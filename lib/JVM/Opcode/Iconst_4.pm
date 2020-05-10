package JVM::Opcode::Iconst_4;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '07' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    push @{$self->operand_stack}, 4;
    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
