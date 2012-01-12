#!/usr/bin/perl

# Author: Stefan Partusch
# Date: 05.08.2006
# Short description: upload modified files via FTP and delete files, which have been deleted locally, from the server.

use Net::FTP;
use FindModified;
use strict;

my $ignore = 'xml_de/
xml_en/
acronyms
common_de.xml
common_en.xml
html_eng
findmodified.db
FindModified.pm
logs_p
toXhtml.pl
upload.pl
toXhtml
upload
xhtml10strict.xsl';

main($ignore, 'home.arcor.de', 'partusch');

sub main {
	my ($ignore, $host, $user, $password) = @_;
	my (@upload, @delete);

	print "FTP Uploader\n";
	$ignore =~ tr/\n/|/;

	unless($password) {
		print 'Bitte Passwort eingeben: ';
		$password = <>;
		chomp($password);
	}

	my $fmod = new FindModified;
	foreach my $file ($fmod->getModified) {
		if($file !~ /^(\.\/)?$ignore/) { push(@upload, $file); }
	}
	foreach my $file ($fmod->getDeleted) {
		if($file !~ /^(\.\/)?$ignore/) { push(@delete, $file); }
	}

	my $ftp = new Net::FTP($host, Passive => 1) or die('Connection failed');
	$ftp->login($user, $password) or die('Login failed');

	$ftp->binary;
	foreach my $file (@upload) {
		print "\nUploading $file ... ";
		$ftp->put($file, $file) or print 'failed';
		print 'ok';
	}

	foreach my $file (@delete) {
		print "\nDeleting $file ... ";
		$ftp->delete($file) or print 'failed';
		print 'ok';
	}

	print "\n\n", scalar @upload, ' files uploaded and ', scalar @delete, " files deleted.\n";

	$ftp->quit;
	$fmod->store;
}
