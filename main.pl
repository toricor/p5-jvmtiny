#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use lib './lib';
use Frame;
use feature qw/say state/;

# prepare class file
# `javac -encoding UTF-8 example/HelloWorld.java`
my $file = $ARGV[0];

open my $fh, '<', $file or die $!;
binmode $fh;

# big endian
sub read_unsigned_short {
    sysread($fh, my $buf, 2);
    return unpack('n', $buf);
}

# big endian
sub read_unsigned_int {
    sysread($fh, my $buf, 4);
    return unpack('N', $buf);
}

sub read_byte {
    sysread($fh, my $buf, 1);
    return unpack('C', $buf);
}

sub read_attribute {
    my ($constant_pool_entries) = @_;

    my $attribute_name_index = read_unsigned_short();
    my $attribute_length = read_unsigned_int();

    my $name = $constant_pool_entries->[$attribute_name_index]->{string}; # attribute name
    my %result = (
        name             => $name,
        attribute_length => $attribute_length,
    );

    # Code Attribute https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3
    if ($name eq 'Code') {
        %result = (
            %result,
            max_stack   => read_unsigned_short(),
            max_locals  => read_unsigned_short(),
            code_length => read_unsigned_int(),
        );
        my $len = $result{code_length};

        sysread($fh, my $buf, $len);
        $result{code} = $buf;

        $result{exception_table_length} = read_unsigned_short();
        my @exception_tables;
        for my $i (1..$result{exception_table_length}){
            push @exception_tables, +{
                start_pc   => read_unsigned_short(),
                end_at     => read_unsigned_short(),
                handler_pc => read_unsigned_short(),
                catch_type => read_unsigned_short(),
            };
        }
        $result{exception_tables} = \@exception_tables;

        $result{attributes_count} = read_unsigned_short();

        my @attributes;
        for my $i (1..$result{attributes_count}) {
            my $attribute = read_attribute($constant_pool_entries);
            push @attributes, $attribute;
        }
        $result{attributes} = \@attributes;
    }
    # LineNumberTable Attribute
    elsif ($name eq 'LineNumberTable') {
        $result{line_number_table_length} = read_unsigned_short();

        my @line_number_tables;
        for my $i (1..$result{line_number_table_length}) {
            push @line_number_tables, +{
                start_pc    => read_unsigned_short(),
                line_number => read_unsigned_short(),
            };
        }
        $result{line_number_tables} = \@line_number_tables;
    }
    # SourceFile Attribute
    elsif ($name eq 'SourceFile') {
        $result{sourcefile_index} = read_unsigned_short();
    }
    # StackMapTable
    elsif ($name eq 'StackMapTable') {
        $result{stack_map_table_number_of_entries} = read_unsigned_short();

        my @stack_map_frame_entries;
        for my $i (1..$result{stack_map_table_number_of_entries}) {
            my $frame_type = read_byte();

            my $entry;
            # CHOP
            if (248 <= $frame_type && $frame_type <= 250) {
                $entry = +{
                    frame_type   => $frame_type,
                    offset_delta => read_unsigned_short(),
                };   
            }
            # APPEND
            elsif (252 <= $frame_type && $frame_type <= 254) {
                $entry = +{
                    frame_type   => $frame_type,
                    offset_delta => read_unsigned_short(),
                };
                my $k = $frame_type - 251;
                
                my @verification_type_infos;
                for (1..$k) {
                    my $variable_info = read_byte();
                    push @verification_type_infos, $variable_info;
                }
                $entry->{verification_type_infos} = \@verification_type_infos;
            }
            push @stack_map_frame_entries, $entry;
        }
        $result{stack_map_table_frame_entries} = \@stack_map_frame_entries;
    }
    # TODO
    else {
        die "$name is unimplemented attribute";
    }

    return \%result;
}

sub main {
    # 1) READ CLASS FILE
    # 2) RUN OPCODES

    # READ CLASS FILE
    ## https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4

    ## header information
    my $magic = read_unsigned_int();
    my $minor = read_unsigned_short();
    my $major = read_unsigned_short();

    ## constant pool
    my @constant_pool_entries = (+{}); # 後でアクセスしやすいように
    my $constant_pool_count = read_unsigned_short();

    for my $i (1..$constant_pool_count-1) {
        my $tag = sprintf("%02x", read_byte());

        my %entry;

        # 0x0A: CONSTANT_Methodref 
        # 0x09: CONSTANT_Fieldref
        # 0x0B: CONSTANT_InterfaceMethodref
        if ($tag eq '09' | $tag eq '0a' | $tag eq '0b') {
            $entry{class_index} = read_unsigned_short();
            $entry{name_and_type_index} = read_unsigned_short();
        }
        # 0x08: CONSTANT_String
        elsif ($tag eq '08') {
            $entry{string_index} = read_unsigned_short();
        }
        # 0x07: CONSTANT_Class
        elsif ($tag eq '07') {
            $entry{name_index} = read_unsigned_short();
        }
        # 0x01: CONSTANT_Utf8
        elsif ($tag eq '01') {
            my $length = read_unsigned_short();
            sysread($fh, my $buf, $length);
            my @unpackeds = unpack("c[$length]", $buf);
            $entry{string} = join('', map {chr($_)} @unpackeds);
        }
        # 0x0C: CONSTANT_NameAndType
        elsif ($tag eq '0c') {
            $entry{name_index} = read_unsigned_short();
            $entry{descriptor_index} = read_unsigned_short();
        }
        # TODO
        else {
            die 'unimplemented tag';
        }

        push @constant_pool_entries, +{
            tag => $tag,
            %entry,
        };
    }
    #use DDP;
    #p @constant_pool_entries;
    my $access_flags = read_unsigned_short();

    my $this_class  = read_unsigned_short(); # HelloWorld: 0x0005(Constant pool #5 // HelloWorld)
    my $super_class = read_unsigned_short(); # HelloWorld: 0x0006(Constant pool #6 // java/lang/Object

    my $interfaces_count = read_unsigned_short(); # 0
    sysread($fh, my $buf, $interfaces_count);
    my @interfaces = unpack("n[$interfaces_count]", $buf);

    my $fields_count = read_unsigned_short(); # 0
    for my $i (1..$fields_count) {
        # TODO
    }

    my $methods_count = read_unsigned_short();

    ## method_info https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.6
    my @methods;
    for (1..$methods_count) {
        my %method = (
            access_flags     => read_unsigned_short(),     # メソッドへのアクセス権 (<init>: 0x00)
            name_index       => $constant_pool_entries[read_unsigned_short()]{string}, # メソッド名
            descriptor_index => $constant_pool_entries[read_unsigned_short()]{string}, # 引数の情報
            attribute_info   => [],
        );
        my $attributes_count = read_unsigned_short(); # 属性の数
        for (1..$attributes_count) {
            push @{$method{attribute_info}}, read_attribute(\@constant_pool_entries);    
        }
        push @methods, \%method;
    }

    my $attribute_count = read_unsigned_short();
    my @attributes;
    for (1..$attribute_count) {
        push @attributes, read_attribute(\@constant_pool_entries);
    }


    # RUN OPCODES
    # https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html
    for my $method (@methods) {
        next if $method->{access_flags} == 0; # FIXME # 静的メソッドなのでコンストラクタは呼ばれないように

        for my $attribute_info (@{$method->{attribute_info}}) {
            my $code = Frame->new(+{
                constant_pool_entries => \@constant_pool_entries,
                raw_code              => $attribute_info->{code},
                raw_code_length       => $attribute_info->{code_length},
            });
            $code->run();
        }
    }
}

main();

close($fh);

__END__

=pod

=encoding utf8

=head1 SYNOPSIS

carton install
carton exec perl main.pl HelloWorld.class
or ./dev_env.sh perl main.pl HelloWorld.class

=head1 DESCRIPTION

    JVM by Perl;
    read *.class and run it

=cut