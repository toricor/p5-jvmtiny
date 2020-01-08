package Frame;
use Mouse;

use java::lang::System;
use feature qw/state/;

# constant pool
has constant_pool_entries => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

# binary
has raw_code => (
    is       => 'ro',
    isa      => 'Defined',
    required => 1,
);

# length(10)
has raw_code_length => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

# ex. [qw/b2 00 02 12 03 .../];
has _code_array => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    default  => sub {
        my $self = shift;
        my $len  = $self->raw_code_length;
        return [map {sprintf("%02x", $_)} unpack("C[$len]", $self->raw_code)];
    },
);

has _operand_stack => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]},
);

has _local_variables => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]},
);

has _current_control => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return +{
            code_index   => 0,    # current control index in code array
            opcode_index => 0,    # current opcode's index
            opcode       => '00', # current opcode
        };
    },
);

sub run {
    my $self = shift;

    my $current = $self->_current_control;

    my $code_array = $self->_code_array;
    while ($current->{code_index} < scalar(@$code_array)) {
        $current->{opcode_index} = int($current->{code_index});
        $current->{opcode}       = $code_array->[$current->{code_index}++];
        my $opcode = $current->{opcode};

        # getstatic
        if ($opcode eq 'b2') {
            my $indexbyte1 = $code_array->[$current->{code_index}++];
            my $indexbyte2 = $code_array->[$current->{code_index}++];
            $self->getstatic($indexbyte1, $indexbyte2);
        }
        # ldc
        elsif ($opcode eq '12') {
            my $index = $code_array->[$current->{code_index}++];
            $self->ldc($index);
        }
        # invokevirtual
        elsif ($opcode eq 'b6') {
            my $indexbyte1 = $code_array->[$current->{code_index}++];
            my $indexbyte2 = $code_array->[$current->{code_index}++];
            $self->invokevirtual($indexbyte1, $indexbyte2);
        }
        # return
        elsif ($opcode eq 'b1') {
            $self->return();
        }
        # iconst_m1
        elsif ($opcode eq '02') {
            $self->iconst_i($opcode);
        }
        # iconst_0
        elsif ($opcode eq '03') {
            $self->iconst_i($opcode);
        }
        # iconst_1
        elsif ($opcode eq '04') {
            $self->iconst_i($opcode);
        }
        # iconst_2
        elsif ($opcode eq '05') {
            $self->iconst_i($opcode);
        }
        # iconst_3
        elsif ($opcode eq '06') {
            $self->iconst_i($opcode);
        }
        # iconst_4
        elsif ($opcode eq '07') {
            $self->iconst_i($opcode);
        }
        # iconst_5
        elsif ($opcode eq '08') {
            $self->iconst_i($opcode);
        }
        # istore
        elsif ($opcode eq '36') {
            my $index = $code_array->[$current->{code_index}++];
            $self->istore($index);
        }
        # istore_0
        elsif ($opcode eq '3b') {
            $self->istore_n($opcode);
        }
        # istore_1
        elsif ($opcode eq '3c') {
            $self->istore_n($opcode);
        }
        # istore_2
        elsif ($opcode eq '3d') {
            $self->istore_n($opcode);
        }
        # istore_3
        elsif ($opcode eq '3e') {
            $self->istore_n($opcode);
        }
        # iload_0
        elsif ($opcode eq '1a') {
            $self->iload_n($opcode);
        }
        # iload_1
        elsif ($opcode eq '1b') {
            $self->iload_n($opcode);
        }
        # iload_2
        elsif ($opcode eq '1c') {
            $self->iload_n($opcode);
        }
        # iload_3
        elsif ($opcode eq '1d') {
            $self->iload_n($opcode);
        }
        # iadd
        elsif ($opcode eq '60') {
            $self->iadd();
        }
        # isub
        elsif ($opcode eq '64') {
            $self->isub();
        }
        # bipush
        elsif ($opcode eq '10') {
            my $byte = $code_array->[$current->{code_index}++];
            $self->bipush($byte);
        }
        # iload
        elsif ($opcode eq '15') {
            my $byte = $code_array->[$current->{code_index}++];
            $self->iload($byte);
        }
        # imul
        elsif ($opcode eq '68') {
            $self->imul();
        }
        # ineg
        elsif ($opcode eq '74') {
            $self->ineg();
        }
        # if_icmp<cond>
        elsif ($opcode eq 'a2') {
            my $branch_byte1 = $code_array->[$current->{code_index}++];
            my $branch_byte2 = $code_array->[$current->{code_index}++];
            $self->if_icmp($opcode, $branch_byte1, $branch_byte2);
        }
        # goto
        elsif ($opcode eq 'a7') {
            my $branch_byte1 = $code_array->[$current->{code_index}++];
            my $branch_byte2 = $code_array->[$current->{code_index}++];
            $self->goto($branch_byte1, $branch_byte2);
        }
        # iinc
        elsif ($opcode eq '84') {
            my $index = $code_array->[$current->{code_index}++];
            my $const = $code_array->[$current->{code_index}++];
            $self->iinc($index, $const);
        }
        # TODO
        else {
            die "opcode:$opcode has not implemented yet";
        }
    }
}


# 0xb2
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.getstatic
sub getstatic {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    my $constant_pool_entries = $self->constant_pool_entries;
    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash      = $constant_pool_entries->[$constant_pool_index];

    # java/lang/System
    my $callee_class = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{class_index}]->{name_index}]->{string};

    # out
    my $field = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{name_and_type_index}]->{name_index}]->{string};

    # out fieldの型情報(Ljava/io/PrintStream;)
    my $method_return = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{name_and_type_index}]->{descriptor_index}]->{string};

    $callee_class =~ s/\//::/g;

    push @{$self->_operand_stack}, +{
        callable => $callee_class->new()->$field,
        return   => $method_return,
    };

}

# 0x12
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.ldc
sub ldc {
    my ($self, $index) = @_;
     my $constant_pool_entries = $self->constant_pool_entries;

     my $symbol_name_hash = $constant_pool_entries->[$index];

     # Hello World !
     my $string = $constant_pool_entries->[$symbol_name_hash->{string_index}]->{string};
     push @{$self->_operand_stack}, $string;
}

# 0xb6
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokevirtual
sub invokevirtual {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    my $constant_pool_entries = $self->constant_pool_entries;
    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash = $constant_pool_entries->[$constant_pool_index];

    my $callee_info = $constant_pool_entries->[$symbol_name_hash->{name_and_type_index}];
    my $method_name = $constant_pool_entries->[$callee_info->{name_index}]->{string};

    my $argments_string = $constant_pool_entries->[$callee_info->{descriptor_index}]->{string};
    # TODO: https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.3
    my $argments_size = 1;#(() = $argments_string =~ m/;/g); # https://shogo82148.github.io/blog/2015/04/09/count-substrings-in-perl/
    #use DDP;
    #p $argments_string; # AddInt: "(I)V"; HelloWorld: "(Ljava/lang/String;)V";
 
    #p $argments_size;   # AddInt: 0
    my @argments;
    for (1..$argments_size) {
        push @argments, pop @{$self->_operand_stack}, # XXX: pop order (本当は逆からpopする必要がある) https://speakerdeck.com/memory1994/php-de-jvm-woshi-zhuang-site-hello-world-wochu-li-surumade?slide=150
    }

    my $method = pop @{$self->_operand_stack};
#se DDP;
#p $method;
    my $return = $method->{callable}->$method_name(@argments);
}

# 0xb1
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.return
sub return {
    my ($self) = @_;
    die 'return';
}

# 0x2 ~ 0x8
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.iconst_i
sub iconst_i {
    my ($self, $opcode) = @_;

    state $value_map; $value_map //= +{
        '02' => -1,
        '03' => 0,
        '04' => 1,
        '05' => 2,
        '06' => 3,
        '07' => 4,
        '08' => 5,
    };
    push @{$self->_operand_stack}, $value_map->{$opcode};
}

# 0x36
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.istore
sub istore {
    my ($self, $index) = @_;
    my $value = pop @{$self->_operand_stack};
    $self->_local_variables->[hex($index)] = $value;
}

# 0x3b ~ 0x3e
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.istore_n
sub istore_n {
    my ($self, $opcode) = @_;
    state $store_map; $store_map //= +{
        '3b' => 0,
        '3c' => 1,
        '3d' => 2,
        '3e' => 3,
    };
    my $value = pop @{$self->_operand_stack};
    my $index = $store_map->{$opcode};
    $self->_local_variables->[$index] = $value;
}

# 0x1a ~ 0x1d
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.iload_n
sub iload_n {
    my ($self, $opcode) = @_;
    state $load_map; $load_map //= +{
        '1a' => 0,
        '1b' => 1,
        '1c' => 2,
        '1d' => 3,
    };
    my $index = $load_map->{$opcode};
    my $value = $self->_local_variables->[$index];
    push @{$self->_operand_stack}, $value;
}

# 0x60
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.iadd
sub iadd {
    my ($self) = @_;

    my $value1 = pop @{$self->_operand_stack};
    my $value2 = pop @{$self->_operand_stack};
    my $result = $value1 + $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x64
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.isub
sub isub {
    my ($self) = @_;

    my $value2 = pop @{$self->_operand_stack};
    my $value1 = pop @{$self->_operand_stack};
    my $result = $value1 - $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x10
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.bipush
sub bipush {
    my ($self, $byte) = @_;
    push @{$self->_operand_stack}, hex($byte);
}

# 0x15
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.iload
sub iload {
    my ($self, $index) = @_;
    my $value = $self->_local_variables->[hex($index)];
    push @{$self->_operand_stack}, $value;
}

# 0x68
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.imul
sub imul {
    my ($self) = @_;

    my $value2 = pop @{$self->_operand_stack};
    my $value1 = pop @{$self->_operand_stack};
    my $result = $value1 * $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x74
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.ineg
sub ineg {
    my ($self) = @_;
    my $value = pop @{$self->_operand_stack};
    my $result = -1 * $value;
    push @{$self->_operand_stack}, $result;
}

# 0x9f, 0xa1 ~ 0xa4
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.if_icmp<cond>
sub if_icmp {
    my ($self, $opcode, $branch_byte1, $branch_byte2) = @_;
    my $value2 = hex(pop @{$self->_operand_stack});
    my $value1 = hex(pop @{$self->_operand_stack});
    $branch_byte1 = hex($branch_byte1);
    $branch_byte2 = hex($branch_byte2);

    my $target_index = 0;
    # if_icmpeq
    if ($opcode eq '9f') {
        if ($value1 == $value2) {
            
        }
    }
    # if_icmpne
    elsif ($opcode eq 'a0') {
        if ($value1 != $value2) {
        
        }
    }
    # if_icmplt
    elsif ($opcode eq 'a1') {
        if ($value1 < $value2) {

        }
    }
    # if_icmpge
    elsif ($opcode eq 'a2') {
        if ($value1 >= $value2) {
            $self->_current_control->{code_index} =
                $self->_current_control->{opcode_index} + $self->_branch_offset($branch_byte1, $branch_byte2);   
        }
    }
    # if_icmpgt
    elsif ($opcode eq 'a3') {
        if ($value1 > $value2) {
           
        }
    }
    # if_icmplt
    elsif ($opcode eq 'a4') {
        if ($value1 < $value2) {
            
        }
    }
}

# 0x84
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.iinc
sub iinc {
    my ($self, $index, $const) = @_;
    $self->_local_variables->[hex($index)] += $const;
}

# 0xa7
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.goto
sub goto {
    my ($self, $branch_byte1, $branch_byte2) = @_;

    $self->_current_control->{code_index} =
        $self->_current_control->{opcode_index} + $self->_branch_offset($branch_byte1, $branch_byte2);
}

# private
sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return (hex($indexbyte1) << 8) | hex($indexbyte2);
}

sub _branch_offset {
    my ($self, $branch_byte1, $branch_byte2) = @_;
    no warnings 'pack';
    my $offset = unpack("c", pack("c", (hex($branch_byte1) << 8) | hex($branch_byte2)));
    return $offset;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;