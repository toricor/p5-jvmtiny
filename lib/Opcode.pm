package Opcode;
use Mouse;

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
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub {
        my $self = shift;
        my $len  = $self->raw_code_length;
        return [map {sprintf("%02x", $_)} unpack("C[$len]", $self->raw_code)];
    },
);

has _operand_stack => (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub {[]},
);

sub run {
    my $self = shift;
    my @code_array = @{$self->_code_array};

    while (@code_array) {
        my $opcode = shift @code_array;

        # getstatic
        if ($opcode eq 'b2') {
            my $indexbyte1 = shift @code_array;
            my $indexbyte2 = shift @code_array;
            $self->getstatic($indexbyte1, $indexbyte2);
        }
        # ldc
        elsif ($opcode eq '12') {
            my $index = shift @code_array;
            $self->ldc($index);
        }
        # invokevirtual
        elsif ($opcode eq 'b6') {
            my $indexbyte1 = shift @code_array;
            my $indexbyte2 = shift @code_array;
            $self->invokevirtual($indexbyte1, $indexbyte2);
        }
        # return
        elsif ($opcode eq 'b1') {
            $self->return();
        }
        # TODO
        else {
            die 'not implemented yet';
        }
    }
}


# 0xb2
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.getstatic
sub getstatic {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    my $constant_pool_entries = $self->constant_pool_entries;
    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash      = $constant_pool_entries->[hex($constant_pool_index)];

    # java/lang/System
    my $callee_class = $constant_pool_entries->[hex($constant_pool_entries->[hex($symbol_name_hash->{class_index})]->{name_index})]->{string};

    # out
    my $field = $constant_pool_entries->[hex($constant_pool_entries->[hex($symbol_name_hash->{name_and_type_index})]->{name_index})]->{string};

    # out fieldの型情報(Ljava/io/PrintStream;)
    my $method_return = $constant_pool_entries->[hex($constant_pool_entries->[hex($symbol_name_hash->{name_and_type_index})]->{descriptor_index})]->{string};

    $callee_class =~ s/\//::/g;
use DDP;
p $callee_class;
    push @{$self->_operand_stack}, +{
        callable => +{}, #+{$callee_class->$field => 1},
        return   => $method_return,
    };

}

# 0x12
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.ldc
sub ldc {
    my ($self, $index) = @_;
     my $constant_pool_entries = $self->constant_pool_entries;

     my $symbol_name_hash = $constant_pool_entries->[hex($index)];

     # Hello World !
     my $string = $constant_pool_entries->[hex($symbol_name_hash->{string_index})]->{string};
     push @{$self->_operand_stack}, $string;
}

# 0xb6
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokevirtual
sub invokevirtual {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    my $constant_pool_entries = $self->constant_pool_entries;
    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash = $constant_pool_entries->[hex($constant_pool_index)];

    my $callee_info = $constant_pool_entries->[hex($symbol_name_hash->{name_and_type_index})];
    my $method_name = $constant_pool_entries->[hex($callee_info->{name_index})]->{string};

    my $argments_string = $constant_pool_entries->[hex($callee_info->{descriptor_index})]->{string};
    my $argments_size = (() = $argments_string =~ m/;/g); # https://shogo82148.github.io/blog/2015/04/09/count-substrings-in-perl/
    
    my @argments;
    for (1..$argments_size) {
        push @argments, pop @{$self->_operand_stack}, # XXX: pop order (本当は逆からpopする必要がある) https://speakerdeck.com/memory1994/php-de-jvm-woshi-zhuang-site-hello-world-wochu-li-surumade?slide=150
    }
    my $method = pop @{$self->_operand_stack};
    
}

# 0xb1
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.return
sub return {
    my ($self) = @_;
    return;
}

# private
sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return int($indexbyte1.$indexbyte2); # XXX:FIXME
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;