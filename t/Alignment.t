#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 6;
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

ok $alignment = VRTrackCrawl::Alignment->new(
    file      => 'http://localhost/123.bam',
    index     => 'http://localhost/123.bam.bai',
    organism  => 'Mouse',
    qc_status => undef
  ), 'initialization without a qc_status set';
is $alignment->is_valid, 0, 'it should be invalid if qc_status is not set';
