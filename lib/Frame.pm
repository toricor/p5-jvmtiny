package Frame;
use Mouse;
use Mouse::Util;

use java::lang::System;
use feature qw/state/;

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
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    default  => sub {
        my $self = shift;
        my $len  = $self->raw_code_length;
        return [map {sprintf("%02x", $_)} unpack("C[$len]", $self->raw_code)];
    },
);

has _operand_stack => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]},
);

has _local_variables => (
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

my $opcode_config = +{
    '02' => +{ name => 'iconst_m1',     operand_count => 0 },
    '03' => +{ name => 'iconst_0',      operand_count => 0 },
    '04' => +{ name => 'iconst_1',      operand_count => 0 },
    '05' => +{ name => 'iconst_2',      operand_count => 0 },
    '06' => +{ name => 'iconst_3',      operand_count => 0 },
    '07' => +{ name => 'iconst_4',      operand_count => 0 },
    '08' => +{ name => 'iconst_5',      operand_count => 0 },
    '10' => +{ name => 'bipush',        operand_count => 1 },
    '12' => +{ name => 'ldc',           operand_count => 1 },
    '15' => +{ name => 'iload',         operand_count => 1 },
    '1a' => +{ name => 'iload_0',       operand_count => 0 },
    '1b' => +{ name => 'iload_1',       operand_count => 0 },
    '1c' => +{ name => 'iload_2',       operand_count => 0 },
    '1d' => +{ name => 'iload_3',       operand_count => 0 },
    '36' => +{ name => 'istore',        operand_count => 1 },
    '3b' => +{ name => 'istore_0',      operand_count => 0 },
    '3c' => +{ name => 'istore_1',      operand_count => 0 },
    '3d' => +{ name => 'istore_2',      operand_count => 0 },
    '3e' => +{ name => 'istore_3',      operand_count => 0 },
    '60' => +{ name => 'iadd',          operand_count => 0 },
    '64' => +{ name => 'isub',          operand_count => 0 },
    '68' => +{ name => 'imul',          operand_count => 0 },
    '70' => +{ name => 'irem',          operand_count => 0 },
    '74' => +{ name => 'ineg',          operand_count => 0 },
    '84' => +{ name => 'iinc',          operand_count => 2 },
    '99' => +{ name => 'ifeq',          operand_count => 2 },
    '9a' => +{ name => 'ifne',          operand_count => 2 },
    '9b' => +{ name => 'iflt',          operand_count => 2 },
    '9c' => +{ name => 'ifge',          operand_count => 2 },
    '9d' => +{ name => 'ifgt',          operand_count => 2 },
    '9e' => +{ name => 'ifle',          operand_count => 2 },
    '9f' => +{ name => 'if_icmpeq',     operand_count => 2 },
    'a0' => +{ name => 'if_icmpne',     operand_count => 2 },
    'a1' => +{ name => 'if_icmplt',     operand_count => 2 },
    'a2' => +{ name => 'if_icmpge',     operand_count => 2 },
    'a3' => +{ name => 'if_icmpgt',     operand_count => 2 },
    'a4' => +{ name => 'if_icmple',     operand_count => 2 },
    'a7' => +{ name => 'goto',          operand_count => 2 },
    'b1' => +{ name => 'return',        operand_count => 0 },
    'b2' => +{ name => 'getstatic',     operand_count => 2 },
    'b6' => +{ name => 'invokevirtual', operand_count => 2 },
};

# jump opcodes
my $jump_opcodes = [qw/
    if_icmpeq
    if_icmpne
    if_icmplt
    if_icmpge
    if_icmpgt
    if_icmple
    ifeq
    ifne
    iflt
    ifge
    ifgt
    ifle
    goto
/];

my $jump_opcode_exists = +{map {$_ => 1} @$jump_opcodes};

sub run {
    my $self = shift;

    my $current = $self->_current_control;

    my $code_array = $self->_code_array;
    while ($current->{code_index} < scalar(@$code_array)) {
        $current->{opcode_index} = int($current->{code_index});
        $current->{opcode}       = $code_array->[$current->{code_index}++];

        my $opcode = $current->{opcode};
        my $operand_count = $opcode_config->{$opcode}->{operand_count};
        my $opcode_name   = $opcode_config->{$opcode}->{name};
        my $module_name   = Mouse::Util::load_class("Opcode::".ucfirst($opcode_name));

        die "opcode: $opcode is unimplemented" unless $opcode_name;

        my @args;
        for (1..$operand_count) {
            my $arg = $code_array->[$current->{code_index}++];
            push @args, $arg;
        }
        my $entity = $module_name->new(
            operands        => \@args,
            operand_stack   => $self->_operand_stack,
            local_variables => $self->_local_variables,
            $jump_opcode_exists->{$opcode_name} ? (current_control_code_index => $self->_current_control->{code_index}) : (),
            $jump_opcode_exists->{$opcode_name} ? (current_control_opcode_index => $self->_current_control->{opcode_index}) : (),
        );
        $entity->run($self->constant_pool_entries);
        $self->_operand_stack($entity->operand_stack);
        $self->_local_variables($entity->local_variables) if $entity->can('local_variables');
        $self->_current_control->{code_index} = $entity->current_control_code_index if $jump_opcode_exists->{$opcode_name};    
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;