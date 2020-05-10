package JVM::Opcode::Return;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { 'b1' }
sub operand_count { 0 }

sub run {
    my $self = shift;

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
    return;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
