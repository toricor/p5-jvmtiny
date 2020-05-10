package JVM::Opcode::Base;
use warnings;
use strict;
use utf8;

use Mouse;
with 'JVM::Opcode::Role::OpcodeName';
with 'JVM::Opcode::Role::OperandCount';
with 'JVM::Opcode::Role::Runnable';

use JVM::Util::MouseType qw/ArrayRef Int/;

sub opcode {
    die 'override me';
}

sub operand_count {
    die 'override me';
}

has operands => (
    is       => 'rw',
    isa      => ArrayRef,
);

has operand_stack => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has local_variables => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has next_opcode_index => (
    is       => 'rw',
    isa      => Int,
    default  => sub {1},
);

has base_index => (
    is       => 'rw',
    isa      => Int,
    required => 1,
);

has constant_pools => (
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
