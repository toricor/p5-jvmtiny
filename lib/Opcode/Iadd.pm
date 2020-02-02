package Opcode::Iadd;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '60';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef[Int]',
    default  => sub {[]}
);

has operand_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

has local_variables => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub run {
    my ($self, $constant_pool_entries) = @_;
    my $value1 = pop @{$self->operand_stack};
    my $value2 = pop @{$self->operand_stack};
    my $result = $value1 + $value2;
    push @{$self->operand_stack}, $result;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;