package Data::Maker::Field;
use Moose::Role;

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
