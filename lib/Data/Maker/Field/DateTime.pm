package Data::Maker::Field::DateTime;
use Moose;
use DateTime::Event::Random;
with 'Data::Maker::Field';

our $VERSION = '0.05';

has start => ( is => 'rw');
has end => ( is => 'rw');
has format => ( is => 'rw');

sub generate_value {
  my $this = shift;
  my $args = {};
  if ($this->start) {
    $args->{start} = DateTime->new( year => $this->start );
  }
  if ($this->end) {
    $args->{end} = DateTime->new( year => $this->end );
  }
  my $dt = DateTime::Event::Random->datetime(
    %{$args}
  );
  if ($this->format) {
    return &{$this->format}($dt);
  }
  return $dt;
}
1;
