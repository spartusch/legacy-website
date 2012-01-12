#!/usr/bin/perl

# Author: Stefan Partusch
# Date: 05.08.2006
# Short description: Applies a XSLT stylesheet to modified XML files of given directories. Requires the Xalan XSLT processor!

use strict;
use FindModified;

&main;

sub main {
	my ($count, %acronyms);
	my $fmod = new FindModified;

	print "XSLT Processing\n";

	open(FILE, '<acronyms');
	while(<FILE>) {
		chomp;
		if(/^(\w+):([\pL 0-9]+)$/i) {
			$acronyms{$1} = qq~<abbr title="$2">$1</abbr>~;
		}
	}
	close(FILE);

	$count = transformXML('xml_de', 'html_de', $fmod, %acronyms);
	$count += transformXML('xml_en', 'html_en', $fmod, %acronyms);

	print "\n\n$count files processed.\n";
}

sub transformXML {
	my ($src_dir, $dest_dir, $fmod, %acronyms) = @_;
	my @files;# = <$src_dir/*.xml>;

	mkdir($dest_dir);
	foreach my $filename ($fmod->getModified($src_dir)) {
		if($filename =~ /\.xml$/) {
			push(@files, $filename);
			print "\n$filename ... ";

			#open(XALAN, 'xalan -in "'.$filename.'" -xsl xhtml10strict.xsl 2>&1 |') or die($!);
			open(XALAN, 'xalan "'.$filename.'" xhtml10strict.xsl 2>&1 |') or die($!);
			local $/;
			my $cmd_out = <XALAN>;
			close(XALAN) or die("failed\n$cmd_out");

			my @file = split(/<\/h1>|<div id="copyright">/, $cmd_out);
			if(@file != 3) { die; }

			foreach my $acr (keys %acronyms) {
				$file[1] =~ s/(>|>[^<>]*?[^A-Z]{1,1}?)$acr([^A-Z]{1,1}?[^<>]*?<|<)/\1$acronyms{$acr}\2/;
			}
			$file[1] =~ s/ KB\)/ <abbr title="Kilobyte">KB<\/abbr>\)/;
			$file[1] =~ s/ MB\)/ <abbr title="Megabyte">MB<\/abbr>\)/;

			unless($filename =~ s/$src_dir\/([a-z_ ]+)\.xml$/$dest_dir\/\1.html/i) { die; }
			open(FILE, ">$filename") or die($!);
			print FILE $file[0].'</h1>'.$file[1].'<div id="copyright">'.$file[2];
			close(FILE);

			print "ok";
		}
	}

	return @files;
}
