=head1 NAME

JSONFile.pm   - Generate a JSON file in the format required by crawl

=head1 SYNOPSIS

use Crawl::JSONFile;
my $json_file = Crawl::JSONFile->new(alignments => @alignments, references => %references);
$json_file.render_to_json();

=cut

package Crawl::JSONFile;

use JSON;
use Moose;

has 'alignments'       => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'references'       => ( is => 'rw', isa => 'HashRef',  required => 1 );
has 'output_structure' => ( is => 'rw', isa => 'HashRef',  lazy_build => 1 );

sub _build_output_structure
{
  my $self = shift;
  my %crawl_json_hash;
  $crawl_json_hash{alignments} = $self->alignments;
  $crawl_json_hash{references} = $self->references;
  return \%crawl_json_hash;
}

sub render_to_json 
{
  my $self = shift;
  my $json = JSON->new->allow_nonref;
  $json = $json->allow_blessed([1]);
  $json->get_allow_blessed;
  $json = $json->convert_blessed([1]);
  return $json->encode( $self->output_structure );
}

1;