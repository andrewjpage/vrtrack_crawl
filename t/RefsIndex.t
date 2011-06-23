#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 6;
    use_ok('VRTrackCrawl::RefsIndex');
}

dies_ok{ my $refs_index = VRTrackCrawl::RefsIndex->new();} 'should die if no file_location passed in';

ok my $refs_index = VRTrackCrawl::RefsIndex->new(file_location => 't/data/refs.index'), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';

ok my @expected_refs = (["abc", "/somedirectory/abc.fa"], ["efg", "/somedirectory/efg.fa"]);
is_deeply $refs_index->assembly_ids_to_sequence_files(), \@expected_refs;
