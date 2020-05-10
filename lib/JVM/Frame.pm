package JVM::Frame;
use warnings;
use strict;
use utf8;

use Mouse;
use Mouse::Util;

use JVM::Util::MouseType qw/ArrayRef HashRef UInt/;

use java::lang::System;

has frame_stack => (
    is  => 'ro',
    isa => 'Defined',
);

# constant pool
has constant_pools => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

# ex. [qw/b2 00 02 12 03 .../];
has code_array => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub {[]},
);

# ex. ['JVM::Opcode::GetStatic', ...]
has opcode_modules => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has _opcode_to_opcode_module => (
    is       => 'ro',
    isa      => HashRef,
    lazy     => 1,
    builder  => sub {
        my $self = shift;
        my %opcode_to_opcode_module;
        for my $module_name (@{$self->opcode_modules}) {
            $opcode_to_opcode_module{$module_name->opcode()} = $module_name;
        }
        return \%opcode_to_opcode_module;
    },
);

has operand_stack => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub {[]},
);

has local_variables => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub {[]},
);

# current control index in code array
has code_index => (
    is      => 'rw',
    isa     => UInt,
    default => sub {0},
);

# current opcode's index
has opcode_index => (
    is      => 'rw',
    isa     => UInt,
    default => sub {0},
);

sub run {
    my $self = shift;

    while ($self->opcode_index < scalar(@{$self->code_array})) {
        my $opcode      = $self->code_array->[$self->opcode_index];   # ex. b6
        my $module_name = $self->_opcode_to_opcode_module->{$opcode}; # ex. +{ b6 => JVM::Opcode::GetStatic, ... }
        die "opcode: $opcode is not implemented" unless $module_name;

        my @operands;
        for (1..$module_name->operand_count()) {
            push @operands, $self->code_array->[$_+$self->opcode_index];
        }

        my $entity = $module_name->new(
            constant_pools  => $self->constant_pools,
            operands        => \@operands,
            operand_stack   => $self->operand_stack,
            local_variables => $self->local_variables,
            base_index      => $self->opcode_index,
        );

        $entity->run($self->frame_stack);

        $self->opcode_index($entity->next_opcode_index);
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
