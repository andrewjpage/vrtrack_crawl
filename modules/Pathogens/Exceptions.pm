package Pathogens::Exceptions;

use Exception::Class (
    Pathogens::Exceptions::MissingParameterException => { description => 'Expected input parameter to the new method is missing' },
);

1;
