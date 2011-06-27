package VRTrackCrawl::Schema::Result::Assembly;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('assembly');
__PACKAGE__->add_columns(qw/ assembly_id name reference_size /);
__PACKAGE__->set_primary_key('assembly_id');
__PACKAGE__->has_many(mapstats => 'VRTrackCrawl::Schema::Result::MapStats', 'assembly_id');

1;
