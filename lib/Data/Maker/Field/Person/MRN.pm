package Data::Maker::Field::Person::MRN;
use Moose;
with 'Data::Maker::Field::Format';

sub format {  '\d\d\d\W\W\W\d\d\d' }

1;
