#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 6;
    use VRTrackCrawl::RefsIndex;
    use VRTrackCrawl::Alignment;
    use DBICx::TestDatabase;
    use_ok('Crawl::JSONFile');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
$dbh->resultset('Assembly')->create({ assembly_id => 1, name => 'homo_sapiens_123',  reference_size => 123 , taxon_id => 9606 });
$dbh->resultset('Assembly')->create({ assembly_id => 2, name => 'homo_sapiens_456',  reference_size => 123 , taxon_id => 9606 });

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

my $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/homo_sapiens_ncbi_name_lookup_xml_page_',
  );

ok my $json_file = Crawl::JSONFile->new(alignments => [$alignment1, $alignment2], references => $refs_index->references), 'initialization';
isa_ok $json_file, 'Crawl::JSONFile';

my $expected_json_string =  '{"references":[{"file":"t/data/refs/homo_sapiens_123.fa","organism":{"translation_table":"1","common_name":"homo_sapiens_123","taxon_id":"9606","genus":"homo","species":"sapiens_123","id":0}},{"file":"t/data/refs/homo_sapiens_456.fa","organism":{"translation_table":"1","common_name":"homo_sapiens_456","taxon_id":"9606","genus":"homo","species":"sapiens_456","id":1}}],"alignments":[{"qc_status":"pass","index":"http://localhost/123.bam.bai","file":"http://localhost/123.bam","organism":"Mouse"},{"qc_status":"fail","index":"http://localhost/456.bam.bai","file":"http://localhost/456.bam","organism":"Human"}]}';
ok my $output_json_string = $json_file->render_to_json();
is $output_json_string, $expected_json_string, 'output json matches';
