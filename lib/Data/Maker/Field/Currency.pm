package Data::Maker::Field::Currency;
use Moose;
use MooseX::Aliases;
extends 'Data::Maker::Field::Number';
use Data::Money;

our $VERSION = '0.20';

has '+precision' => ( default => 2 );
has '+separate_thousands' => ( default => 1 );
has 'as_float' => ( is => 'rw', isa => 'Bool', default => 0 );
has iso_code => ( is => 'rw', default => 'USD', alias => 'code');
has with_code => ( is => 'rw', isa => 'Bool', default => 0);

sub generate_value {
  my $this = shift;
  my $thousands = $this->separate_thousands;
  $this->separate_thousands(0) if $thousands;
  my $money = Data::Money->new(
    value => $this->SUPER::generate_value(@_),
    code => $this->iso_code,
    format => 'FMT_COMMON'
  );
  my $out;
  if ($this->as_float) {
    $out = $money->as_float;
  } elsif ($thousands) {
    $this->separate_thousands(1);
    $out = $money;
  } else {
    $out = $money->as_float;
  }
  if ($this->with_code) {
    #$out =~ s/[^\d\.\,]//g;
    #$out =~ s/^\.//;
    $out = join(' ', $this->iso_code, $out);
  }
  return $out;
}

1;
