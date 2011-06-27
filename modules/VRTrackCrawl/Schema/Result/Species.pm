package VRTrackCrawl::Schema::Result::Species;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('species');
__PACKAGE__->add_columns(qw/species_id name/);
__PACKAGE__->set_primary_key('species_id');
__PACKAGE__->has_many(individuals => 'VRTrackCrawl::Schema::Result::Individual', 'individual_id');

1;
