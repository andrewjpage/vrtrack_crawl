#!/usr/bin/env perl

=head1 NAME

generate.pl

=head1 SYNOPSIS

generate -e [test|production]

=head1 DESCRIPTION

This application generates a json file for crawl to allow BAM files stored in the VRTrack database to be viewed through Web-Artemis

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut
package Deploy;

BEGIN { unshift(@INC, './modules') }
use strict;
use warnings;
use Getopt::Long;
use VRTrackCrawl::ConfigSettings;

my $ENVIRONMENT;

GetOptions ('environment|e=s'    => \$ENVIRONMENT);

$ENVIRONMENT or die <<USAGE;
Usage: $0 [options]
Create a JSON file for crawl

 Options:
     --environment		   The configuration settings you wish to use (test|production)

USAGE
;

# initialise settings
my %config_settings = %{VRTrackCrawl::ConfigSettings->new(environment => $ENVIRONMENT)->get_config_settings()};

use VRTrackCrawl::RefsIndex;
my $refs_index = VRTrackCrawl::RefsIndex->new( file_location => $config_settings{refs_index_file} );
