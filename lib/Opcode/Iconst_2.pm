package Opcode::Iconst_2;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '05';

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
    push @{$self->operand_stack}, 2;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;