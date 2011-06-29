#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use VRTrackCrawl::Alignment;
    use Test::Most tests => 6;
    use VRTrackCrawl::RefsIndex;
    use_ok('Crawl::JSONFile');
}

dies_ok{ my $json_file = Crawl::JSONFile->new();} 'should die if required parameters not passed in';

my $alignment1 = VRTrackCrawl::Alignment->new(
    file      => 'http://localhost/123.bam',
    index     => 'http://localhost/123.bam.bai',
    organism  => 'Mouse',
    qc_status => 'pass'
  );
my $alignment2 = VRTrackCrawl::Alignment->new(
    file      => 'http://localhost/456.bam',
    organism  => 'Human',
    qc_status => 'fail'
  );

my $refs_index = VRTrackCrawl::RefsIndex->new(file_location => 't/data/refs.index');

ok my $json_file = Crawl::JSONFile->new(alignments => [$alignment1, $alignment2], references => $refs_index->references), 'initialization';
isa_ok $json_file, 'Crawl::JSONFile';

my $expected_json_string =  '{"references":{"abc":"t/data/refs/abc.fa","efg":"t/data/refs/efg.fa"},"alignments":[{"qc_status":"pass","index":"http://localhost/123.bam.bai","file":"http://localhost/123.bam","organism":"Mouse"},{"qc_status":"fail","index":"http://localhost/456.bam.bai","file":"http://localhost/456.bam","organism":"Human"}]}';
ok my $output_json_string = $json_file->render_to_json();
is $output_json_string, $expected_json_string, 'output json matches';
