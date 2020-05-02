package Opcode::Istore;

use Mouse;
extends 'Opcode::Base';

sub opcode { '36' }
sub operand_count { 1 }

sub run {
    my ($self) = @_;

    my $index = $self->operands->[0];
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[hex($index)] = $value;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;