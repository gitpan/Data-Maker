package Data::Maker;
use Data::Maker::Record;
use Moose;
use MooseX::AttributeHelpers;

our $VERSION = '0.05';

has fields => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );
has record_count => ( is => 'rw' );
has object_cache => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has data_sources => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has record_counts => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has delimiter => ( is => 'rw' );
has records => ( is => 'rw', isa => 'ArrayRef[Date::Maker::Record]', auto_deref => 1, default => sub { [] } );

#has records => ( 
#  metaclass => 'Collection::List',
#  is => 'rw', 
#  isa => 'ArrayRef[Data::Maker::Record]'
#);

sub generated { shift->generated_count }
sub generated_count { scalar @{shift->records} }

sub field_by_name {
  my ($this, $name) = @_;
  for my $field($this->fields) {
    if ($field->{name} eq $name) {
      return $field;
    }
  }
}

sub next_record {
  my $this = shift;
  return if $this->generated >= $this->record_count;
  my $record = {};
  $this->{_in_progress} = $record;
  for my $field($this->fields) {
    if (my $class = $field->{class}) {
      $field->{args}->{name} = $field->{name};
      #my $object = $this->new_or_cached($class, $field);
      my $object = $this->object_cache->{$class} || $class->new( $field->{args} ? %{$field->{args}} : () );
      $record->{ $field->{name} } = $object->generate($this);
    }
  }
  my $obj = Data::Maker::Record->new(data => $record, fields => [$this->fields], delimiter => $this->delimiter );
  push(@{$this->records}, $obj);
  return $obj;
}

sub previous_record {
  my $this = shift;
  my $current = $this->generated;
  my $previous = $current - 1;
  return unless $previous;
  my $prev_index = $previous - 1;
  if (my $record = $this->records->[$prev_index]) {
    return $record;
  }
}

sub new_or_cached {
  my ($this, $class, $field) = @_;
  return $this->object_cache->{$class} || $class->new( $field->{args} ? %{$field->{args}} : () );
}
sub in_progress {
  my ($this, $name) = @_;
  if (my $prog = $this->{_in_progress}) {
    if (my $field = $prog->{$name}) {
      return $field->value;
    }
  }
}

1;
