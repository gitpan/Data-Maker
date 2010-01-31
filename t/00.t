#!perl -w
use strict;
use warnings; 

use Test::Simple 'no_plan';

use Data::Maker;
use Data::Maker::Field::Person::FirstName;

ok(
  my $maker = new Data::Maker(
    seed => 37854,
    record_count => 10,
    delimiter => "\t",
    fields => [
      {
        name => 'firstname',
        class => 'Data::Maker::Field::Person::FirstName'
      }
    ]
  )
);

my $record = $maker->next_record;
#$record->firstname->value);
