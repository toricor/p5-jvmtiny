use strict;
use utf8;
use warnings;
use lib './lib';
use Opcode;
use Test::Spec;

# Java8
my @constant_pool_entries = (
    +{},
    +{ #1
        class_index          => "06",
        name_and_type_index  => "0f",
        tag                  => "0a",
    },
    +{ #2
        class_index           => "10",
        name_and_type_index   => "11",
        tag                   => "09"
    },
    +{ #3
        string_index   => 12,
        tag            => "08"
    },
    +{ #4
        class_index          => 13,
        name_and_type_index  => 14,
        tag                  => "0a"
    },
    +{ #5
        name_index   => 15,
        tag          => "07"
    },
    +{ #6
        name_index   => 16,
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
        descriptor_index   => "08",
        name_index         => "07",
        tag                => "0c"
    },
    +{ #16
        name_index   => 17,
        tag          => "07"
    },
    +{ #17
        descriptor_index   => 19,
        name_index         => 18,
        tag                => "0c"
    },
    +{ #18
        string   => "Hello World!",
        tag      => "01"
    },
    +{ #19
        name_index   => "1a",
        tag          => "07"
    },
    +{ #20
        descriptor_index   => "1c",
        name_index         => "1b",
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

describe 'opcode' => sub {
    before all => sub {
        my @vals   = map {hex($_)} qw/B2 00 02 12 03 B6 00 04 B1/; # main
        my $packed = pack("C*", @vals);
        my $code = Opcode->new(+{
            constant_pool_entries => \@constant_pool_entries,
            raw_code => $packed,
            raw_code_length => scalar(@vals),
        });
        $code->run();
    };
    it 'getstatic' => sub {
        ok 1;
    };
};

runtests unless caller;