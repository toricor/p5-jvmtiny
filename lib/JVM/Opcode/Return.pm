package JVM::Opcode::Return;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { 'b1' }
sub operand_count { 0 }

sub run {
    my $self = shift;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
    return;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;