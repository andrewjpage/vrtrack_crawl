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
use VRTrackCrawl::Assemblies;

my $ENVIRONMENT;

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'category|c=s'       => \$CATEGORY
);

$ENVIRONMENT or die <<USAGE;
Usage: $0 [options]
Create a JSON file for crawl

 Options:
     --environment       The configuration settings you wish to use ( test | production )
     --category          ( eukaryotes | helminths | metahit | prokaryotes | viruses | test )

USAGE
;

# initialise settings
my %config_settings = %{VRTrackCrawl::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'config.yml')->settings()};
my %database_settings = %{VRTrackCrawl::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'database.yml')->settings()};


# lookup assembly name in DB
# Get to mapstats table and find BAM where ID of mapstats = BAM name
# Find organism and reference genome
# produce JSON file

my $dbh = VRTrackCrawl::Schema->connect("DBI:mysql:host=$database_settings{$CATEGORY}{host}:port=$database_settings{$CATEGORY}{port};database=$database_settings{$CATEGORY}{database}", $database_settings{$CATEGORY}{user}, $database_settings{$CATEGORY}{password}, {'RaiseError' => 1, 'PrintError'=>0});

my $assemblies = VRTrackCrawl::Assemblies->new( 
    _dbh => $dbh, 
    refs_index_file_location => $config_settings{refs_index_file}, 
    alignments_base_directory => $config_settings{$CATEGORY}{base_directory});
my @alignments = $assemblies->alignments();

