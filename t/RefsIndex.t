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
my $vrt_assembly = $dbh->resultset('Assembly')->create({ assembly_id => 1, name => 'homo_sapiens_123',  reference_size => 123 , taxon_id => 9606 });
$dbh->resultset('Assembly')->create({ assembly_id => 2, name => 'homo_sapiens_456',  reference_size => 123 , taxon_id => 9606});

dies_ok{ my $refs_index = VRTrackCrawl::RefsIndex->new();} 'should die if no file_location passed in';

ok my $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/homo_sapiens_ncbi_name_lookup_xml_page_',
), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';

my @expected_row1 = ("homo_sapiens_123", "t/data/refs/homo_sapiens_123.fa");
my @expected_row2 = ("homo_sapiens_456", "t/data/refs/homo_sapiens_456.fa");
my @expected_array = (\@expected_row1, \@expected_row2);

is_deeply $refs_index->_assembly_names_to_sequence_files, \@expected_array, 'read in file is split into 2d array';
my $json = JSON->new->allow_nonref;
$json = $json->allow_blessed([1]);
$json->get_allow_blessed;
$json = $json->convert_blessed([1]);

is $json->encode($refs_index->references), '[{"file":"t/data/refs/homo_sapiens_123.gff","organism":{"translation_table":"1","ID":0,"common_name":"homo_sapiens_123","genus":"homo","taxonID":"9606","species":"sapiens_123"}},{"file":"t/data/refs/homo_sapiens_456.gff","organism":{"translation_table":"1","ID":1,"common_name":"homo_sapiens_456","genus":"homo","taxonID":"9606","species":"sapiens_456"}}]' ;

# Where the reference file dont exist
ok $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/invalid_refs.index', 
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/homo_sapiens_ncbi_name_lookup_xml_page_',), 'initialization';
  
is $json->encode($refs_index->references), '[]', 'filter files which dont exist' ;


# dont use the references if the taxon id doesnt exist
$vrt_assembly->taxon_id(undef);
$vrt_assembly->update;
ok $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/nonexistant_name_xml_page_',
), 'initialization';
isa_ok $refs_index, 'VRTrackCrawl::RefsIndex';
is $json->encode($refs_index->references),'[{"file":"t/data/refs/homo_sapiens_456.gff","organism":{"translation_table":"1","ID":0,"common_name":"homo_sapiens_456","genus":"homo","taxonID":"9606","species":"sapiens_456"}}]', 'dont use the references if the taxon id doesnt exist' ;
