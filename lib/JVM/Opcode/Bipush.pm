package JVM::Opcode::Bipush;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { '10' }
sub operand_count { 1 };

sub run {
    my $self = shift;

    my $byte = $self->operands->[0];
    push @{$self->operand_stack}, hex($byte);

    $self->next_opcode_index($self->base_index + $self->operand_count + 1);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
