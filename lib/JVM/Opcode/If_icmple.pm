package JVM::Opcode::If_icmple;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { 'a4' }
sub operand_count { 2 }

sub run {
    my ($self) = @_;

    my $branchbyte2 = pop @{$self->operands};
    my $branchbyte1 = pop @{$self->operands};
    my $value2 = hex(pop @{$self->operand_stack});
    my $value1 = hex(pop @{$self->operand_stack});

    if ($value1 <= $value2) {
        $self->next_opcode_index($self->base_index + $self->_branch_offset($branchbyte1, $branchbyte2));
    } else {
        $self->next_opcode_index($self->base_index + $self->operand_count + 1);
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
