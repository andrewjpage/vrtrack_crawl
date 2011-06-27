package VRTrackCrawl::Schema::Result::MapStats;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('mapstats');
__PACKAGE__->add_columns(qw/row_id mapstats_id lane_id assembly_id latest/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->belongs_to(assembly => 'VRTrackCrawl::Schema::Result::Assembly', 'assembly_id');

1;
