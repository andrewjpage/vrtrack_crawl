package VRTrackCrawl::Schema::Result::MapStats;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('latest_mapstats');
__PACKAGE__->add_columns(qw/row_id mapstats_id lane_id assembly_id/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->belongs_to(assembly => 'VRTrackCrawl::Schema::Result::Assembly', { 'foreign.assembly_id' => 'self.assembly_id' });
__PACKAGE__->belongs_to(lane => 'VRTrackCrawl::Schema::Result::Lane', { 'foreign.lane_id' => 'self.lane_id' } );

1;
