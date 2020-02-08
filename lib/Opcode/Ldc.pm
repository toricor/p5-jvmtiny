package Opcode::Ldc;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '12';

my $operand_count = 1;

has operand_count => (
    is      => 'ro',
    isa     => 'Int',
    default => sub {$operand_count},
);

has operands => (
    is       => 'rw',
    isa      => 'ArrayRef',
);

has operand_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    default  => sub {[]},
);

has current_control_code_index => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has current_control_opcode_index => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

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