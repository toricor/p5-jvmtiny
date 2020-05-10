package JVM::Opcode::Invokevirtual;

use Mouse;
extends 'JVM::Opcode::Base';

sub opcode { 'b6' }
sub operand_count { 2 }

sub run {
    my ($self) = @_;
    my $constant_pools = $self->constant_pools;

    my $indexbyte1 = $self->operands->[0];
    my $indexbyte2 = $self->operands->[1];

    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash = $constant_pools->[$constant_pool_index];

    my $callee_info = $constant_pools->[$symbol_name_hash->{name_and_type_index}];
    my $method_name = $constant_pools->[$callee_info->{name_index}]->{string};

    my $argments_string = $constant_pools->[$callee_info->{descriptor_index}]->{string};
    # TODO: https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.3
    my $argments_size = 1; # XXX
    #use DDP;
    #p $argments_string; # AddInt: "(I)V"; HelloWorld: "(Ljava/lang/String;)V";
    my @argments;
    for (1..$argments_size) {
        push @argments, pop @{$self->operand_stack};
    }

    my $method = pop @{$self->operand_stack};

    my $return = $method->{callable}->$method_name(@argments);

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
