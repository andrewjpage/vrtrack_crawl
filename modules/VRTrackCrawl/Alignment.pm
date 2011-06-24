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

use strict;
use warnings;
use Moose;

has 'file'         => ( is => 'rw', isa => 'Str', required => 1 );
has 'index'        => ( is => 'rw', isa => 'Str' );
has 'organism'     => ( is => 'rw', isa => 'Str', required => 1 );
has 'qc_status'    => ( is => 'rw', isa => 'Str' );
# add in more fields from BAM header and from mapstats table

1;
