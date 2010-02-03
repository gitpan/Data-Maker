package Data::Maker;
use Data::Maker::Record;
use Moose;
use Data::Maker::Field::Format;

our $VERSION = '0.09';

has fields => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );
has record_count => ( is => 'rw', isa => 'Num' );
has object_cache => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has data_sources => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has record_counts => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has delimiter => ( is => 'rw' );
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

An extremely basic example:

  use Data::Maker;

  my $maker = Data::Maker->new(
    record_count => 10_000,
    fields => [
      { name => 'phone', format => '(\d\d\d)\d\d\d-\d\d\d\d' } 
    ]
  );

  while (my $record = $maker->next_record) {
    print $record->phone . "\n";
  }

A more complete example:

  use Data::Maker;
  use Data::Maker::Field::Person::LastName;
  use Data::Maker::Field::Person::FirstName;

  my $maker = Data::Maker->new(
    record_count => 10_000,
    delimiter => "\t",
    fields => [
      { 
        name => 'lastname', 
        class => 'Data::Maker::Field::Person::LastName'
      },
      { 
        name => 'firstname', 
        class => 'Data::Maker::Field::Person::FirstName'
      },
      { 
        name => 'phone', 
        class => 'Data::Maker::Field::Format',
        args => {
          format => '(\d\d\d)\d\d\d-\d\d\d\d',
        }
      },
    ]
  );

  while (my $record = $maker->next_record) {
    print $record->delimited . "\n";
  }


=head1 DESCRIPTION

Whatever kind of test or demonstration data you need, L<Data::Maker> will help you make lots of it.

And if you happen to need one of the various types of data that is available as predefined field types,
it will be even easier.

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

=head1 ATTRIBUTES

The following L<Moose> attributes are used (the data type of each attribute is also listed):

=over 4

=item B<fields> (I<ArrayRef[HashRef]>)

A list of hashrefs, each of which describes one field to be generated.   Each field needs to define the subclass of L<Data::Maker::Field> that is used to generate that field.  The order of the fields has I<some> relevance, particularly in the context of L<Data::Maker::Record>.  For example, the L<delimited|Data::Maker::Record/delimited> method returns the fields in the order in which they are listed here. 

B<Note:> It may make more sense in the future for each field to have a "sequence" attribute, so methods such as L<delimited|Data::Maker::Record/delimited> would return then in a different order than that in which they are generated.  The order in which fields are generated matters in the event that one field relies on data from another (for example, the L<Data::Maker::Field::Person::Gender> field class relies on a first name that must have already been generated).

=over 8 

=item * L<Data::Maker::Field::Code> - Use a code reference to generate the data.  This is useful for generating a value for a field that is based on the value of another field.

=item * L<Data::Maker::Field::DateTime> - Generates a random DateTime, using L<DateTime::Event::Random>.

=item * L<Data::Maker::Field::File> - Provide your own file of seed data.

=item * L<Data::Maker::Field::Format> - Specify a format for the data to follow.  The follow regexp-inspired atoms are supported:

  \d: Digit
  \w: Word character
  \W: Word character, with all letters uppercase
  \l: Letter
  \L: Uppercase letter
  \x: hex character (00, f2, 97, b4, etc)
  \X: Uppercase hex character (00, F2, 97, B4, etc)

=item * L<Data::Maker::Field::Person::FirstName> - A built-in field class for generating (mostly Anglo) first (given) names.

=item * L<Data::Maker::Field::Person::MiddleName> - A built-in field class for generating middle I<initials> (I realize it's called MiddleName).  It should eventually be able to generate middle I<names> or I<initials>.

=item * L<Data::Maker::Field::Person::LastName> - A built-in field class for generating (mostly Anglo) surnames.

=item * L<Data::Maker::Field::Person::Gender> - Given a field that represents a given name, this class uses L<Text::GenderFromName> to guess the gender (currently returning only "M" or "F").  If it is not able to guess the gender, it returns "U" (unknown). 

=item * L<Data::Maker::Field::Person::SSN> - A simple example of class that can be added to meet your own needs.  This class uses L<Data::Maker::Field::Format> to create a formatted string of random digits.

=back 

=item B<record_count> (I<Num>)

The number of records desired

=item B<object_cache> (I<HashRef>)

Used internally by Data::Maker to ensure reuse of the field objects for each row.  This is important 
because certain objects have large data sets inside them.

=item B<data_sources> (I<HashRef>)

Used internally by Data::Maker.  It's a hashref to store open file handles.

=item B<record_counts> (I<HashRef>)

A hashref of record counts.  Not sure why this was used.  It's mentioned in
Data::Maker::Field::File 

=item B<delimiter>

The optional delimiter... could be anything.  Usually a comma, tab, pipe, etc

=item B<generated> (I<Num>)

Returns the number of records that have been generated so far.

=item B<seed> (I<Num>)

The optional random seed.  Provide a seed to ensure that the randomly-generated 
data comes out the same each time you run it.

=back

=head1 CONTRIBUTORS

Thanks to my employer, Informatics Corporation of America, for its commitment to Perl and to giving back to the Perl community.
Thanks to Mark Frost for the idea about optionally seeding the randomness to ensure the same output each time a program is run, if that's what you want to do.

=head1 AUTHOR

John Ingram (john@funnycow.com)

=head1 LICENSE

Copyright 2010 by John Ingram. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same terms
as Perl itself.
