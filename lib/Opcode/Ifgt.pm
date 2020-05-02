package Opcode::Ifgt;

use Mouse;
extends 'Opcode::Base';

sub opcode { '9d' }
sub operand_count { 2 }

sub run {
    my ($self, $constant_pool_entries) = @_;

    my $branchbyte2 = pop @{$self->operands};
    my $branchbyte1 = pop @{$self->operands};
    my $value = hex(pop @{$self->operand_stack});

    if ($value > 0) {
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