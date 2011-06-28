package VRTrackCrawl::Schema::Result::Library;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('latest_library');
__PACKAGE__->add_columns(qw/row_id library_id sample_id seq_tech_id hierarchy_name/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(lanes => 'VRTrackCrawl::Schema::Result::Lane', 'lane_id');
__PACKAGE__->belongs_to(sample => 'VRTrackCrawl::Schema::Result::Sample', { 'foreign.sample_id' => 'self.sample_id' });
__PACKAGE__->belongs_to(seq_tech => 'VRTrackCrawl::Schema::Result::SeqTech', { 'foreign.seq_tech_id' => 'self.seq_tech_id' });

1;
