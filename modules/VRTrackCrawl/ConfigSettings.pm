=head1 NAME

ConfigSettings.pm   - Return configuration settings

=head1 SYNOPSIS

use VRTrackCrawl::ConfigSettings;
my %config_settings = %{VRTrackCrawl::ConfigSettings->new(environment => 'test')->settings()};

=cut

package VRTrackCrawl::ConfigSettings;

use strict;
use warnings;
use Moose;
use File::Slurp;
use YAML::XS;

has 'environment' => (is => 'rw', isa => 'Str', default => 'test');
has 'settings' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );

sub _build_settings 
{
  my $self = shift;
  my %config_settings = %{ Load( scalar read_file("config/".$self->environment."/config.yml"))};

  return \%config_settings;
} 

1;
