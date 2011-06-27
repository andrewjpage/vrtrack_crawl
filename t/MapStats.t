#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 5;
    use DBICx::TestDatabase;
    use VRTrackCrawl::Schema;
    use_ok('VRTrackCrawl::Schema::Result::MapStats');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
  
ok my $vrt_assembly = $dbh->resultset('Assembly')->find_or_create({ name => 'abc', assembly_id => 10, reference_size => 123 }), 'create assembly';
ok my $vrt_mapstats = $dbh->resultset('MapStats')->create({ mapstats_id => 111, assembly_id => 10, latest => 1, row_id => 1, lane_id => 2 }), 'create mapstats';

ok my @actual_mapstats = $dbh->resultset('MapStats')->search({ mapstats_id => 111  })->all;

is $actual_mapstats[0]->assembly_id, 10, 'retrieve a column';

