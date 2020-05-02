package Frame;
use Mouse;
use Mouse::Util;

use java::lang::System;

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
    '02' => +{ name => 'iconst_m1',  },
    '03' => +{ name => 'iconst_0',   },
    '04' => +{ name => 'iconst_1',   },
    '05' => +{ name => 'iconst_2',   },
    '06' => +{ name => 'iconst_3',   },
    '07' => +{ name => 'iconst_4',   },
    '08' => +{ name => 'iconst_5',   },
    '10' => +{ name => 'bipush',     },
    '12' => +{ name => 'ldc',        },
    '15' => +{ name => 'iload',      },
    '1a' => +{ name => 'iload_0',    },
    '1b' => +{ name => 'iload_1',    },
    '1c' => +{ name => 'iload_2',    },
    '1d' => +{ name => 'iload_3',    },
    '36' => +{ name => 'istore',     },
    '3b' => +{ name => 'istore_0',   },
    '3c' => +{ name => 'istore_1',   },
    '3d' => +{ name => 'istore_2',   },
    '3e' => +{ name => 'istore_3',   },
    '60' => +{ name => 'iadd',       },
    '64' => +{ name => 'isub',       },
    '68' => +{ name => 'imul',       },
    '70' => +{ name => 'irem',       },
    '74' => +{ name => 'ineg',       },
    '84' => +{ name => 'iinc',       },
    '99' => +{ name => 'ifeq',       },
    '9a' => +{ name => 'ifne',       },
    '9b' => +{ name => 'iflt',       },
    '9c' => +{ name => 'ifge',       },
    '9d' => +{ name => 'ifgt',       },
    '9e' => +{ name => 'ifle',       },
    '9f' => +{ name => 'if_icmpeq',  },
    'a0' => +{ name => 'if_icmpne',  },
    'a1' => +{ name => 'if_icmplt',  },
    'a2' => +{ name => 'if_icmpge',  },
    'a3' => +{ name => 'if_icmpgt',  },
    'a4' => +{ name => 'if_icmple',  },
    'a7' => +{ name => 'goto',       },
    'b1' => +{ name => 'return',     },
    'b2' => +{ name => 'getstatic',  },
    'b6' => +{ name => 'invokevirtual',},
};

sub run {
    my $self = shift;

    my $current = $self->_current_control;

    my $code_array = $self->_code_array;
    while ($current->{code_index} < scalar(@$code_array)) {
        $current->{opcode_index} = int($current->{code_index});
        $current->{opcode}       = $code_array->[$current->{code_index}++];

        my $opcode      = $current->{opcode}; # ex. b6
        my $opcode_name = $opcode_config->{$opcode}->{name}; # ex. getstatic

        die "opcode: $opcode is unimplemented" unless $opcode_name;

        my $module_name = Mouse::Util::load_class("Opcode::".ucfirst($opcode_name));

        my $before_current_control_code_index   = $self->_current_control->{code_index};
        my $before_current_control_opcode_index = $self->_current_control->{opcode_index};

        my @operands;
        for (1..$module_name->operand_count()) {
            push @operands, $code_array->[$current->{code_index}++];
        }

        my $entity = $module_name->new(
            operand_stack                => $self->_operand_stack,
            local_variables              => $self->_local_variables,
            current_control_code_index   => $before_current_control_code_index,
            current_control_opcode_index => $before_current_control_opcode_index,
            operands                     => \@operands,
        );

        $entity->run($self->constant_pool_entries);

        $self->_operand_stack($entity->operand_stack);
        $self->_local_variables($entity->local_variables);
 
        $self->_current_control->{code_index} = $entity->current_control_code_index;
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;