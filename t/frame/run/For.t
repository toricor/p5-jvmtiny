use strict;
use utf8;
use warnings;

use Frame;
use Test::Spec;

# Java8 (javac -encoding UTF-8 example/For.java)

my @cp = (
    +{},
    +{   # 1
        'name_and_type_index' => 15,
        'tag' => '0a',
        'class_index' => 5
    },
    +{  # 2
        'name_and_type_index' => 17,
        'tag' => '09',
        'class_index' => 16
    },
    +{ # 3
        'name_and_type_index' => 19,
        'tag' => '0a',
        'class_index' => 18
    },
    +{  # 4
          'name_index' => 20,
          'tag' => '07'
    },
    +{  # 5
          'tag' => '07',
          'name_index' => 21
    },
    +{  # 6
          'string' => '<init>',
          'tag' => '01'
    },
    +{  # 7
          'tag' => '01',
          'string' => '()V'
    },
    +{  # 8
        'tag' => '01',
        'string' => 'Code'
        },
    +{  # 9
           'string' => 'LineNumberTable',
           'tag' => '01'
    },
    +{  # 10
           'string' => 'main',
           'tag' => '01'
    },
    +{  # 11
           'string' => '([Ljava/lang/String;)V',
           'tag' => '01'
    },
    +{  # 12
           'tag' => '01',
           'string' => 'StackMapTable'
    },
    +{  # 13
           'tag' => '01',
           'string' => 'SourceFile'
    },
    +{  # 14
           'tag' => '01',
           'string' => 'For.java'
    },
    +{  # 15
           'tag' => '0c',
           'descriptor_index' => 7,
           'name_index' => 6
    },
    +{  # 16
           'name_index' => 22,
           'tag' => '07'
    },
    +{  # 17
           'tag' => '0c',
           'descriptor_index' => 24,
           'name_index' => 23
    },
    +{  # 18
           'name_index' => 25,
           'tag' => '07'
    },
    +{  # 19
           'tag' => '0c',
           'descriptor_index' => 27,
           'name_index' => 26
    },
    +{  # 20
           'tag' => '01',
           'string' => 'For'
    },
    +{  # 21
           'tag' => '01',
           'string' => 'java/lang/Object'
    },
    +{  # 22
           'string' => 'java/lang/System',
           'tag' => '01'
    },
    +{  # 23
           'tag' => '01',
           'string' => 'out'
    },
    +{  # 24
           'string' => 'Ljava/io/PrintStream;',
           'tag' => '01'
    },
    +{  # 25
           'tag' => '01',
           'string' => 'java/io/PrintStream'
    },
    +{  # 26
           'tag' => '01',
           'string' => 'println'
    },
    +{  # 27
           'tag' => '01',
           'string' => '(I)V'
    },
);

describe 'Frame.run' => sub {
    # say 0
    # say 1
    # say 2
    context 'For' => sub {
        before all => sub {
            my @codes = (
                qw/ 06 /,       # iconst_3
                qw/ 3c /,       # istore_1
                qw/ 03 /,       # iconst_0
                qw/ 3d /,       # istore_2
                qw/ 1c /,       # iload_2
                qw/ 1b /,       # iload_1
                qw/ a2 00 10 /, # if_icmpge
                qw/ b2 00 02 /, # getstatic
                qw/ 1c /,       # iload_2
                qw/ b6 00 03 /, # invokevirtual
                qw/ 84 02 01 /, # iinc
                qw/ a7 ff f1 /, # goto
                qw/ b1 /        # return
            );

            my $frame = Frame->new(+{
                constant_pool_entries => \@cp,
                code_array            => \@codes,
            });

            trap {
                $frame->run();
            };
        };
        it 'should show 1,2&3' => sub {
            is $trap->stdout, "0\n1\n2\n";
        };
    };
};

runtests unless caller;