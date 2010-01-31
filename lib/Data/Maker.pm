package Data::Maker;
use Data::Maker::Record;
use Moose;
use MooseX::AttributeHelpers;
use Data::Maker::Field::Format;

our $VERSION = '0.03';

# The list of fields to be generated
has fields => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );

# how many records?
has record_count => ( is => 'rw', isa => 'Num' );

# Ensure reuse of the field objects for each row.  This is important because
# certain objects have large data sets inside them
has object_cache => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# This is a hashref to store open file handles
has data_sources => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# A hashref of record counts.  Not sure why this was used.  It's mentioned in
# Data::Maker::Field::File 
has record_counts => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# The optional delimiter... could be anything.  Usually a comma, tab, pipe, etc
has delimiter => ( is => 'rw' );

# Here I deleted the "records" arrayref.   There is no additional need for it. 

# This is for maintaining a count of the number of records that have been generated.
has generated => ( is => 'rw', isa => 'Num', default => 0);

# The optional random seed
has seed => ( is => 'rw', isa => 'Num');

# The BUILD method is a Moose thing.  It is run immediately after the object is created.
# We seed the randomness of a seed was provided.
sub BUILD {
  my $this = shift;
  if ($this->seed) {
    srand($this->seed);
  }
}

# Given the name of a field, this method returns the Field object
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
  $this->generated( $this->generated + 1 );
  return $obj;
}

# deleted previous_record() method.  It was only going to be useful if we were maintaining
# a list of all records generated, and that's just not scalable and isn't needed.

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
__END__

=head1 NAME

Data::Maker - Simple, flexibile and extensible generation of realistic data

=head1 SYNOPSIS

  my $maker = Data::Maker->new(
    record_count => 10_000,
    fields => [
      { name => 'phone', format => '(\d\d\d)\d\d\d-\d\d\d\d' } 
    ]
  );

  while (my $record = $maker->next_record) {
    print $record->delimited . "\n";
  }

=head1 DESCRIPTION

L<Data::Maker> does not know why kind of data you need, but it will help you make lots of it.

And if you happen to need one of the various types of data that is available as predefined field types,
it can be made even easier.

=head1 CONSTRUCTOR

=over 4

=item B<new PARAMS>

Returns a new L<Data::Maker> object.  Any PARAMS passed to the constructor will be set as properties of the object.

=back

=head1 OBJECT METHODS

=over 4

=item B<BUILD>

The BUILD method is a L<Moose> thing.  It is run immediately after the object is created.
Currently used in Data::Maker only to seed the randomness, if a seed was provided.

=item B<field_by_name>

Given the name of a field, this method returns the Field object

=item B<next_record>

This method not only gets the next record, but it also triggers the generation of the data itself.

=item B<new_or_cached>

This method is not used yet, though I keep hoping the object_cache() code above (in next_record ) 
will call this method instead of having the code there.  But it is really only used once
in this form, so I'm perhaps being too picky.

=item B<in_progress> B<NAME>

This method is used to get the already-generated value of a field in the list,
before the entire record has been created and blessed as a Record object.
This was created for, and is mostly useful for, fields that depend upon the values
of other fields.  For example, the Data::Maker::Field::Person::Gender class uses this,
so that the gender of the person will match the first name of the person.

=item B<header>

Prints out a delimited list of all of the labels, only if a delimiter was 
provided to the L<Data::Maker> object

=back

=head1 PROPERTIES

=over 4

=item B<fields> (I<ArrayRef>)

The list of fields to be generated

=item B<record_count> (I<Num>)

The number of records desired

=item B<object_cache> (I<HashRef>)

Ensure reuse of the field objects for each row.  This is important 
because certain objects have large data sets inside them.

=item B<data_sources> (I<HashRef>)

This is a hashref to store open file handles

=item B<record_counts> (I<HashRef>)

A hashref of record counts.  Not sure why this was used.  It's mentioned in
Data::Maker::Field::File 

=item B<delimiter>

The optional delimiter... could be anything.  Usually a comma, tab, pipe, etc

=item B<generated> (I<Num>)

This is for maintaining a count of the number of records that have been generated.

=item B<seed> (I<Num>)

The optional random seed.  Provide a seed to ensure that the randomly-generated 
data comes out the same each time you run it.

=back

