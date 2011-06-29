#!/usr/bin/env perl

=head1 NAME

generate.pl

=head1 SYNOPSIS

vrtrack_alignments_for_crawl.pl -e (test|production) -c (eukaryotes|helminths|metahit|prokaryotes|viruses|test)

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
use Crawl::JSONFile;

my $ENVIRONMENT;
my $CATEGORY;

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'category|c=s'       => \$CATEGORY
);

$ENVIRONMENT or die <<USAGE;
Usage: $0 [options]
Create a JSON file for crawl.

./vrtrack_alignments_for_crawl.pl -e (test|production) -c (eukaryotes|helminths|metahit|prokaryotes|viruses|test)

 Options:
     --environment       The configuration settings you wish to use ( test | production )
     --category          ( eukaryotes | helminths | metahit | prokaryotes | viruses | test )
The environment variable DATA_HIERARCHY should be set (defaults to "genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane").

USAGE
;

# initialise settings
my %config_settings = %{VRTrackCrawl::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'config.yml')->settings()};
my %database_settings = %{VRTrackCrawl::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'database.yml')->settings()};
my $data_hierarchy = $ENV{'DATA_HIERARCHY'} || $config_settings{default_data_hierarchy};

my $dbh = VRTrackCrawl::Schema->connect("DBI:mysql:host=$database_settings{$CATEGORY}{host}:port=$database_settings{$CATEGORY}{port};database=$database_settings{$CATEGORY}{database}", $database_settings{$CATEGORY}{user}, $database_settings{$CATEGORY}{password}, {'RaiseError' => 1, 'PrintError'=>0});

my $assemblies = VRTrackCrawl::Assemblies->new( 
    _dbh => $dbh, 
    refs_index_file_location => $config_settings{refs_index_file}, 
    alignments_base_directory => $config_settings{$CATEGORY}{base_directory},
    data_hierarchy => $data_hierarchy
    );
my $refs_index = VRTrackCrawl::RefsIndex->new(file_location => $config_settings{refs_index_file});
my $json_file = Crawl::JSONFile->new(alignments => $assemblies->alignments(), references => $refs_index->references);

open (OUTPUT_FILE, "+>$config_settings{$CATEGORY}{output_json_file}") or die "Couldnt open output file";
print OUTPUT_FILE $json_file->render_to_json();
close (OUTPUT_FILE);

print "Saved file to $config_settings{$CATEGORY}{output_json_file}\n";
