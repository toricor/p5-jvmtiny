package JVM::Opcode::Istore;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '36' }
sub operand_count { 1 }

sub run {
    my ($self) = @_;

    my $index = $self->operands->[0];
    my $value = pop @{$self->operand_stack};
    $self->local_variables->[hex($index)] = $value;

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
