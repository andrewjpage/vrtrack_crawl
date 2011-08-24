=head1 NAME

MapStat.pm   - Represents a row in the VRtrack database and the assosiated data

=head1 SYNOPSIS

use VRTrackCrawl::MapStat;
$mapstat = VRTrackCrawl::MapStat->new(
    _dbh => $dbh,
    alignments_base_directory => 't/data/seq-pipelines',
    data_hierarchy => "genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane",
    mapstats_id    => 1
  );

=cut

package VRTrackCrawl::MapStat;
use Moose;
use VRTrackCrawl::Schema;

has '_dbh'                      => ( is => 'rw',                    required   => 1 );
has 'alignments_base_directory' => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'data_hierarchy'            => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'mapstats_id'               => ( is => 'rw', isa => 'Int',      required   => 1 );
has 'filename'                  => ( is => 'rw', isa => 'Str',      lazy_build => 1 );
has 'qc_status'                 => ( is => 'rw', isa => 'Str',      lazy_build => 1 );

sub _build_qc_status
{
  my ($self) = @_;
  my $lane = $self->_lane_result_set_id($self->mapstats_id)->first;
  return $lane->qc_status if(defined $lane);
  return '';
}

sub _build_filename
{
  my ($self) = @_;

  my @file_name_components;
  push(@file_name_components, $self->alignments_base_directory);
  eval {
    push(@file_name_components, @{$self->_populate_data_hierarchy});
    1;
  } or do
  {
    return '';
  };

  push(@file_name_components, ''.$self->mapstats_id.'.'.$self->_file_extension.'.raw.sorted.bam');
  join('/', @file_name_components);
}

sub _file_extension
{
  my ($self) = @_;
  my $ended;
  
  $self->_is_paired ? 'pe' : 'se';
}

sub _is_paired
{
  my ($self) = @_;
  $self->_lane_result_set_id($self->mapstats_id)->first->paired
}


sub _data_hierarchy_array
{
  my ($self) = @_;
  my @split_data_hierarchy = split(/:/, $self->data_hierarchy);
  return \@split_data_hierarchy;
}

sub _populate_data_hierarchy
{
  my ($self) = @_;
  my @populated_hierarchy;
  for my $directory (@{$self->_data_hierarchy_array})
  {
    if ($directory eq uc($directory)) {
      push(@populated_hierarchy, $directory);
    }
    else
    {
      my $method_to_call = "_$directory";
      $method_to_call =~ s/-/_/g;

      push(@populated_hierarchy, $self->$method_to_call());
    }
  }
  return \@populated_hierarchy;
}


###### Methods called from the data_hierarchy #######
sub _genus
{
  my ($self) = @_;
  @{$self->_split_species_name}[0];
}

sub _species_subspecies
{
  my ($self) = @_;
  my @split_species = @{$self->_split_species_name};
  # remove Genus
  shift(@split_species);
  join('-',@split_species);
}

sub _projectssid
{
  my ($self) = @_;
  $self->_project_result_set_id($self->mapstats_id)->first->ssid;
}

sub _sample
{
  my ($self) = @_;
  $self->_sample_result_set_id($self->mapstats_id)->first->hierarchy_name;
}

sub _technology
{
  my ($self) = @_;
  $self->_seq_tech_result_set_id($self->mapstats_id)->first->name;
}

sub _library
{
  my ($self) = @_;
  $self->_library_result_set_id($self->mapstats_id)->first->hierarchy_name;
}

sub _lane
{
  my ($self) = @_;
  $self->_lane_result_set_id($self->mapstats_id)->first->hierarchy_name;
}


###### END Methods called from the data_hierarchy #######


###### Result Sets ######
sub _lane_result_set_id
{
  my ($self) = @_;
  # we need mapping to have been done
  # 0001 imported
  # 0010 qc'd
  # 0100 mapped
  # 1000 stored
  my @mapping_done = (5,7,13,15,29,31);
  $self->_dbh->resultset('MapStats')->search({ mapstats_id => $self->mapstats_id  })->search_related('lane', { processed => \@mapping_done });
}

sub _library_result_set_id
{
  my ($self) = @_;
  $self->_lane_result_set_id($self->mapstats_id)->search_related('library');
}

sub _seq_tech_result_set_id
{
  my ($self) = @_;
  $self->_library_result_set_id($self->mapstats_id)->search_related('seq_tech');
}

sub _sample_result_set_id
{
  my ($self) = @_;
  $self->_library_result_set_id($self->mapstats_id)->search_related('sample');
}

sub _project_result_set_id
{
  my ($self) = @_;
  $self->_sample_result_set_id($self->mapstats_id)->search_related('project');
}

sub _individual_result_set_id
{
  my ($self) = @_;
  $self->_sample_result_set_id($self->mapstats_id)->search_related('individual');
}

sub _species_result_set_id
{
  my ($self) = @_;
  $self->_individual_result_set_id($self->mapstats_id)->search_related('species');
}

###### End Result Sets ######


sub _species_name
{
  my ($self) = @_;
  $self->_species_result_set_id($self->mapstats_id)->first->name;
}

sub _split_species_name
{
  my ($self) = @_;
  my @split_species_name = split(/ /,$self->_species_name);
  return \@split_species_name;
}

1;
