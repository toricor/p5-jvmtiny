package Opcode::Iconst_1;

use Mouse;
extends 'Opcode::Base';

sub opcode { '04' }
sub operand_count { 0 }

sub run {
    my ($self, $constant_pool_entries) = @_;

    push @{$self->operand_stack}, 1;
    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;