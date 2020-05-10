package JVM::Opcode::Bipush;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '10' }
sub operand_count { 1 };

sub run {
    my $self = shift;

    my $byte = $self->operands->[0];
    push @{$self->operand_stack}, hex($byte);

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
