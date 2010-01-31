package Data::Maker;
use Data::Maker::Record;
use Moose;
use MooseX::AttributeHelpers;
use Data::Maker::Field::Format;

our $VERSION = '0.02';

has fields => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );
has record_count => ( is => 'rw' );
has object_cache => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has data_sources => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has record_counts => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has delimiter => ( is => 'rw' );
has records => ( is => 'rw', isa => 'ArrayRef[Date::Maker::Record]', auto_deref => 1, default => sub { [] } );
has generated => ( is => 'rw', isa => 'Num', default => 0);
has seed => ( is => 'rw', isa => 'Num');

sub BUILD {
  my $this = shift;
  if ($this->seed) {
    srand($this->seed);
  }
}

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
    } elsif ($field->{format}) {
      my $object = Data::Maker::Field::Format->new( format => $field->{format} );
      $record->{ $field->{name} } = $object->generate($this);
    }
  }
  my $obj = Data::Maker::Record->new(data => $record, fields => [$this->fields], delimiter => $this->delimiter );
  #push(@{$this->records}, $obj);
  $this->generated( $this->generated + 1 );
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
sub header {
  my $this = shift;
  return join($this->delimiter, map { $_->{label} } $this->fields); 
}


1;
