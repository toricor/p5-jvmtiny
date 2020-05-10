package JVM::Opcode::Istore_1;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '3c' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    my $value = pop @{$self->operand_stack};
    $self->local_variables->[1] = $value;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
