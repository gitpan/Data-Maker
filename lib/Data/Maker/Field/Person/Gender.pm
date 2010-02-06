package Data::Maker::Field::Person::Gender;
use Moose;
extends 'Data::Maker::Field::Code';
use Text::GenderFromName;

our $VERSION = '0.08';

has from_field => ( is => 'rw', isa => 'Str');
has from_name => ( is => 'rw', isa => 'Str');

has code => ( 
  is => 'rw', 
  default => sub { 
    sub {
      my ($this, $maker) = @_;
      my $field = $this->from_field;
      my $name = $maker->in_progress($field) if $field;
      $name = shift || 'Pat' unless $name;
      return $this->get_gender($name);
    }
  }
);

sub get_gender {
  my ($this, $name) = @_;
  if (my $gender = gender($name)) {
    return uc($gender);
  } else {
    return 'F' if $name =~ /(a|ie)$/;
    return 'M' if $name =~ /o$/;
    return 'U';
  }
}


1;
