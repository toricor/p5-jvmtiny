package Opcode::Istore_1;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '3c';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef[Int]',
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
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[1] = $value;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;