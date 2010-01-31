package Data::Maker::Field::Format;
use Moose;
with 'Data::Maker::Field';

our $VERSION = '0.05';

has formatter => ( is => 'rw', builder => 'format' );
has format => ( is => 'rw');

#requires 'format';

sub generate_value { 
  my $this = shift;
  if (my $value = $this->from_format) {
    return $value;
  }
}


1;
