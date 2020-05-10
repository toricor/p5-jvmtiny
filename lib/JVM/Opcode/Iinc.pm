package JVM::Opcode::Iinc;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '84' }
sub operand_count { 2 }

sub run {
    my ($self) = @_;

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
