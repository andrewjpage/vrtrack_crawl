=head1 NAME

JSONFile.pm   - Generate a JSON file in the format required by crawl

=head1 SYNOPSIS

use Crawl::JSONFile;
my $json_file = Crawl::JSONFile->new(alignments => @alignments);
$json_file.to_json();

=cut

package Crawl::JSONFile;

use strict;
use warnings;
use JSON;
use Moose;

has 'alignments'       => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_structure' => ( is => 'rw', isa => 'HashRef',  lazy_build => 1 );

sub _build_output_structure
{
  my $self = shift;
  %crawl_json_hash;
  $crawl_json_hash(alignments => $self->alignments);
  return \%crawl_json_hash;
}

sub to_json 
{
  my $self = shift;
  $json = JSON->new->allow_nonref;
  $json_text = $json->encode( $self->output_structure );
}

 