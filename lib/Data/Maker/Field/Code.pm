package Data::Maker::Field::Code;
use Moose;
with 'Data::Maker::Field';

has code => ( is => 'rw', isa => 'CodeRef');

sub generate_value {
  my ($this, $maker) = @_;
  &{$this->code}($this, $maker);
}

1;
