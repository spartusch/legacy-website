#!/usr/bin/perl

# Author: Stefan Partusch
# Date: 05.08.2006
# Short description: Class to find modified and deleted files.

package FindModified;

use strict;

use fields qw(current stored);

sub new {
	my ($self, $db, $dir) = @_;
	unless(ref $self) { $self = fields::new($self); }

	$self->load($db);
	$self->refresh($dir);

	return $self;
}

sub refresh {
	my ($self, $dir) = @_;

	$self->{current} = {};
	unless($dir) { $dir = '.'; }
	$self->getFiles($dir);
}

sub load {
	my ($self, $db) = @_;

	unless($db) { $db = 'findmodified.db'; }
	if(-e($db)) {
		open(FILE, $db);
		foreach(<FILE>) {
			chomp;
			if(/^(.+)\t([0-9]+)$/) {
				%{$self->{stored}}->{$1} = $2;
			}
		}
		close(FILE);
	}
}

sub store {
	my ($self, $db) = @_;

	unless($db) { $db = 'findmodified.db'; }
	open(FILE, ">$db");
	foreach my $file (keys %{$self->{current}}) {
		print FILE $file, "\t", %{$self->{current}}->{$file}, "\n";
	}
	close(FILE);
}

sub getFiles {
	my ($self, $dir) = @_;

	my @files = <$dir/*>;
	foreach(@files) {
		if(-d) {
			$self->getFiles($_);
		}
		else {
			my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat;
			%{$self->{current}}->{$_} = $mtime;
		}
	}
}

sub getModified {
	my ($self, @dirs) = @_;
	my ($dir, @files);

	if(@dirs) { $dir = join('|', @dirs); }
	else  { $dir = '.'; }

	foreach my $file (keys %{$self->{current}}) {
		if($file =~ /^(\.\/)?($dir)/ && (%{$self->{current}}->{$file} != %{$self->{stored}}->{$file})) {
			push(@files, $file);
		}
	}

	return @files;
}

sub getDeleted {
	my ($self, @dirs) = @_;
	my ($dir, @files);

	if(@dirs) { $dir = join('|', @dirs); }
	else  { $dir = '.'; }

	foreach my $file (keys %{$self->{stored}}) {
		if($file =~ /^(\.\/)?($dir)/ && !exists(%{$self->{current}}->{$file})) {
			push(@files, $file);
		}
	}

	return @files;
}

1;