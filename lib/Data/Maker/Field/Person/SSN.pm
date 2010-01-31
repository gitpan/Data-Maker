package Data::Maker::Field::Person::SSN;
use Moose;
with 'Data::Maker::Field::Format';

our $VERSION = '0.08';

sub format { return '\d\d\d-\d\d-\d\d\d\d' }

1;
