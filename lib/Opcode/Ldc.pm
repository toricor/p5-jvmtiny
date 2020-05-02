package Opcode::Ldc;

use Mouse;
extends 'Opcode::Base';

sub opcode { '12' }
sub operand_count { 1 }

sub run {
    my ($self, $constant_pool_entries) = @_;

    my $index = $self->operands->[0];
    my $symbol_name_hash = $constant_pool_entries->[$index];

    my $string = $constant_pool_entries->[$symbol_name_hash->{string_index}]->{string};
    push @{$self->operand_stack}, $string;

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;