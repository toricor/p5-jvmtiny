use strict;
use utf8;
use warnings;

use JVM::Frame;
use JVM::Util;

use Test::Spec;

# Java8 (javac -encoding UTF-8 example/AddInt10.java)

my @add_int_10_cp = (
    +{},
    +{ # 1
        class_index           => 5,
        name_and_type_index   => 14,
        tag                   => "0a"
    },
    +{ # 2
        class_index           => 15,
        name_and_type_index   => 16,
        tag                   => "09"
    },
    +{ # 3
        class_index           => 17,
        name_and_type_index   => 18,
        tag                   => "0a"
    },
    +{ # 4
        name_index   => 19,
        tag          => "07"
    },
    +{ # 5
        name_index   => 20,
        tag          => "07"
    },
    +{ # 6
        string   => "<init>",
        tag      => "01"
    },
    +{ # 7
        string   => "()V",
        tag      => "01"
    },
    +{ # 8
        string   => "Code",
        tag      => "01"
    },
    +{ # 9
        string   => "LineNumberTable",
        tag      => "01"
    },
    +{ # 10
        string   => "main",
        tag      => "01"
    },
    +{ # 11
        string   => "([Ljava/lang/String;)V",
        tag      => "01"
    },
    +{ # 12
        string   => "SourceFile",
        tag      => "01"
    },
    +{ # 13
        string   => "AddInt10.java",
        tag      => "01"
    },
    +{ # 14
        descriptor_index   => 7,
        name_index         => 6,
        tag                => "0c"
    },
    +{ # 15
        name_index   => 21,
        tag          => "07"
    },
    +{ # 16
        descriptor_index   => 23,
        name_index         => 22,
        tag                => "0c"
    },
    +{ # 17
        name_index   => 24,
        tag          => "07"
    },
    +{ # 18
        descriptor_index   => 26,
        name_index         => 25,
        tag                => "0c"
    },
    +{ # 19
        string   => "AddInt10",
        tag      => "01"
    },
    +{ # 20
        string   => "java/lang/Object",
        tag      => "01"
    },
    +{ # 21
        string   => "java/lang/System",
        tag      => "01"
    },
    +{ # 22
        string   => "out",
        tag      => "01"
    },
    +{ # 23
        string   => "Ljava/io/PrintStream;",
        tag      => "01"
    },
    +{ # 24
        string   => "java/io/PrintStream",
        tag      => "01"
    },
    +{ # 25
        string   => "println",
        tag      => "01"
    },
    +{ # 26
        string   => "(I)V",
        tag      => "01"
    }
);

describe 'Frame.run' => sub {
    # println(10+20)
    context 'AddInt10' => sub {
        before all => sub {
            my @codes = (
                qw/ 10 0a /,    # bipush
                qw/ 3c /,       # iconst_1
                qw/ 10 14 /,    # bipush
                qw/ 3d /,       # iconst_2
                qw/ b2 00 02 /, # getstatic
                qw/ 1b /,       # iload_1
                qw/ 1c /,       # iload_2
                qw/ 60 /,       # iadd
                qw/ b6 00 03 /, # invokevirtual
                qw/ b1 /,       # return
            );

            my $frame = JVM::Frame->new(+{
                constant_pool_entries => \@add_int_10_cp,
                opcode_modules        => [ map { Mouse::Util::load_class("JVM::Opcode::$_") } JVM::Util->get_valid_opcode_names() ],
                code_array            => \@codes,
            });

            trap {
                $frame->run();
            };
        };
        it 'should show 30' => sub {
            is $trap->stdout, "30\n";
        };
    };
};

runtests unless caller;