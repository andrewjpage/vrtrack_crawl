=head1 NAME

Reference.pm   - A reference assembly

=head1 SYNOPSIS

use VRTrackCrawl::Reference;

my $reference = VRTrackCrawl::Reference->new(
    _dbh      => $dbh,
    file      => 'http://localhost/123.bam',
    organism  => 'Homo_sapiens_123',
    taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_',
    id        => 1
  );
  
$reference->genus;
$reference->species;
$reference->translation_table;
$reference->taxon_id;

=cut

package VRTrackCrawl::Reference;

use Moose;
use VRTrackCrawl::Schema;
use VRTrackCrawl::Exceptions;
use XML::LibXML ;


has '_dbh'                 => ( is => 'rw',               required   => 1 );
has 'file'                 => ( is => 'rw', isa => 'Str', required   => 1 );
has 'organism'             => ( is => 'rw', isa => 'Str', required   => 1 );
has 'id'                   => ( is => 'rw', isa => 'Str', required   => 1 );
has 'taxon_lookup_service' => ( is => 'rw', isa => 'Str', required   => 1 );

has 'genus'                => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'species'              => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'translation_table'    => ( is => 'rw', isa => 'Int', lazy_build => 1 );
has 'taxon_id'             => ( is => 'rw', isa => 'Int', lazy_build => 1 );

use Data::Dumper;

sub _build_translation_table
{
  my $self = shift;
  my $parser = XML::LibXML->new();
  eval {
    my $dom = XML::LibXML->load_xml( location => ''.$self->taxon_lookup_service.''.$self->taxon_id );
    $dom->findvalue('//Taxon/GeneticCode/GCId');
  } or do
  {
     VRTrackCrawl::Exceptions::TaxonLookupException->throw( error => "Cant get the translation table for taxon ".$self->taxon_id );
  };
}

sub _build_taxon_id
{
  my $self = shift;
  $self->_assembly_result_set->first->taxon_id;
}

sub _build_genus
{
  my ($self) = @_;
  @{$self->_split_species_name}[0];
}

sub _build_species
{
  my ($self) = @_;
  my @split_species = @{$self->_split_species_name};
  # remove Genus
  shift(@split_species);
  join('_',@split_species);
}

sub _assembly_result_set
{
  my ($self) = @_;
  $self->_dbh->resultset('Assembly')->search({ name => $self->organism  });
}

sub _species_name
{
  my ($self) = @_;
  $self->_assembly_result_set()->first->name;
}

sub _split_species_name
{
  my ($self) = @_;
  my @split_species_name = split(/_/,$self->_species_name);
  return \@split_species_name;
}

sub TO_JSON
{
  my $self = shift;
  my %reference_data;
  
  $reference_data{file} = $self->file;
  my %organism_data = ( 
    common_name       => $self->organism, 
    id                => $self->id,
    genus             => $self->genus,
    species           => $self->species,
    translation_table => $self->translation_table,
    taxon_id          => $self->taxon_id 
  );
  $reference_data{organism} = \%organism_data;

  return \%reference_data;
}

sub is_valid
{
  my $self = shift;
  return 0 unless (-e $self->file)
}


1;
