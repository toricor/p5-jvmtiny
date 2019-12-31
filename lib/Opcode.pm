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
}

# 0x12
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.ldc
sub ldc {
    my ($self) = @_;
}

# 0xb6
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokevirtual
sub invokevirtual {
    my ($self) = @_;
}

# 0xb1
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.return
sub return {
    my ($self) = @_;
    return;
}


no Mouse;
__PACKAGE__->meta->make_immutable;

1;