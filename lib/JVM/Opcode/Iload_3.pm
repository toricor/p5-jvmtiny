package JVM::Opcode::Iload_3;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '1a' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    my $value = $self->local_variables->[3];
    push @{$self->operand_stack}, $value;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
