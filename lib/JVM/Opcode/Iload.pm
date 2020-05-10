package JVM::Opcode::Iload;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '1a' }
sub operand_count { 1 }

sub run {
    my ($self) = @_;

    my $index = $self->operands->[0];
    my $value = $self->local_variables->[hex($index)];
    push @{$self->operand_stack}, $value;

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
