package VRTrackCrawl::Schema::Result::Lane;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('latest_lane');
__PACKAGE__->add_columns(qw/row_id lane_id library_id hierarchy_name processed qc_status paired/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(mapstats => 'VRTrackCrawl::Schema::Result::MapStats', 'lane_id');
__PACKAGE__->belongs_to(library => 'VRTrackCrawl::Schema::Result::Library', { 'foreign.library_id' => 'self.library_id' });

1;
