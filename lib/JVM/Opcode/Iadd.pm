package JVM::Opcode::Iadd;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '60' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    my $value1 = pop @{$self->operand_stack};
    my $value2 = pop @{$self->operand_stack};
    my $result = $value1 + $value2;
    push @{$self->operand_stack}, $result;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;