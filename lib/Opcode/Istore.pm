package Opcode::Istore;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '36';

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
    my $index = $self->operands->[0];
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[hex($index)] = $value;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;