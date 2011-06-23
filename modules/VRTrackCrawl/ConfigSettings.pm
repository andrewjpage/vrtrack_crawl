=head1 NAME

ConfigSettings.pm   - Return configuration settings

=head1 SYNOPSIS

use VRTrackCrawl::ConfigSettings;
my %config_settings = %{VRTrackCrawl::ConfigSettings->new(environment => 'test')->get_config_settings()};

=cut

package VRTrackCrawl::ConfigSettings;

use strict;
use warnings;
use File::Slurp;
use YAML::XS;

sub new
{
    my ($class,@args) = @_;
    my $self = @args ? {@args} : {};
    bless $self, ref($class) || $class;
    
    $self->{environment} = 'test' unless defined $self->{environment};

    return $self;
}

sub get_config_settings
{
  my( $self ) = @_;
  my %config_settings = %{ Load( scalar read_file("config/".$self->{environment}."/config.yml"))};

  return \%config_settings;
} 

1;
