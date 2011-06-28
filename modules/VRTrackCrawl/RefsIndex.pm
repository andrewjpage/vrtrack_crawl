=head1 NAME

RefsIndex.pm   - Representation of the refs.index file from lustre

=head1 SYNOPSIS

use VRTrackCrawl::RefsIndex;
my $refs_index = VRTrackCrawl::RefsIndex->new( file_location => 't/data/refs.index');
$refs_index->assembly_names_to_sequence_files;

=cut

package VRTrackCrawl::RefsIndex;

use Moose;

has 'file_location' => ( is => 'rw', isa => 'Str', required => 1 );
has 'assembly_names_to_sequence_files' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );

sub _build_assembly_names_to_sequence_files
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

sub references
{
  my $self = shift;
  my %references_to_output;
  for my $reference (@{$self->assembly_names_to_sequence_files})
  {
    next unless -e @{$reference}[1];
    $references_to_output{@{$reference}[0]} = @{$reference}[1];
  }
  return \%references_to_output;
}
1;
