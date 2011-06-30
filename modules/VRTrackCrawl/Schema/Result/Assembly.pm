package VRTrackCrawl::Schema::Result::Assembly;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('assembly');
__PACKAGE__->add_columns('assembly_id' => {}, 'name' => {}, 'reference_size' => {}, 'taxon_id' => { is_nullable => 1 }, 'translation_table' => { is_nullable => 1 } );
__PACKAGE__->set_primary_key('assembly_id');
__PACKAGE__->has_many(mapstats => 'VRTrackCrawl::Schema::Result::MapStats', 'assembly_id');

1;
