=head1 NAME

Assemblies.pm   - Represents a collection of assemblies from the tracking database, populated from RefsIndex. 
It returns an array of Alignment objects.

=head1 SYNOPSIS

use VRTrackCrawl::Assemblies;
my $assemblies = VRTrackCrawl::Assemblies->new( database_connection => $dbh);
my $assemblies->alignments();

=cut

package VRTrackCrawl::Assemblies;
use Moose;
use VRTrackCrawl::Schema;
use VRTrackCrawl::RefsIndex;
use VRTrackCrawl::Alignment;
use VRTrackCrawl::Schema::Result::Assembly;
use VRTrackCrawl::Schema::Result::MapStats;


has '_dbh'                     => ( is => 'rw',                    required   => 1 );
has 'refs_index_file_location' => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'alignments'               => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );

sub _build_alignments
{
  my $self = shift;
  my @alignment_objects;
  
  my $refs_index = VRTrackCrawl::RefsIndex->new( file_location => 't/data/refs.index');
  my @assembly_names_to_sequence_files = $refs_index->assembly_names_to_sequence_files;
  
  for my $assembly_name_to_sequence_file (@assembly_names_to_sequence_files)
  {
    my $assemblies = $self->_dbh->resultset('Assembly')->search({ name => { like => @{$assembly_name_to_sequence_file}[0] } });
    while( my $assembly = $assemblies->next )
    {
      my $mapstats = $self->_dbh->resultset('MapStats')->search({ assembly_id => $assembly->assembly_id, latest => 1  });
      
      while( my $mapstat = $mapstats->next )
      {
        # mapstats->lane->library->sample->individual->species->name
        # qc_status => $mapstat->qcstatus 
        my $alignment_object = VRTrackCrawl::Alignment->new(
          file => $self->_filename_from_mapstats_id($mapstat->mapstats_id),
          organism => 'Plasmodium' 
          );
        push(@alignment_objects, $alignment_object);
      }
    }
  }
  return \@alignment_objects;
}

sub _filename_from_mapstats_id
{
  my ($self, $mapstats_id) = @_;
  return "http://localhost/".$mapstats_id.".bam";
}

sub _assemblies
{
  my $self = shift;
  my $assembly_name = shift;

  my @assemblies = $self->_dbh->resultset('Assembly')->search(
    { name => { like => $assembly_name } }
  );
  return \@assemblies;
}

sub _map_stats_from_assembly
{
  my $self = shift;
  my $assembly_id = shift;

  my @mapstats = $self->_dbh->resultset('MapStats')->search(
    { assembly_id => $assembly_id  }
  )->all;
}

1;
