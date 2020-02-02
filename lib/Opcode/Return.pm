package Opcode::Return;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = 'b1';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef[Int]',
    default  => sub {[]}
);

has to_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    default  => sub {[]},
);

sub run {
    return;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;