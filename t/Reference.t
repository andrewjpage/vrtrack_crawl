#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 12;
    use DBICx::TestDatabase;
    use_ok('VRTrackCrawl::Reference');
}
my $dbh = DBICx::TestDatabase->new('VRTrackCrawl::Schema');

dies_ok{ my $reference = VRTrackCrawl::Reference->new();} 'should die if required parameters not passed in';

$dbh->resultset('Assembly')->create({ assembly_id => 1, name => 'Homo_sapiens_123',  reference_size => 123 , taxon_id => 9606 });

ok my $reference = VRTrackCrawl::Reference->new(
    _dbh                 => $dbh,
    file                 => 'http://localhost/123.bam',
    organism             => 'Homo_sapiens_123',
    taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
    id                   => 1
  ), 'initialization';
isa_ok $reference, 'VRTrackCrawl::Reference';

is $reference->genus, 'Homo', 'get genus';
is $reference->species, 'sapiens_123', 'get species';
is $reference->translation_table, 1, 'get translation table';
is $reference->taxon_id, 9606, 'get taxon id';

# Cant get taxon id 

$dbh->resultset('Assembly')->create({ assembly_id => 2, name => 'Another_name_123',  reference_size => 123 , taxon_id => 1 });

ok $reference = VRTrackCrawl::Reference->new(
    _dbh                 => $dbh,
    file                 => 'http://localhost/123.bam',
    organism             => 'Another_name_123',
    taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
    id                   => 1
  ), 'initialization';
dies_ok{ $reference->translation_table; };


# translation table is already saved to the database so no need to look it up
$dbh->resultset('Assembly')->create({ assembly_id => 3, name => 'Some_other_name',  reference_size => 123 , taxon_id => 9606, translation_table => 99 });

ok $reference = VRTrackCrawl::Reference->new(
    _dbh                 => $dbh,
    file                 => 'http://localhost/123.bam',
    organism             => 'Some_other_name',
    taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
    id                   => 1
  ), 'initialization';
is $reference->translation_table, 99, 'dont lookup taxon webservice if translation already stored in db';