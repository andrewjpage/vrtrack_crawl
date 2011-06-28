#!/usr/bin/env perl
use strict;
use warnings;
use JSON;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 8;
    use_ok('VRTrackCrawl::RefsIndex');
}

dies_ok{ my $refs_index = VRTrackCrawl::RefsIndex->new();} 'should die if no file_location passed in';

ok my $refs_index = VRTrackCrawl::RefsIndex->new(file_location => 't/data/refs.index'), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';

my @expected_row1 = ("abc", "t/data/refs/abc.fa");
my @expected_row2 = ("efg", "t/data/refs/efg.fa");
my @expected_array = (\@expected_row1, \@expected_row2);

is_deeply $refs_index->assembly_names_to_sequence_files, \@expected_array, 'read in file is split into 2d array';
my $json = JSON->new->allow_nonref;
is $json->encode($refs_index->references), '{"abc":"t/data/refs/abc.fa","efg":"t/data/refs/efg.fa"}', 'references structure' ;

# Where the reference file dont exist
ok $refs_index = VRTrackCrawl::RefsIndex->new(file_location => 't/data/invalid_refs.index'), 'initialization';
is $json->encode($refs_index->references), '{}', 'filter files which dont exist' ;
