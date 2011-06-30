=head1 NAME

RefsIndex.pm   - Representation of the refs.index file from lustre

=head1 SYNOPSIS

use VRTrackCrawl::RefsIndex;
my $refs_index = VRTrackCrawl::RefsIndex->new(
  file_location => 't/data/refs.index',
  _dbh      => $dbh,
  taxon_lookup_service => 't/data/homo_sapiens_ncbi_taxon_lookup_xml_page_'
  );

$refs_index->references;

=cut

package VRTrackCrawl::RefsIndex;

use Moose;
use VRTrackCrawl::Reference;

has 'file_location'             => ( is => 'rw', isa => 'Str',      required   => 1 );
has '_dbh'                      => ( is => 'rw',                    required   => 1 );
has 'taxon_lookup_service'      => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'taxon_name_search_service' => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'references'                => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );

sub _build_references
{
  my $self = shift;
  my $id_count = 0;
  my @references;

  for my $reference_row (@{$self->_assembly_names_to_sequence_files})
  {
    eval{
      my $reference = VRTrackCrawl::Reference->new(
          _dbh      => $self->_dbh,
          file      => @{$reference_row}[1],
          organism  => @{$reference_row}[0],
          taxon_lookup_service => $self->taxon_lookup_service,
          taxon_name_search_service => $self->taxon_name_search_service,
          id        => $id_count
        );
      if( $reference->is_valid() )
      {
        push(@references, $reference);
        $id_count++;
      }
    };
  }
  return \@references;
}

sub _assembly_names_to_sequence_files
{
  my $self = shift;
  my @ref_index_split;

  open(FILE, $self->file_location) or die "Couldnt open refs.index file";
  while(<FILE>) {
    chomp;
    my @single_row = split("\t");
    push( @ref_index_split, \@single_row );
  }

  close(FILE);
  return \@ref_index_split ;
}

1;
