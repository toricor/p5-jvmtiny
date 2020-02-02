package Opcode::Istore_0;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '3b';

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
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[0] = $value;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;