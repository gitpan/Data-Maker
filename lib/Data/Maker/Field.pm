package Data::Maker::Field;
use Moose::Role;

our $VERSION = '0.08';

has name      => ( is => 'rw' );
has class     => ( is => 'rw' );
has args      => ( is => 'rw', isa => 'HashRef' );
#has format    => ( is => 'rw', default => undef );
has digits    => ( is => 'ro', isa => 'ArrayRef', default => sub { [0..9]             }, lazy => 1);
has letters   => ( is => 'ro', isa => 'ArrayRef', default => sub { ['a'..'z']         }, lazy => 1 );
has wordchars => ( is => 'ro', isa => 'ArrayRef', default => sub { [ 0..9, 'a'..'z' ] }, lazy => 1 );
has hex_set   => ( is => 'ro', isa => 'ArrayRef', default => sub { [ 0..255 ]         }, lazy => 1 );
has value     => ( is => 'rw' );
has formatted => ( is => 'rw', default => sub { shift->value }  );

requires 'generate_value';

sub generate {
  my $this = shift;
  my $maker = shift;
  $this->value( $this->generate_value($maker) );
  return $this;
}

sub output {
  my $this = shift;
  $this->value;
}
sub from_format {
  my $this = shift;
  return unless $this->formatter || $this->format;
  my $out;
  while(my $atom = $this->next_atom) {
    if ($atom eq '\\') {
      $atom .= $this->next_atom;
    }
    if ($atom eq '\\d') {
      $atom = $this->digit;
    } elsif ($atom eq '\\w') {
      $atom = $this->wordchar;
    } elsif ($atom eq '\\W') {
      $atom = uc($this->wordchar);
    } elsif ($atom eq '\\l') {
      $atom = $this->letter;
    } elsif ($atom eq '\\x') {
      $atom = $this->hex;
    } elsif ($atom eq '\\X') {
      $atom = uc($this->hex);
    } elsif ($atom eq '\\L') {
      $atom = uc($this->letter);
    }
    $out .= $atom;
  }
  undef $this->{_working_format};
  return $out;
}

sub next_atom {
  my $this = shift;
  my $key = '_working_format';
  $this->{$key} = [ split('', $this->formatter || $this->format) ] unless $this->{$key} ;
  return shift @{$this->{$key}};
}

sub _rand_from_list {
  my ($this, $list) = @_;
  return $list->[ rand @{$list} ]
}
sub digit {
  my $this = shift;
  $this->_rand_from_list($this->digits);
}
sub letter {
  my $this = shift;
  $this->_rand_from_list($this->letters);
}
sub wordchar {
  my $this = shift;
  $this->_rand_from_list($this->wordchars);
}
sub hex {
  my $this = shift;
  sprintf("%2.2x", $this->_rand_from_list($this->hex_set) );
};

1;


__END__

=head1 NAME

Data::Maker::Field - a L<Moose> role that is consumed by all Data::Maker field classes; the ones included with Data::Maker and the ones that you write yourself to extend Data::Maker's capabilities.

=head1 SYNOPSIS

  use Data::Maker;
  use Data::Maker::Field::Person::LastName;
  use MyField;

  my $maker = Data::Maker->new(
    record_count => 10_000,
    delimiter => "\t",
    fields => [
      { 
        name => 'lastname', 
        class => 'Data::Maker::Field::Person::LastName'
      },
      { 
        name => 'ssn', 
        class => 'Data::Maker::Field::Format',
        args => {
          format => '\d\d\d-\d\d-\d\d\d\d'
        }
      },
      { 
        name => 'myfield', 
        class => 'MyField'
      },
    ]
  );
  

=head1 DESCRIPTION

To write your own Data::Maker field class, create a L<Moose> class that consumes the Data::Maker::Field role.  

  package MyField;
  use Moose;
  with 'Data::Maker::Field';
 
  has some_attribute => ( is => 'rw' ); 

  sub generate_value {
    my ($this, $maker) = @_;
    # amazing code here...
    return $amazing_value;
  }

  1;


You must provide a C<generate_value> method, which is the method that will be called to generate the value of this field for each record.

Any Moose attribute that you define (C<some_flag> in the above example) can then be passed in as an argument in your field definition and will be available as an object method inside your C<generate_value> method (or any other class method, for that matter):

  # define the field in your Data::Maker constructor:

  my $maker = Data::Maker->new(
    record_count => 10,
    fields => [ 
      {
        name => 'myfield',
        class => 'MyField',
        args => { 
          some_attribute => 'blah' 
        }
      }
    ]
  );

  # And then later, in C<generate_value>...

  sub generate_value {
    my ($this, $maker) = @_;
    # $this->some_attribute now return "blah"
    # amazing code here...
    return $amazing_value;
  }
