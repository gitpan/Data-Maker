package Data::Maker::Record;
use Moose;

has delimiter => ( is => 'rw' );
has fields => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );
has data => ( is => 'rw', isa => 'HashRef' );

sub BUILD {
  my $this = shift;
  if (my $args = shift) {
    if (my $data = $args->{data}) {
      for my $key(keys(%{$data})) {
        $this->{$key} = $data->{$key}; 
        has $key => ( is => 'rw' );
      }
    }
  }
}

sub delimited {
  my $this = shift;
  return join($this->delimiter, map { 
      if (my $method = $_->{name} ) {
        $this->$method->value;
      }
    } $this->fields);
}

1;
