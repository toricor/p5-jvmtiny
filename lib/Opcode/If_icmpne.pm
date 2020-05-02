package Opcode::If_icmpne;
use warnings;
use strict;
use utf8;

use Mouse;
with 'Opcode::Role::Runnable';

our $opcode = 'a0';

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
    my $branchbyte2 = pop @{$self->operands};
    my $branchbyte1 = pop @{$self->operands};
    my $value2 = hex(pop @{$self->operand_stack});
    my $value1 = hex(pop @{$self->operand_stack});
    if ($value1 != $value2) {
        $self->current_control_code_index($self->current_control_opcode_index + $self->_branch_offset($branchbyte1, $branchbyte2));
    } else {
        $self->current_control_code_index(
            $self->current_control_opcode_index
            + $self->operand_count # XXX
            + 1
        );
    }
}

sub _branch_offset {
    my ($self, $branch_byte1, $branch_byte2) = @_;
    {
        no warnings 'pack';
        my $offset = unpack("c", pack("c", (hex($branch_byte1) << 8) | hex($branch_byte2)));
        return $offset;
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;