package VRTrackCrawl::Schema::Result::Individual;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('individual');
__PACKAGE__->add_columns(qw/individual_id species_id/);
__PACKAGE__->set_primary_key('individual_id');
__PACKAGE__->has_many(samples => 'VRTrackCrawl::Schema::Result::Sample', 'sample_id');
__PACKAGE__->belongs_to(species => 'VRTrackCrawl::Schema::Result::Species', { 'foreign.species_id' => 'self.species_id' });

1;
