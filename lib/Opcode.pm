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

# [qw/b2 00 02 12 03 .../];
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

# 0xb2
# https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.getstatic
sub getstatic {
    my ($self, $stream, $indexbyte1, $indexbyte2) = @_;
}


no Mouse;
__PACKAGE__->meta->make_immutable;

1;