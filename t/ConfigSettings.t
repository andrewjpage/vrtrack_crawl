#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 8;
    use_ok('VRTrackCrawl::ConfigSettings');
}

ok my $config_settings = VRTrackCrawl::ConfigSettings->new(environment => 'some_environment'), 'initialization';
is $config_settings->{environment}, 'some_environment', 'some_environment loaded';

ok $config_settings = VRTrackCrawl::ConfigSettings->new(), 'initialization';
is $config_settings->{environment}, 'test', 'test environment loaded by default';
isa_ok $config_settings, 'VRTrackCrawl::ConfigSettings';

ok my %settings = %{$config_settings->settings}, 'settings hash';
is $settings{refs_index_file}, 't/data/refs.index', 'refs index file location';
