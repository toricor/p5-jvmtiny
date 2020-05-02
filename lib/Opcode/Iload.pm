package Opcode::Iload;

use Mouse;
extends 'Opcode::Base';

sub opcode { '1a' }
sub operand_count { 1 }

sub run {
    my ($self, $constant_pool_entries) = @_;

    my $index = $self->operands->[0];
    my $value = $self->local_variables->[hex($index)];
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