package JVM::Opcode::Istore_1;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '3c' }
sub operand_count { 0 }

sub run {
    my ($self) = @_;

    my $value = pop @{$self->operand_stack};
    $self->local_variables->[1] = $value;

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
