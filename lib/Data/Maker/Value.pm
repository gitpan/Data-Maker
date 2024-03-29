package Data::Maker::Value;
use strict;
use warnings;

our $VERSION = '0.01';

use overload '""' => 'value';

sub new {
  my ($class,$value) = @_;
  return bless \$value, $class;
}

sub value {
  return ${$_[0]};
}

1;

=head1 NAME

Data::Maker::Value - A value generated by a Data::Maker::Field

=head1 SYNOPSIS

  my $record = $maker->next_record;
  my $first_name = $record->{first_name};   # <=== A Data::Maker::Value object
  
  # automatic stringification
  print "First name: $first_name\n";
  
  # or, value() for backwards compatibility
  printf "First name: %s\n", $first_name->value;

=head1 DESCRIPTION

This is a lightweight wrapper for L<Data::Maker> field values that allows the Data::Maker internals to run a bit faster than they would without it, at the same time maintaining backward compatibility.

=head2 METHODS

=over 4

=item value

Returns the boxed value.

=back

=head1 AUTHOR

Philip Garrett (philip.garrett@icainformatics.com)

=head1 LICENSE

Copyright 2010 by Philip Garrett. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut