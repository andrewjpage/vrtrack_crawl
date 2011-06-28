package VRTrackCrawl::Schema::Result::SeqTech;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('seq_tech');
__PACKAGE__->add_columns(qw/seq_tech_id name/);
__PACKAGE__->set_primary_key('seq_tech_id');
__PACKAGE__->has_many(libraries => 'VRTrackCrawl::Schema::Result::Library', 'library_id');

1;
