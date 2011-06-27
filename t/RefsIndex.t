#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 5;
    use_ok('VRTrackCrawl::RefsIndex');
}

dies_ok{ my $refs_index = VRTrackCrawl::RefsIndex->new();} 'should die if no file_location passed in';

ok my $refs_index = VRTrackCrawl::RefsIndex->new(file_location => 't/data/refs.index'), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';

my @expected_row1 = ("abc", "/somedirectory/abc.fa");
my @expected_row2 = ("efg", "/somedirectory/efg.fa");
my @expected_array = (\@expected_row1, \@expected_row2);

is_deeply $refs_index->assembly_names_to_sequence_files, \@expected_array, 'read in file is split into 2d array' ;
