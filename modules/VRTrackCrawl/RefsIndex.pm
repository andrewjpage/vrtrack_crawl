=head1 NAME

RefsIndex.pm   - Representation of the refs.index file from lustre

=head1 SYNOPSIS

use VRTrackCrawl::RefsIndex;
my $refs_index = VRTrackCrawl::RefsIndex->new( file_location => 't/data/refs.index');
$refs_index->assembly_ids_to_sequence_files();

=cut

package VRTrackCrawl::RefsIndex;

use strict;
use warnings;

sub new
{
    my ($class,@args) = @_;
    my $self = @args ? {@args} : {};
    bless $self, ref($class) || $class;
    
    die "File location must be specified" unless defined $self->{file_location};
    $self->load_file();
 
    return $self;
}

sub load_file
{
  my( $self ) = @_;
  $self->{assembly_ids_to_sequence_files} = [];
  
  open(FILE, $self->{file_location}) or die "Couldnt open refs.index file";
  while(<FILE>) {
    chomp;
    my($assembly_id, $sequence_file) = split("\t");
    my @single_row = ($assembly_id, $sequence_file);
    push( @{$self->{assembly_ids_to_sequence_files}}, @single_row );
  }
  
  close(FILE);
}

sub assembly_ids_to_sequence_files
{
  my( $self ) = @_;
  return $self->{assembly_ids_to_sequence_files};
}

1;
