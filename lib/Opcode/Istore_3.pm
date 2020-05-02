package Opcode::Istore_3;

use Mouse;
extends 'Opcode::Base';

sub opcode { '3e' }
sub operand_count { 0 }

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