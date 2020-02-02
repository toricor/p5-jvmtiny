package Opcode::Getstatic;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = 'b2';

has from_stack => (
    is       => 'ro',
    isa      => 'ArrayRef[Int]',
    default  => sub {[]}
);

has to_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    default  => sub {[]},
);

sub run {
    my ($self, $constant_pool_entries) = @_;

    my $indexbyte1 = $self->from_stack->[0];
    my $indexbyte2 = $self->from_stack->[1];

    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash      = $constant_pool_entries->[$constant_pool_index];

    # java/lang/System
    my $callee_class = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{class_index}]->{name_index}]->{string};

    # out
    my $field = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{name_and_type_index}]->{name_index}]->{string};

    # out fieldの型情報(Ljava/io/PrintStream;)
    my $method_return = $constant_pool_entries->[$constant_pool_entries->[$symbol_name_hash->{name_and_type_index}]->{descriptor_index}]->{string};

    $callee_class =~ s/\//::/g;

    push @{$self->to_stack}, +{
        callable => $callee_class->new()->$field,
        return   => $method_return,
    };
    return $self->to_stack;
}

sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return (hex($indexbyte1) << 8) | hex($indexbyte2);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;