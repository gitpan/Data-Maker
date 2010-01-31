package Data::Maker::Field::Person::SSN;
use Moose;
with 'Data::Maker::Field::Format';

sub format { return '\d\d\d-\d\d-\d\d\d\d' }

1;
