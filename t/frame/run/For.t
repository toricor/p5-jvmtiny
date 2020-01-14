use strict;
use utf8;
use warnings;

use Frame;
use Test::Spec;

# Java8 (javac -encoding UTF-8 example/For.java)

my @cp = (
    +{}, # 1
    +{   # 2
        'name_and_type_index' => 15,
        'tag' => '0a',
        'class_index' => 5
    },
    +{  # 3
        'name_and_type_index' => 17,
        'tag' => '09',
        'class_index' => 16
    },
    +{ # 4
        'name_and_type_index' => 19,
        'tag' => '0a',
        'class_index' => 18
    },
    +{  # 5
          'name_index' => 20,
          'tag' => '07'
    },
    +{  # 6
          'tag' => '07',
          'name_index' => 21
    },
    +{  # 7
          'string' => '<init>',
          'tag' => '01'
    },
    +{  # 8
          'tag' => '01',
          'string' => '()V'
    },
    +{  # 9
        'tag' => '01',
        'string' => 'Code'
        },
    +{  # 10
           'string' => 'LineNumberTable',
           'tag' => '01'
    },
    +{  # 11
           'string' => 'main',
           'tag' => '01'
    },
    +{  # 12
           'string' => '([Ljava/lang/String;)V',
           'tag' => '01'
    },
    +{  # 13
           'tag' => '01',
           'string' => 'StackMapTable'
    },
    +{  # 14
           'tag' => '01',
           'string' => 'SourceFile'
    },
    +{  # 15
           'tag' => '01',
           'string' => 'For.java'
    },
    +{  # 16
           'tag' => '0c',
           'descriptor_index' => 7,
           'name_index' => 6
    },
    +{  # 17
           'name_index' => 22,
           'tag' => '07'
    },
    +{  # 18
           'tag' => '0c',
           'descriptor_index' => 24,
           'name_index' => 23
    },
    +{  # 19
           'name_index' => 25,
           'tag' => '07'
    },
    +{  # 20
           'tag' => '0c',
           'descriptor_index' => 27,
           'name_index' => 26
    },
    +{  # 21
           'tag' => '01',
           'string' => 'For'
    },
    +{  # 22
           'tag' => '01',
           'string' => 'java/lang/Object'
    },
    +{  # 23
           'string' => 'java/lang/System',
           'tag' => '01'
    },
    +{  # 24
           'tag' => '01',
           'string' => 'out'
    },
    +{  # 25
           'string' => 'Ljava/io/PrintStream;',
           'tag' => '01'
    },
    +{  # 26
           'tag' => '01',
           'string' => 'java/io/PrintStream'
    },
    +{  # 27
           'tag' => '01',
           'string' => 'println'
    },
    +{  # 28
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
            my @values = map {hex($_)} (
                qw/ 06 /, # iconst_3
                qw/ 3c /, # istore_1
                qw/ 03 /, # iconst_0
                qw/ 3d /, # istore_2
                qw/ 1c /, # iload_2
                qw/ 1b /, # iload_1
                qw/ a2 00 10/, # if_icmpge
                qw/ b2 00 02/, # getstatic
                qw/ 1c /, # iload_2
                qw/ b6 00 03/, # invokevirtual
                qw/ 84 02 01/, # iinc
                qw/ a7 ff f1/, # goto
                qw/ b1 / # return
            );
            my $packed = pack("C*", @values);
            my $frame = Frame->new(+{
                constant_pool_entries => \@cp,
                raw_code              => $packed,
                raw_code_length       => scalar(@values),
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