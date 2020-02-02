package Opcode::Ldc;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '12'; # 18 (0x12)

has operands => (
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
    my $index = $self->operands->[0];
    my $symbol_name_hash = $constant_pool_entries->[$index];

    my $string = $constant_pool_entries->[$symbol_name_hash->{string_index}]->{string};
    push @{$self->to_stack}, $string;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;