package App::Martha;
# ABSTRACT: Build wxPerl desktop applications with a selected Strawberry Perl

use strict;
use warnings;
use File::Copy qw(copy);
use File::ShareDir qw(dist_dir);
use File::Spec;

our $VERSION = '0.003';

sub create_example {
    my ($directory) = @_;
    die "Usage: martha --example NEW_DIRECTORY\n" unless defined $directory && length $directory;

    my $source = File::Spec->catdir(dist_dir('App-Martha'), 'roundtrip');
    mkdir $directory or die "Cannot create new example directory '$directory': $!\n";
    my @copied;
    for my $name (qw(demo.wxg DemoFrame.pm app.pl)) {
        my $destination = File::Spec->catfile($directory, $name);
        my $template = File::Spec->catfile($source, $name);
        # An open source handle copies the bytes without inheriting the
        # installed template's Windows read-only attribute.
        my $input;
        unless (open($input, '<:raw', $template) and copy($input, $destination)) {
            my $error = $!;
            unlink $destination, @copied;
            rmdir $directory;
            die "Cannot copy $name to '$directory': $error\n";
        }
        push @copied, $destination;
    }
    return $directory;
}

1;
