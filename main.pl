#!/usr/bin/perl
use utf8;
use strict;
use warnings;

my $file = 'HelloWorld.class';

open my $fh, '<', $file or die $!;
binmode $fh;

# big endian
sub read_unsigned_short {
    sysread($fh, my $buf, 2);
    return sprintf("%02x", unpack('n', $buf));
    # return unpack('n', $buf); # これは%dで結果が返るようだ 
}

# big endian
sub read_unsigned_int {
    sysread($fh, my $buf, 4);
    return sprintf("%x", unpack('N', $buf));
}

sub read_byte {
    sysread($fh, my $buf, 1);
    return sprintf("%02x", unpack('c', $buf));
}

sub read_attribute {
    my ($constant_pool_entries) = @_;

    my $attribute_name_index = read_unsigned_short();
    my $attribute_length = hex(read_unsigned_short());

    my %result;
    my $name = $constant_pool_entries->[hex($attribute_name_index)]->{string}; # attribute name
    $result{name} = $name;
    # Code Attribute https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3
    if ($name eq 'Code') {
        $result{max_stack}   = read_unsigned_short();
        $result{max_locals}  = read_unsigned_short();
        $result{code_length} = read_unsigned_int();
        my $len = hex($result{code_length});

        sysread($fh, my $buf, $len);
        $result{code} = $buf;
        use DDP;
        p %result;
    }
    # LineNumberTable Attribute
    elsif ($name eq 'LineNumberTable') {

    }
    # SourceFile Attribute
    elsif ($name eq 'SourceFile') {
    
    }
}

sub main {
    # https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4

    # header information
    my $magic = read_unsigned_int();
    my $minor = read_unsigned_short();
    my $major = read_unsigned_short();

    # constant pool 
    my @constant_pool_entries = (undef); # 後でアクセスしやすいように
    my $constant_pool_count = hex(read_unsigned_short());

    die 'invalid value' unless $constant_pool_count == 29; 

    for my $i (1..$constant_pool_count-1) {
        my $tag = read_byte();
        
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
            my $length = hex(read_unsigned_short());
            sysread($fh, my $buf, $length);
            my @unpackeds = unpack("c[$length]", $buf); # unpackはスカラコンテキストでは最初の値しか返さない http://www5b.biglobe.ne.jp/~sgi/perl/framec/pl511.html
            $entry{string} = join('', map {chr($_)} @unpackeds);
        }        
        # 0x0C: CONSTANT_NameAndType
        elsif ($tag eq '0c') {
            $entry{name_index} = read_unsigned_short();
            $entry{descriptor_index} = read_unsigned_short();
        }    
        push @constant_pool_entries, +{
            tag => $tag,
            %entry,
        };
    }
    use DDP;
    p @constant_pool_entries;

    my $access_flags = read_unsigned_short();
    die 'access_flag is wrong' unless $access_flags == 20;
   
    my $this_class       = read_unsigned_short(); # HelloWorld: 0x0005(Constant pool #5 // HelloWorld)
    my $super_class      = read_unsigned_short(); # HelloWorld: 0x0006(Constant pool #6 // java/lang/Object

    my $interfaces_count = hex(read_unsigned_short()); # 0
    read($fh, my $buf, $interfaces_count);
    # unpackはスカラコンテキストでは最初の値しか返さない http://www5b.biglobe.ne.jp/~sgi/perl/framec/pl511.html
    my @interfaces = unpack("n[$interfaces_count]", $buf); # (0)

    my $fields_count = hex(read_unsigned_short()); # 0
    for my $i (1..$fields_count) {
        # TODO
    }

    my $methods_count = hex(read_unsigned_short());
    die 'invalid methods count' unless $methods_count == 2; # <init> and main

    # method_info https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.6
    my @methods;
    for my $i (1..$methods_count) {
        my %method;
        $method{access_flags}     = read_unsigned_short();      # メソッドへのアクセス権 (<init>: 0x00)
        $method{name_index}       = $constant_pool_entries[hex(read_unsigned_short())]{string}; # メソッド名
        $method{descriptor_index} = $constant_pool_entries[hex(read_unsigned_short())]{string}; # 引数の情報
        my $attributes_count      = hex(read_unsigned_short()); # 属性の数
        
        $method{attribute_info} = [];
        for my $j (1..$attributes_count) {
            push @{$method{attribute_info}}, read_attribute(\@constant_pool_entries);    
        }
        push @methods, \%method;
    }
    p @methods;
}

main();

close($fh);
