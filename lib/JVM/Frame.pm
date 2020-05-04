package JVM::Frame;
use warnings;
use strict;
use utf8;

use Mouse;
use Mouse::Util;

use java::lang::System;

# constant pool
has constant_pool_entries => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

# ex. [qw/b2 00 02 12 03 .../];
has code_array => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

# ex. ['JVM::Opcode::GetStatic', ...]
has opcode_modules => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has _opcode_to_opcode_module => (
    is       => 'ro',
    isa      => 'HashRef',
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
    isa     => 'ArrayRef',
    default => sub {[]},
);

has local_variables => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]},
);

has _current_control => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return +{
            code_index   => 0,    # current control index in code array
            opcode_index => 0,    # current opcode's index
            opcode       => '00', # current opcode
        };
    },
);

sub run {
    my $self = shift;

    my $current = $self->_current_control;
    my $code_array = $self->code_array;

    while ($current->{code_index} < scalar(@$code_array)) {
        $current->{opcode_index} = int($current->{code_index});
        $current->{opcode}       = $code_array->[$current->{code_index}++];

        my $opcode      = $current->{opcode}; # ex. b6
        my $module_name = $self->_opcode_to_opcode_module->{$opcode}; # ex. +{ b6 => JVM::Opcode::GetStatic, ... }
        die "opcode: $opcode is unimplemented" unless $module_name;

        my $before_current_control_code_index   = $self->_current_control->{code_index};
        my $before_current_control_opcode_index = $self->_current_control->{opcode_index};

        my @operands;
        for (1..$module_name->operand_count()) {
            push @operands, $code_array->[$current->{code_index}++];
        }

        my $entity = $module_name->new(
            constant_pool_entries        => $self->constant_pool_entries,
            operands                     => \@operands,
            operand_stack                => $self->operand_stack,
            local_variables              => $self->local_variables,
            current_control_code_index   => $before_current_control_code_index,
            current_control_opcode_index => $before_current_control_opcode_index,
        );

        $entity->run();

        $self->operand_stack($entity->operand_stack);
        $self->local_variables($entity->local_variables);
 
        $self->_current_control->{code_index} = $entity->current_control_code_index;
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;