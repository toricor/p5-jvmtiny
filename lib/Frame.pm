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

my $opcode_config = +{
    '02' => +{ name => 'iconst_m1',     operand_count => 0 },
    '03' => +{ name => 'iconst_0',      operand_count => 0 },
    '04' => +{ name => 'iconst_1',      operand_count => 0 },
    '05' => +{ name => 'iconst_2',      operand_count => 0 },
    '06' => +{ name => 'iconst_3',      operand_count => 0 },
    '07' => +{ name => 'iconst_4',      operand_count => 0 },
    '08' => +{ name => 'iconst_5',      operand_count => 0 },
    '10' => +{ name => 'bipush',        operand_count => 1 },
    '12' => +{ name => 'ldc',           operand_count => 1 },
    '15' => +{ name => 'iload',         operand_count => 1 },
    '1a' => +{ name => 'iload_0',       operand_count => 0 },
    '1b' => +{ name => 'iload_1',       operand_count => 0 },
    '1c' => +{ name => 'iload_2',       operand_count => 0 },
    '1d' => +{ name => 'iload_3',       operand_count => 0 },
    '36' => +{ name => 'istore',        operand_count => 1 },
    '3b' => +{ name => 'istore_0',      operand_count => 0 },
    '3c' => +{ name => 'istore_1',      operand_count => 0 },
    '3d' => +{ name => 'istore_2',      operand_count => 0 },
    '3e' => +{ name => 'istore_3',      operand_count => 0 },
    '60' => +{ name => 'iadd',          operand_count => 0 },
    '64' => +{ name => 'isub',          operand_count => 0 },
    '68' => +{ name => 'imul',          operand_count => 0 },
    '70' => +{ name => 'irem',          operand_count => 0 },
    '74' => +{ name => 'ineg',          operand_count => 0 },
    '84' => +{ name => 'iinc',          operand_count => 2 },
    '99' => +{ name => 'ifeq',          operand_count => 2 },
    '9a' => +{ name => 'ifne',          operand_count => 2 },
    '9b' => +{ name => 'iflt',          operand_count => 2 },
    '9c' => +{ name => 'ifge',          operand_count => 2 },
    '9d' => +{ name => 'ifgt',          operand_count => 2 },
    '9e' => +{ name => 'ifle',          operand_count => 2 },
    '9f' => +{ name => 'if_icmpeq',     operand_count => 2 },
    'a0' => +{ name => 'if_icmpne',     operand_count => 2 },
    'a1' => +{ name => 'if_icmplt',     operand_count => 2 },
    'a2' => +{ name => 'if_icmpge',     operand_count => 2 },
    'a3' => +{ name => 'if_icmpgt',     operand_count => 2 },
    'a4' => +{ name => 'if_icmple',     operand_count => 2 },
    'a7' => +{ name => 'goto',          operand_count => 2 },
    'b1' => +{ name => 'return',        operand_count => 0 },
    'b2' => +{ name => 'getstatic',     operand_count => 2 },
    'b6' => +{ name => 'invokevirtual', operand_count => 2 },
};

# opcode名がメソッド名ではないもの
my $opcode_to_special_method = +{
    '02' => 'iconst_i',
    '03' => 'iconst_i',
    '04' => 'iconst_i',
    '05' => 'iconst_i',
    '06' => 'iconst_i',
    '07' => 'iconst_i',
    '08' => 'iconst_i',

    '1a' => 'iload_n',
    '1b' => 'iload_n',
    '1c' => 'iload_n',
    '1d' => 'iload_n', 

    '99' => 'if',
    '9a' => 'if',
    '9b' => 'if',
    '9c' => 'if',
    '9d' => 'if',
    '9e' => 'if',

    '9f' => 'if_icmp',
    'a0' => 'if_icmp',
    'a1' => 'if_icmp',
    'a2' => 'if_icmp',
    'a3' => 'if_icmp',
    'a4' => 'if_icmp',

    '3b' => 'istore_n',
    '3c' => 'istore_n',
    '3d' => 'istore_n',
    '3e' => 'istore_n',
};


sub run {
    my $self = shift;

    my $current = $self->_current_control;

    my $code_array = $self->_code_array;
    while ($current->{code_index} < scalar(@$code_array)) {
        $current->{opcode_index} = int($current->{code_index});
        $current->{opcode}       = $code_array->[$current->{code_index}++];

        my $opcode = $current->{opcode};
 
        if ($opcode eq 'aa' || $opcode eq 'ab') { # has padding
            die "opcode: $opcode is unimplemented";
        }
        else {
            my $operand_count = $opcode_config->{$opcode}->{operand_count};
            my $opcode_name   = $opcode_config->{$opcode}->{name};

            die "opcode: $opcode is unimplemented" unless $opcode_name;

            my @args;
            for (1..$operand_count) {
                my $arg = $code_array->[$current->{code_index}++];
                push @args, $arg;
            }
            my $method = $opcode_to_special_method->{$opcode} // $opcode_name; 
            $self->$method($opcode, @args);
        }
    }
}


# 0xb2
sub getstatic {
    my ($self, $opcode, $indexbyte1, $indexbyte2) = @_;
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
sub ldc {
    my ($self, $opcode, $index) = @_;
     my $constant_pool_entries = $self->constant_pool_entries;

     my $symbol_name_hash = $constant_pool_entries->[$index];

     my $string = $constant_pool_entries->[$symbol_name_hash->{string_index}]->{string};
     push @{$self->_operand_stack}, $string;
}

# 0xb6
sub invokevirtual {
    my ($self, $opcode, $indexbyte1, $indexbyte2) = @_;
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
#use DDP;
#p $method;
    my $return = $method->{callable}->$method_name(@argments);
}

# 0xb1
sub return {
    my ($self) = @_;
    #die 'return';
}

# 0x2 ~ 0x8
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
sub istore {
    my ($self, $opcode, $index) = @_;
    my $value = pop @{$self->_operand_stack};
    $self->_local_variables->[hex($index)] = $value;
}

# 0x3b ~ 0x3e
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
sub iadd {
    my ($self) = @_;

    my $value1 = pop @{$self->_operand_stack};
    my $value2 = pop @{$self->_operand_stack};
    my $result = $value1 + $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x64
sub isub {
    my ($self) = @_;

    my $value2 = pop @{$self->_operand_stack};
    my $value1 = pop @{$self->_operand_stack};
    my $result = $value1 - $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x10
sub bipush {
    my ($self, $opcode, $byte) = @_;
    push @{$self->_operand_stack}, hex($byte);
}

# 0x15
sub iload {
    my ($self, $opcode, $index) = @_;
    my $value = $self->_local_variables->[hex($index)];
    push @{$self->_operand_stack}, $value;
}

# 0x68
sub imul {
    my ($self) = @_;

    my $value2 = pop @{$self->_operand_stack};
    my $value1 = pop @{$self->_operand_stack};
    my $result = $value1 * $value2;
    push @{$self->_operand_stack}, $result;
}

# 0x74
sub ineg {
    my ($self) = @_;
    my $value = pop @{$self->_operand_stack};
    my $result = -1 * $value;
    push @{$self->_operand_stack}, $result;
}

# 0x9f, 0xa1 ~ 0xa4
sub if_icmp {
    my ($self, $opcode, $branch_byte1, $branch_byte2) = @_;
    my $value2 = hex(pop @{$self->_operand_stack});
    my $value1 = hex(pop @{$self->_operand_stack});

    my $target_index = 0;
    # if_icmpeq
    if ($opcode eq '9f') {
        return unless ($value1 == $value2);
    }
    # if_icmpne
    elsif ($opcode eq 'a0') {
        return unless ($value1 != $value2);
    }
    # if_icmplt
    elsif ($opcode eq 'a1') {
        return unless ($value1 < $value2);
    }
    # if_icmpge
    elsif ($opcode eq 'a2') {
        return unless ($value1 >= $value2);
    }
    # if_icmpgt
    elsif ($opcode eq 'a3') {
        return unless ($value1 > $value2);
    }
    # if_icmplt
    elsif ($opcode eq 'a4') {
        return unless ($value1 < $value2);
    }
    else {
        die 'something wrong';
    }
    $self->_current_control->{code_index} =
        $self->_current_control->{opcode_index} + $self->_branch_offset($branch_byte1, $branch_byte2);
}

# 0x99 ~ 0x9e
sub if {
    my ($self, $opcode, $branch_byte1, $branch_byte2) = @_;
    my $value = hex(pop @{$self->_operand_stack});

    my $target_index = 0;
    # ifeq
    if ($opcode eq '99') {
        return unless ($value == 0);
    }
    # ifne
    elsif ($opcode eq '9a') {
        return unless ($value != 0);
    }
    # iflt
    elsif ($opcode eq '9b') {
        return unless ($value < 0);
    }
    # ifge
    elsif ($opcode eq '9c') {
        return unless ($value >= 0);
    }
    # ifgt
    elsif ($opcode eq '9d') {
        return unless ($value > 0);
    }
    # iflt
    elsif ($opcode eq '9e') {
        return unless ($value < 0);
    }
    else {
        die 'something wrong';
    }
    $self->_current_control->{code_index} =
        $self->_current_control->{opcode_index} + $self->_branch_offset($branch_byte1, $branch_byte2);
}

# 0x84
sub iinc {
    my ($self, $opcode, $index, $const) = @_;
    $self->_local_variables->[hex($index)] += $const;
}

# 0xa7
sub goto {
    my ($self, $opcode, $branch_byte1, $branch_byte2) = @_;

    $self->_current_control->{code_index} =
        $self->_current_control->{opcode_index} + $self->_branch_offset($branch_byte1, $branch_byte2);
}

# 0x70
sub irem {
    my ($self, $opcode) = @_;
    my $value2 = pop @{$self->_operand_stack};
    my $value1 = pop @{$self->_operand_stack};
    my $result = $value1 % $value2;
    push @{$self->_operand_stack}, $result;
}


#
#
# private
sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return (hex($indexbyte1) << 8) | hex($indexbyte2);
}

sub _branch_offset {
    my ($self, $branch_byte1, $branch_byte2) = @_;
    {
        no warnings 'pack';
        my $offset = unpack("c", pack("c", (hex($branch_byte1) << 8) | hex($branch_byte2)));
        return $offset;
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;