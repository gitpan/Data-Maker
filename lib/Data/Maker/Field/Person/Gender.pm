package Data::Maker::Field::Person::Gender;
use Moose;
extends 'Data::Maker::Field::Code';
use Text::GenderFromName;

our $VERSION = '0.05';

has from_field => ( is => 'rw', isa => 'Str');

has code => ( 
  is => 'rw', 
  default => sub { 
    sub {
      my ($this, $maker) = @_;
      if (my $field = $this->from_field) {
        if (my $name = $maker->in_progress($field)) {
          if (my $gender = gender($name)) {
            return uc($gender);
          } else {
            return 'F' if $name =~ /(a|ie)$/;
            return 'M' if $name =~ /o$/;
            return 'U';
          }
        } else {
          die "no in-progress \"$field\" field\n";
        }
      } else {
        die "you have to tell me what field to use as a data source for determining gender\n";
      }
    }
  }
);



1;
