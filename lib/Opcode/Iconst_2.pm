package Opcode::Iconst_2;

use Mouse;
extends 'Opcode::Base';

sub opcode { '05' }
sub operand_count { 0 }

sub run {
    my ($self, $constant_pool_entries) = @_;

    push @{$self->operand_stack}, 2;
    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;