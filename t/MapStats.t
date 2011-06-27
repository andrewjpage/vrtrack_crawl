#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 12;
    use DBICx::TestDatabase;
    use VRTrackCrawl::Schema;
    use_ok('VRTrackCrawl::Schema::Result::MapStats');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
  
ok my $vrt_assembly   = $dbh->resultset('Assembly'  )->create({ assembly_id   => 10, name          => 'abc', reference_size => 123 }), 'create assembly';
ok my $vrt_mapstats   = $dbh->resultset('MapStats'  )->create({ mapstats_id   => 1,  assembly_id   => 10,    row_id         => 1, lane_id => 2 }), 'create mapstats';
ok my $vrt_lane       = $dbh->resultset('Lane'      )->create({ lane_id       => 2,  library_id    => 3,     row_id         => 1 }), 'create lane';
ok my $vrt_library    = $dbh->resultset('Library'   )->create({ library_id    => 3,  sample_id     => 4,     row_id         => 1 }), 'create library';
ok my $vrt_sample     = $dbh->resultset('Sample'    )->create({ sample_id     => 4,  individual_id => 5,     row_id         => 1 }), 'create sample';
ok my $vrt_individual = $dbh->resultset('Individual')->create({ individual_id => 5,  species_id    => 6 }), 'create individual';
ok my $vrt_species    = $dbh->resultset('Species'   )->create({ species_id    => 6,  name          => 'species_name' }), 'create species';

ok my @actual_mapstats = $dbh->resultset('MapStats')->search({ mapstats_id => 1  })->all;
is $actual_mapstats[0]->assembly_id, 10, 'retrieve a column';

ok my $mapstats = $dbh->resultset('MapStats')->search({ mapstats_id => 1  });
my $all_results = $mapstats->search_related('lane')->search_related('library')->search_related('sample')->search_related('individual')->search_related('species')->first;
is_deeply $all_results->species_id, 6,'retrieve a species_id from mapstats';

