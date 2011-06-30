package VRTrackCrawl::Exceptions;

use Exception::Class (
    VRTrackCrawl::Exceptions::TaxonLookupException => { description => 'Cant get the translation table for a given taxon id' },
);

1;
