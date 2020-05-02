package Opcode::Base;
use warnings;
use strict;
use utf8;

use Mouse;
with 'Opcode::Role::OpcodeName';
with 'Opcode::Role::OperandCount';
with 'Opcode::Role::Runnable';

sub opcode {
    die 'override me';
}

sub operand_count {
    die 'override me';
}

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

has constant_pool_entries => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

sub run {
    die 'override me!';
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;