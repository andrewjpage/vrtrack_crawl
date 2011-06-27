#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 5;
    use DBICx::TestDatabase;
    use_ok('VRTrackCrawl::Assemblies');
}

my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');

my $vrt_assembly = $dbh->resultset('Assembly')->find_or_create({ name => 'abc', assembly_id => 999, reference_size => 123 });
my $vrt_mapstats = $dbh->resultset('MapStats')->create({ mapstats_id => '111', assembly_id => 999, latest => 1, row_id => 1, lane_id => 2 });
my $expected_alignment = VRTrackCrawl::Alignment->new(file  => 'http://localhost/111.bam', organism => 'Plasmodium');
my @expected_array = ($expected_alignment);

dies_ok{ my $assemblies = VRTrackCrawl::Assemblies->new();} 'should die if required fields not passed in';

ok my $assemblies = VRTrackCrawl::Assemblies->new(refs_index_file_location => 't/data/refs.index', _dbh => $dbh ), 'initialization and build alignment objects from database';
isa_ok $assemblies, 'VRTrackCrawl::Assemblies';

is_deeply $assemblies->alignments, \@expected_array, 'alignment objects data match expected' ;
