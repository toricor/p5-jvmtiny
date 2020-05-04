package JVM::Opcode::Iconst_m1;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '02' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    push @{$self->operand_stack}, -1;
    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;