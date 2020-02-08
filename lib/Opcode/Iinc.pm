package Opcode::Iinc;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '84';

my $operand_count = 2;

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
    my $index = $self->operands->[0];
    my $const = $self->operands->[1];
    $self->local_variables->[hex($index)] += $const;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;