#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 4;
    use_ok('VRTrackCrawl::Alignment');
}

dies_ok{ my $alignment = VRTrackCrawl::Alignment->new();} 'should die if required parameters not passed in';

ok my $alignment = VRTrackCrawl::Alignment->new(
    file      => 'http://localhost/123.bam',
    index     => 'http://localhost/123.bam.bai',
    organism  => 'Mouse',
    qc_status => 'pass'
  ), 'initialization';
isa_ok $alignment, 'VRTrackCrawl::Alignment';
