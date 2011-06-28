#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 12;
    use DBICx::TestDatabase;
    use VRTrackCrawl::Schema;
    use_ok('VRTrackCrawl::MapStat');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
  
ok my $vrt_assembly   = $dbh->resultset('Assembly'  )->create({ assembly_id   => 10, name           => 'abc',                     reference_size => 123 }), 'create assembly';
ok my $vrt_mapstats   = $dbh->resultset('MapStats'  )->create({ mapstats_id   => 1,  assembly_id    => 10,                        row_id         => 1, lane_id => 2 }), 'create mapstats';
ok my $vrt_lane       = $dbh->resultset('Lane'      )->create({ lane_id       => 2,  hierarchy_name => 'lane_name',               library_id     => 3,     row_id         => 1 }), 'create lane';
ok my $vrt_library    = $dbh->resultset('Library'   )->create({ library_id    => 3,  hierarchy_name => 'library_name',            sample_id      => 4,     row_id         => 1, seq_tech_id => 9 }), 'create library';
ok my $vrt_sample     = $dbh->resultset('Sample'    )->create({ sample_id     => 4,  hierarchy_name => 'sample_name',             individual_id  => 5,     row_id         => 1, project_id  => 7 }), 'create sample';
ok my $vrt_individual = $dbh->resultset('Individual')->create({ individual_id => 5,  species_id     => 6 }), 'create individual';
ok my $vrt_species    = $dbh->resultset('Species'   )->create({ species_id    => 6,  name           => 'Genus Species SubSpecies' }), 'create species';
ok my $vrt_project    = $dbh->resultset('Project'   )->create({ project_id    => 7,  ssid           => 8, row_id => 1 }), 'create project';
ok my $vrt_seq_tech   = $dbh->resultset('SeqTech'   )->create({ seq_tech_id   => 9,  name           => 'SLX' }), 'create seq_tech';


ok my $mapstat = VRTrackCrawl::MapStat->new(
    _dbh => $dbh, 
    alignments_base_directory => 't/data/seq-pipelines', 
    data_hierarchy => "genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane",
    mapstats_id    => 1
  );
is $mapstat->filename, 't/data/seq-pipelines/Genus/Species-SubSpecies/TRACKING/8/sample_name/SLX/library_name/lane_name/1.bam', 'filename constructed correctly';
