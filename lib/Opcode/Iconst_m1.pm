package Opcode::Iconst_m1;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '02';

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

has local_variables => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub run {
    my ($self, $constant_pool_entries) = @_;
    push @{$self->operand_stack}, -1;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;