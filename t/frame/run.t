use strict;
use utf8;
use warnings;

use Frame;
use Test::Spec;

# Java8 (javac -encoding UTF-8 HelloWorld.java)
my @hello_world_cp = (
    +{},
    +{ #1
        class_index          => 6,
        name_and_type_index  => 15,
        tag                  => "0a",
    },
    +{ #2
        class_index           => 16,
        name_and_type_index   => 17,
        tag                   => "09"
    },
    +{ #3
        string_index   => 18,
        tag            => "08"
    },
    +{ #4
        class_index          => 19,
        name_and_type_index  => 20,
        tag                  => "0a"
    },
    +{ #5
        name_index   => 21,
        tag          => "07"
    },
    +{ #6
        name_index   => 22,
        tag          => "07"
    },
    +{ #7
        string   => "<init>",
        tag      => "01"
    },
    +{ #8
        string   => "()V",
        tag      => "01"
    },
    +{ #9
        string   => "Code",
        tag      => "01"
    },
    +{ #10
        string   => "LineNumberTable",
        tag      => "01"
    },
    +{ #11
        string   => "main",
        tag      => "01"
    },
    +{ #12
        string   => "([Ljava/lang/String;)V",
        tag      => "01"
    },
    +{ #13
        string   => "SourceFile",
        tag      => "01"
    },
    +{ #14
        string   => "HelloWorld.java",
        tag      => "01"
    },
    +{ #15
        descriptor_index   => 8,
        name_index         => 7,
        tag                => "0c"
    },
    +{ #16
        name_index   => 23,
        tag          => "07"
    },
    +{ #17
        descriptor_index   => 25,
        name_index         => 24,
        tag                => "0c"
    },
    +{ #18
        string   => "Hello World!",
        tag      => "01"
    },
    +{ #19
        name_index   => 26,
        tag          => "07"
    },
    +{ #20
        descriptor_index   => 28,
        name_index         => 27,
        tag                => "0c"
    },
    +{ #21
        string   => "HelloWorld",
        tag      => "01"
    },
    +{ #22
        string   => "java/lang/Object",
        tag      => "01"
    },
    +{ #23
        string   => "java/lang/System",
        tag      => "01"
    },
    +{ #24
        string   => "out",
        tag      => "01"
    },
    +{ #25
        string   => "Ljava/io/PrintStream;",
        tag      => "01"
    },
    +{ #26
        string   => "java/io/PrintStream",
        tag      => "01"
    },
    +{ #27
        string   => "println",
        tag      => "01"
    },
    +{ #28
        string   => "(Ljava/lang/String;)V",
        tag      => "01"
    }
);

describe 'Frame.run' => sub {
    context 'HelloWorld' => sub {
        before all => sub {
            my @values = map {hex($_)} (
                qw/B2 00 02/, # getstatic
                qw/12 03/,    # ldc
                qw/B6 00 04/, # invokevirtual
            );
            my $packed = pack("C*", @values);
            my $frame = Frame->new(+{
                constant_pool_entries => \@hello_world_cp,
                raw_code              => $packed,
                raw_code_length       => scalar(@values),
            });
            trap {
                $frame->run();
            };
        };
        it 'should show "Hello World!\n"' => sub {
            is $trap->stdout, "Hello World!\n";
        };
    };
};

runtests unless caller;