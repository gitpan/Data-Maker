package Data::Maker::Field::Person::Name;
use Moose;
with 'Data::Maker::Field';
use Data::Maker::Field::Person::FirstName;
use Data::Maker::Field::Person::MiddleName;
use Data::Maker::Field::Person::LastName;

has firstname => ( is => 'rw' );
has middlename => ( is => 'rw' );
has lastname => ( is => 'rw' );
has format => ( is => 'rw' );

sub generate_value {
  my $this = shift;
  my $maker = shift;
  my $segments = {
    f => { class => 'Data::Maker::Field::Person::FirstName', method => 'firstname' },
    m => { class => 'Data::Maker::Field::Person::MiddleName', method => 'middlename' },
    l => { class => 'Data::Maker::Field::Person::LastName', method => 'lastname' },
  };
  if (my $formatted = $this->format) {
    for my $key(keys(%{$segments})) {
      if (my $class = $segments->{$key}->{class}) {
        my $value = $class->new->generate;
        if (my $method = $segments->{$key}->{method}) {
          $this->$method($value);
        }
        $formatted =~ s/%$key/$value->value/ge;
      }
    }
    $this->formatted($formatted);
    return $this->formatted;
  } else {
    return;
  }
}


1;
