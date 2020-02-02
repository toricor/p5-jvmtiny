package Opcode::Iload;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '1a';

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
    my $index = $self->operands->[0];
    my $value = $self->local_variables->[hex($index)];
    push @{$self->operand_stack}, $value;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;