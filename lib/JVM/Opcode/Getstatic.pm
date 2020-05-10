package JVM::Opcode::Getstatic;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { 'b2' };
sub operand_count { 2 };

sub run {
    my ($self) = @_;
    my $constant_pools = $self->constant_pools;

    my $indexbyte1 = $self->operands->[0];
    my $indexbyte2 = $self->operands->[1];

    my $constant_pool_index = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash    = $constant_pools->[$constant_pool_index];

    # java/lang/System
    my $callee_class = $constant_pools->[$constant_pools->[$symbol_name_hash->{class_index}]->{name_index}]->{string};

    # out
    my $field = $constant_pools->[$constant_pools->[$symbol_name_hash->{name_and_type_index}]->{name_index}]->{string};

    # out fieldの型情報(Ljava/io/PrintStream;)
    my $method_return = $constant_pools->[$constant_pools->[$symbol_name_hash->{name_and_type_index}]->{descriptor_index}]->{string};

    $callee_class =~ s/\//::/g;

    push @{$self->operand_stack}, +{
        callable => $callee_class->new()->$field,
        return   => $method_return,
    };

    $self->current_control_code_index(
        $self->current_control_opcode_index
        + $self->operand_count # XXX
        + 1
    );
}

sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return (hex($indexbyte1) << 8) | hex($indexbyte2);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
