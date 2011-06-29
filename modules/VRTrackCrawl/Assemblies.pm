=head1 NAME

Assemblies.pm   - Represents a collection of assemblies from the tracking database, populated from RefsIndex. 
It returns an array of Alignment objects.

=head1 SYNOPSIS

use VRTrackCrawl::Assemblies;
my $assemblies = VRTrackCrawl::Assemblies->new( 
    _dbh => $dbh, 
    refs_index_file_location => 't/data/refs.index', 
    alignments_base_directory => 'http://localhost');
my $assemblies->alignments();

=cut

package VRTrackCrawl::Assemblies;
use Moose;
use VRTrackCrawl::Schema;
use VRTrackCrawl::RefsIndex;
use VRTrackCrawl::Alignment;
use VRTrackCrawl::MapStat;


has '_dbh'                      => ( is => 'rw',                    required   => 1 );
has 'refs_index_file_location'  => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'alignments_base_directory' => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'data_hierarchy'            => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'alignments'                => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );

sub _build_alignments
{
  my $self = shift;
  my @alignment_objects;
  
  my $refs_index = VRTrackCrawl::RefsIndex->new( file_location => $self->refs_index_file_location);
  my @assembly_names_to_sequence_files = @{$refs_index->assembly_names_to_sequence_files};
  
  for my $assembly_name_to_sequence_file (@assembly_names_to_sequence_files)
  {
    my $assemblies = $self->_assemblies( @{$assembly_name_to_sequence_file}[0] );
    while( my $assembly = $assemblies->next )
    {
      my $mapstats = $self->_map_stats_from_assembly($assembly->assembly_id);
      while( my $mapstat = $mapstats->next )
      {
        my $alignment = $self->_create_alignment($mapstat, $assembly);
        push(@alignment_objects,$alignment) if defined $alignment ;
      }
    }
  }
  return \@alignment_objects;
}

sub _create_alignment
{
  my ($self, $mapstat, $assembly) = @_;
  my $mapstat_data = VRTrackCrawl::MapStat->new(
    _dbh => $self->_dbh, 
    alignments_base_directory => $self->alignments_base_directory, 
    data_hierarchy => $self->data_hierarchy,
    mapstats_id    => $mapstat->mapstats_id
  );
   
  my $alignment_object = VRTrackCrawl::Alignment->new(
    file => $mapstat_data->filename,
    organism => $assembly->name,
    qc_status => $mapstat_data->qc_status
  );
  
  # Dont return anything if the alignment is invalid, e.g. bam file doesnt exist
  return undef unless $alignment_object->is_valid();
  return $alignment_object;
}


sub _assemblies
{
  my $self = shift;
  my $assembly_name = shift;

  my $assemblies = $self->_dbh->resultset('Assembly')->search(
    { name => { like => $assembly_name } }
  );
  return $assemblies;
}

sub _map_stats_from_assembly
{
  my $self = shift;
  my $assembly_id = shift;

  my $mapstats = $self->_dbh->resultset('MapStats')->search(
    { assembly_id => $assembly_id  }
  );
  return $mapstats;
}

1;
