package VRTrackCrawl::Exceptions;

use Exception::Class (
    VRTrackCrawl::Exceptions::TaxonLookupException => { description => 'Cant get the translation table for a given taxon id' },
    VRTrackCrawl::Exceptions::NullTaxonID => { description => 'Null taxon ID found so not going to use this reference'}
);

1;
