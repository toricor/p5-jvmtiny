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

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
