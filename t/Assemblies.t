#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 17;
    use DBICx::TestDatabase;
    use Crawl::JSONFile;
    use_ok('VRTrackCrawl::Assemblies');
}

my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');
$dbh->resultset('Assembly')->create({ assembly_id => 2, name => 'homo_sapiens_456',  reference_size => 123 , taxon_id => 9606});
ok my $vrt_assembly   = $dbh->resultset('Assembly'  )->create({ assembly_id   => 10, name           => 'homo_sapiens_123',                     reference_size => 123, taxon_id => 9606 }), 'create assembly';
ok my $vrt_mapstats   = $dbh->resultset('MapStats'  )->create({ mapstats_id   => 1,  assembly_id    => 10,                        row_id         => 1, lane_id => 2 }), 'create mapstats';
ok my $vrt_lane       = $dbh->resultset('Lane'      )->create({ lane_id       => 2,  hierarchy_name => 'lane_name',               library_id     => 3,     row_id         => 1, processed => 7, qc_status => 'passed', paired => 1  }), 'create lane';
ok my $vrt_library    = $dbh->resultset('Library'   )->create({ library_id    => 3,  hierarchy_name => 'library_name',            sample_id      => 4,     row_id         => 1, seq_tech_id => 9 }), 'create library';
ok my $vrt_sample     = $dbh->resultset('Sample'    )->create({ sample_id     => 4,  hierarchy_name => 'sample_name',             individual_id  => 5,     row_id         => 1, project_id  => 7 }), 'create sample';
ok my $vrt_individual = $dbh->resultset('Individual')->create({ individual_id => 5,  species_id     => 6 }), 'create individual';
ok my $vrt_species    = $dbh->resultset('Species'   )->create({ species_id    => 6,  name           => 'Genus Species SubSpecies' }), 'create species';
ok my $vrt_project    = $dbh->resultset('Project'   )->create({ project_id    => 7,  ssid           => 8, row_id => 1 }), 'create project';
ok my $vrt_seq_tech   = $dbh->resultset('SeqTech'   )->create({ seq_tech_id   => 9,  name           => 'SLX' }), 'create seq_tech';


my $expected_alignment = VRTrackCrawl::Alignment->new(file  => 't/data/seq-pipelines/Genus/Species-SubSpecies/TRACKING/8/sample_name/SLX/library_name/lane_name/1.pe.raw.sorted.bam', organism => 'homo_sapiens_123', qc_status => 'passed');
my @expected_array = ($expected_alignment);

dies_ok{ my $assemblies = VRTrackCrawl::Assemblies->new();} 'should die if required fields not passed in';

ok my $assemblies = VRTrackCrawl::Assemblies->new(
  refs_index_file_location => 't/data/refs.index', 
  _dbh => $dbh, 
  alignments_base_directory => 't/data/seq-pipelines',
  data_hierarchy => "genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane",
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/homo_sapiens_ncbi_name_lookup_xml_page_',
   ), 'initialization and build alignment objects from database';
isa_ok $assemblies, 'VRTrackCrawl::Assemblies';

is_deeply $assemblies->alignments, \@expected_array, 'alignment objects data match expected' ;

my $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
  taxon_name_search_service => 't/data/homo_sapiens_ncbi_name_lookup_xml_page_',
  );
ok my $json_file = Crawl::JSONFile->new(alignments => $assemblies->alignments, references => $refs_index->references), 'initialization';

my $expected_json_string =    '{"references":[{"file":"t/data/refs/homo_sapiens_123.gff","organism":{"translation_table":"1","ID":0,"common_name":"homo_sapiens_123","genus":"homo","taxonID":"9606","species":"sapiens_123"}},{"file":"t/data/refs/homo_sapiens_456.gff","organism":{"translation_table":"1","ID":1,"common_name":"homo_sapiens_456","genus":"homo","taxonID":"9606","species":"sapiens_456"}}],"alignments":[{"qc_status":"passed","index":"t/data/seq-pipelines/Genus/Species-SubSpecies/TRACKING/8/sample_name/SLX/library_name/lane_name/1.pe.raw.sorted.bam.bai","file":"t/data/seq-pipelines/Genus/Species-SubSpecies/TRACKING/8/sample_name/SLX/library_name/lane_name/1.pe.raw.sorted.bam","organism":"homo_sapiens_123"}]}';
ok my $output_json_string = $json_file->render_to_json(), 'render crawl json';
is $output_json_string, $expected_json_string, 'output json matches';
