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
use LWP::UserAgent;
use XML::TreePP;
use URI::Escape;


has '_dbh'                      => ( is => 'rw',               required   => 1 );
has 'file'                      => ( is => 'rw', isa => 'Str', required   => 1 );
has 'organism'                  => ( is => 'rw', isa => 'Str', required   => 1 );
has 'id'                        => ( is => 'rw', isa => 'Str', required   => 1 );
has 'taxon_lookup_service'      => ( is => 'rw', isa => 'Str', required   => 1 );
has 'taxon_name_search_service' => ( is => 'rw', isa => 'Str', required   => 1 );

has 'genus'                     => ( is => 'rw', isa => 'Str',        lazy_build => 1 );
has 'species'                   => ( is => 'rw', isa => 'Str',        lazy_build => 1 );
has 'translation_table'         => ( is => 'rw', isa => 'Maybe[Int]', lazy_build => 1 );
has 'taxon_id'                  => ( is => 'rw', isa => 'Maybe[Int]', lazy_build => 1 );

sub _build_translation_table
{
  my $self = shift;
  my $translation_table = $self->_assembly_result_set->first->translation_table;
  unless(defined $translation_table)
  {  
    $translation_table = $self->_lookup_translation_table;
    my $assembly = $self->_assembly_result_set->first;
    $assembly->translation_table($translation_table);
    $assembly->update;
  }
  $translation_table;
}

sub _build_taxon_id
{
  my $self = shift;
  my $assembly = $self->_assembly_result_set->first;
  
  unless(defined $assembly->taxon_id)
  {  
    my $taxon_id = $self->_lookup_taxon_id;
    my $assembly = $self->_assembly_result_set->first;
    $assembly->taxon_id($taxon_id);
    $assembly->update;
  }
  
  $assembly->taxon_id;
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

sub _lookup_translation_table
{
  my $self = shift;
  my $taxon_service_url = ''.$self->taxon_lookup_service.''.$self->taxon_id ;
  my $translation_table = $self->_local_lookup_translation_table($taxon_service_url);
  
  $translation_table = $self->_remote_lookup_translation_table($taxon_service_url) unless(defined $translation_table);
  
  (defined $translation_table) ? $translation_table : undef;
}

sub _local_lookup_translation_table
{
  my ($self, $file) = @_;
  return undef unless (-e $file);
  
  my $tpp = XML::TreePP->new();
  my $tree = $tpp->parsefile( $file );
  $tree->{TaxaSet}->{Taxon}->{GeneticCode}->{GCId};
}

sub _remote_lookup_translation_table
{
  my ($self, $url) = @_;
  
  eval {
    my $tpp = $self->_setup_xml_parser_via_proxy;
    my $tree = $tpp->parsehttp( GET => $url );
    $tree = $tpp->parse($tree->{html}->{body}->{pre});
    $tree->{TaxaSet}->{Taxon}->{GeneticCode}->{GCId};
  } or do
  {
     VRTrackCrawl::Exceptions::TaxonLookupException->throw( error => "Cant get the translation table for taxon ".$self->taxon_id );
  };
}


sub _lookup_taxon_id
{
  my $self = shift;
  my @species_name = @{$self->_split_species_name};
  pop(@species_name);
  
  my $taxon_id = $self->_local_lookup_taxon_id(''.$self->taxon_name_search_service.''.join('_',@species_name));
  $taxon_id = $self->_remote_lookup_taxon_id($self->taxon_name_search_service, join(' ',@species_name)) unless(defined $taxon_id);
  
  (defined $taxon_id) ? $taxon_id : undef;
}

sub _local_lookup_taxon_id
{
  my ($self, $file) = @_;
  return undef unless (-e $file);
  
  my $tpp = XML::TreePP->new();
  my $tree = $tpp->parsefile( $file );
  $tree->{eSearchResult}->{IdList}->{Id};
}

sub _remote_lookup_taxon_id
{
  my ($self, $url, $search_term) = @_;
  
  eval {
    my $tpp = $self->_setup_xml_parser_via_proxy;
    my $tree = $tpp->parsehttp( GET => ''.$url.uri_escape($search_term) );
    $tree->{eSearchResult}->{IdList}->{Id};
  } or do
  {
     VRTrackCrawl::Exceptions::TaxonLookupException->throw( error => "Cant get the taxon id for ".$self->_species_name );
  };
}






sub _setup_xml_parser_via_proxy
{
  my ($self) = @_;
  my $tpp = XML::TreePP->new();
  my $ua = LWP::UserAgent->new();
  $ua->timeout( 60 );
  $ua->env_proxy;
  $tpp->set( lwp_useragent => $ua );
  $tpp;
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
  return 0 unless(-e $self->file);
  return 0 unless(defined $self->taxon_id);
  
  1;
}


1;
