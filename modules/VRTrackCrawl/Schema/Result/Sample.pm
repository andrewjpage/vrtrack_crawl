package VRTrackCrawl::Schema::Result::Sample;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('latest_sample');
__PACKAGE__->add_columns(qw/row_id sample_id individual_id project_id hierarchy_name/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(libraries => 'VRTrackCrawl::Schema::Result::Library', 'library_id');
__PACKAGE__->belongs_to(individual => 'VRTrackCrawl::Schema::Result::Individual', { 'foreign.individual_id' => 'self.individual_id' });
__PACKAGE__->belongs_to(project => 'VRTrackCrawl::Schema::Result::Project', { 'foreign.project_id' => 'self.project_id' });

1;
