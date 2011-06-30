#!/usr/bin/env perl
use strict;
use warnings;
use JSON;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 11;
    use DBICx::TestDatabase;
    use_ok('VRTrackCrawl::RefsIndex');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
my $assembly = $dbh->resultset('Assembly')->create({ assembly_id => 1, name => 'abc',  reference_size => 123 , taxon_id => 9606 });
$dbh->resultset('Assembly')->create({ assembly_id => 2, name => 'efg',  reference_size => 123 , taxon_id => 9606});

dies_ok{ my $refs_index = VRTrackCrawl::RefsIndex->new();} 'should die if no file_location passed in';

ok my $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';

my @expected_row1 = ("abc", "t/data/refs/abc.fa");
my @expected_row2 = ("efg", "t/data/refs/efg.fa");
my @expected_array = (\@expected_row1, \@expected_row2);

is_deeply $refs_index->_assembly_names_to_sequence_files, \@expected_array, 'read in file is split into 2d array';
my $json = JSON->new->allow_nonref;
$json = $json->allow_blessed([1]);
$json->get_allow_blessed;
$json = $json->convert_blessed([1]);

is $json->encode($refs_index->references), '[{"file":"t/data/refs/abc.fa","organism":{"translation_table":"1","common_name":"abc","taxon_id":"9606","genus":"abc","species":"","id":0}},{"file":"t/data/refs/efg.fa","organism":{"translation_table":"1","common_name":"efg","taxon_id":"9606","genus":"efg","species":"","id":1}}]', 'references structure' ;

# Where the reference file dont exist
ok $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/invalid_refs.index', 
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',), 'initialization';
is $json->encode($refs_index->references), '[]', 'filter files which dont exist' ;


# dont use the references if the taxon id doesnt exist
$assembly->taxon_id(undef);
$assembly->update;
ok $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';
is $json->encode($refs_index->references),'[{"file":"t/data/refs/efg.fa","organism":{"translation_table":"1","common_name":"efg","taxon_id":"9606","genus":"efg","species":"","id":0}}]', 'dont use the references if the taxon id doesnt exist' ;

