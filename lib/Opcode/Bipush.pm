package Opcode::Bipush;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = '10';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef',
    default  => sub {[]}
);

has operand_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub run {
    my $self = shift;
    my $byte = $self->operands->[0];
    push @{$self->operand_stack}, hex($byte);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;