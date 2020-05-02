package Opcode::Istore_3;
use warnings;
use strict;
use utf8;

use Mouse;
with 'Opcode::Role::Runnable';

our $opcode = '3e';

my $operand_count = 0;

has operand_count => (
    is      => 'ro',
    isa     => 'Int',
    default => sub {$operand_count},
);

has operands => (
    is       => 'rw',
    isa      => 'ArrayRef',
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

has current_control_code_index => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has current_control_opcode_index => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

sub run {
    my ($self, $constant_pool_entries) = @_;
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[3] = $value;
    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;