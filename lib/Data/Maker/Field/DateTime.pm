package Data::Maker::Field::DateTime;
use Moose;
use DateTime::Event::Random;
with 'Data::Maker::Field';

our $VERSION = '0.08';

has start => ( is => 'rw');
has end => ( is => 'rw');
has format => ( is => 'rw');

sub generate_value {
  my $this = shift;
  my $args = {
    start => $this->parse_date_arg('start'),
    end => $this->parse_date_arg('end'),
  };
  my $dt = DateTime::Event::Random->datetime(
    %{$args}
  );
  if ($this->format) {
    return &{$this->format}($dt);
  }
  return $dt;
}

# `start` and `end` can be either a year or an actual DateTime object.  This method determines which it is and 
sub parse_date_arg {
  my ($this, $keyword) = @_;
  if (my $in = $this->$keyword) {
    if (ref($in) && $in->isa('DateTime')) {
      return $in;
    } elsif ($in =~ /^\d{4}$/) {
      return DateTime->new( year => $in );
    } else {
      die "Invalid `$keyword` argument to " . __PACKAGE__;
    }
  }
}
1;
