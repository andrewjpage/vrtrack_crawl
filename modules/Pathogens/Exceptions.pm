package Pathogens::Exceptions;

use Exception::Class (
    Pathogens::Exceptions::CantCreatePathToAlignmentFile => { description => 'Data thats needed to create the path to the alignment file is missing from the database' },
);

1;
