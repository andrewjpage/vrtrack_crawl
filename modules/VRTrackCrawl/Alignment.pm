=head1 NAME

Alignment.pm   - Representation of an alignment and its data

=head1 SYNOPSIS

use VRTrackCrawl::Alignment;
my $alignment = VRTrackCrawl::Alignment->new(
    file      => 'http://localhost/123.bam',
    index     => 'http://localhost/123.bam.bai',
    organism  => 'Mouse',
    qc_status => 'pass'
  );

=cut

package VRTrackCrawl::Alignment;

use Moose;

has 'file'         => ( is => 'rw', isa => 'Str', required => 1 );
has 'index'        => ( is => 'rw', isa => 'Str' );
has 'organism'     => ( is => 'rw', isa => 'Str', required => 1 );
has 'qc_status'    => ( is => 'rw', isa => 'Str' );
# add in more fields from BAM header and from mapstats table

sub TO_JSON
{
  my $self = shift;
  my %attributes_to_output = (
      file => $self->file,
      index => $self->index,
      organism => $self->organism,
      qc_status => $self->qc_status
    );
  return \%attributes_to_output;
}

sub is_valid
{
  my $self = shift;
  return 0 unless (-e $self->file)
}

1;
