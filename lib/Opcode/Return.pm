package Opcode::Return;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = 'b1';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef',
    default  => sub {[]}
);

has operand_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub run {
    return;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;