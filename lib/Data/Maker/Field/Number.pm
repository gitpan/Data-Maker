package Data::Maker::Field::Number;
use Data::Maker::Field::Format;
use Moose;
use MooseX::Aliases;
with 'Data::Maker::Field';
use Data::Dumper;

our $VERSION = '0.20';

has int_digits_between => ( is => 'rw', isa => 'ArrayRef');
has thousands_separator => ( is => 'rw', default => ',');
has decimal_separator => ( is => 'rw', default => '.');
has separate_thousands => ( is => 'rw', isa => 'Bool', default => 0, alias => 'commafy');
has min => ( is => 'rw', isa => 'Num');
has max => ( is => 'rw', isa => 'Num');
has precision => ( is => 'rw', isa => 'Num', default => 0);
has fixed_precision => ( is => 'rw', isa => 'Bool', default => 0);
has static_decimal => ( is => 'rw', isa => 'Num', default => 0);

has integer => ( is => 'rw', isa => 'Num');

# force the integer to be a well-behaved number... for example
before integer => sub { 
  my $this = shift;
  if ($_[0]) {
    $_[0] = sprintf("%d", $_[0]);
  }
};

has decimal => ( is => 'rw');
before decimal => sub {
  my $this = shift;
  unless($this->fixed_precision) {
    if ($_[0]) {
      # get rid of trailing zeroes 
      $_[0] =~ s/0+$//;
    }
  }
};

sub generate_value {
  my $this = shift;
  $this->generate_integer; 
  $this->generate_decimal;
  return $this->format;
}

sub generate_integer {
  my $this = shift;
  if ($this->int_digits_between) {
    my $int_format = '\d' x Data::Maker->random( @{$this->int_digits_between} );
    $this->integer(Data::Maker::Field::Format->new(format => $int_format )->generate_value);
  } elsif (defined($this->min) && defined($this->max)) {
    my $format = '%.' . $this->precision . 'f';
    $this->integer( sprintf("$format", $this->min + rand($this->max - $this->min)));
  } else {
    die "Not enough arguments for " . ref($this);
  }
}

sub generate_decimal {
  my $this = shift;
  if (my $value = $this->static_decimal) {
    $this->decimal($value);
    return;
  }
  if ($this->precision) {
    my $precision_format;
    if ($this->fixed_precision) {
      $precision_format = '\d' x $this->precision; 
    } else {
      $precision_format = '\d' x Data::Maker->random(1..$this->precision);
    }
    $this->decimal(Data::Maker::Field::Format->new(format => $precision_format)->generate_value);
  } 
}

sub format {
  my $this = shift;
  if ($this->commafy) {
    return join($this->decimal_separator, $this->commafied, $this->decimal || ());
  } else {
    return join($this->decimal_separator, $this->integer, $this->decimal || ());
  }
}

sub commafied {
  my $this = shift;
  my $input = $this->integer;
  $input = reverse $input;
  my $sep = $this->thousands_separator;
  $input =~ s<(\d\d\d)(?=\d)(?!\d*\.)><$1$sep>g;
  $input = reverse $input;
  return $input;
}

1;

__END__

=head1 NAME 

Data::Maker::Field::Number - A L<Data::Maker> field class used for generating numeric data.

=head1 SYNOPSIS

  use Data::Maker;
  use Data::Maker::Field::Number;

  my $maker = Data::Maker->new(
    record_count => 10,
    fields => [
      {
        name => 'population',
        class => 'Data::Maker::Field::Number',
        args => {
          min => 5000,
          max => 5000000
        }
      }
    ]
  );

=head1 DESCRIPTION 

Data::Maker::Field::Number supports the following L<Moose> attributes:

=over 4

=item * B<int_digits_between> (I<ArrayRef>)

This badly-named attribute defines a range of digit lengths that you want to
integer portion of the generated number to fall between.  For example, if you
want a 3-6 digit number, you can set this to C<[3..6]>

=item * B<thousands_separator> (I<Str>)

The string used to separate the thousands of the integer portion of the 
generated number.  Defaults to ','

=item * B<decimal_separator> (I<Str>)

The string used to separate the integer portion from the decimal portion
of the generated number.  Defaults to '.'

=item * B<separate_thousands> (I<Bool>)

If set to a true value, the thousands of the integer portion of the generated number
will be separated by the string defined by the I<thousands_separator> attribute. Defaults to 0.

=item * B<min> (I<Num>)

The minimum number that is to be generated

=item * B<max> (I<Num>)

The maximum number that is to be generated

=item * B<precision> (I<Num>)

The maximum number of places to which the decimal portion of the number should be generated.
To ensure that the precision is I<always> the same length, set I<fixed_precision> to a true value.

=item * B<fixed_precision> (I<Bool>)

This attribute causes the decimal portion of the number to always be the length defined by the 
I<precision> attribute, even if it ends in zeros (which are usually removed).  Defaults to 0.

=item * B<static_decimal> (I<Num>)

If this attribute is defined, the decimal portion of the number is always given that value.  
For example, if you want random prices that all end with 99 cents, you could set this attribute to .99

=item * B<integer> (I<Num>)

This method gets and sets the integer portion of the number.

=item * B<decimal> (I<Num>)

This method gets and sets the decimal portion of the number.

=back

=head1 AUTHOR

John Ingram (john@funnycow.com)

=head1 LICENSE

Copyright 2010 by John Ingram. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same terms
as Perl itself.
