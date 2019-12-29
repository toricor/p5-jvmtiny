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
sub read_unsigned_long {
    sysread($fh, my $buf, 4);
    return sprintf("%x", unpack('N', $buf));
}

sub read_byte {
    sysread($fh, my $buf, 1);
    return sprintf("%x", unpack('c', $buf));
}

sub main {
    # https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4

    # header information
    my $magic = read_unsigned_long();
    my $minor = read_unsigned_short();
    my $major = read_unsigned_short();
    
    my @constant_pool_entries;
    my $constant_pool_count = hex(read_unsigned_short());

    die 'invalid value' unless $constant_pool_count == 29; 

    # constant pool 
    for my $i (1..$constant_pool_count-1) {
        my $tag = read_byte();
        
        my %entry;

        # 0x0A: CONSTANT_Methodref 
        # 0x09: CONSTANT_Fieldref
        # 0x0B: CONSTANT_InterfaceMethodref
        if ($tag eq '9' | $tag eq 'a' | $tag eq 'b') {
            $entry{class_index} = read_unsigned_short();
            $entry{name_and_type_index} = read_unsigned_short();
        }
        # 0x08: CONSTANT_String
        elsif ($tag eq '8') {
            $entry{string_index} = read_unsigned_short();
        }
        # 0x07: CONSTANT_Class
        elsif ($tag eq '7') {
            $entry{name_index} = read_unsigned_short();
        }
        # 0x01: CONSTANT_Utf8
        elsif ($tag eq '1') {
            my $length = hex(read_unsigned_short());
            sysread($fh, my $buf, $length);
            my @unpackeds = unpack("c[$length]", $buf); # unpackはスカラコンテキストでは最初の値しか返さない http://www5b.biglobe.ne.jp/~sgi/perl/framec/pl511.html
            $entry{string} = join('', map {chr($_)} @unpackeds);
        }        
        # 0x0C: CONSTANT_NameAndType
        elsif ($tag eq 'c') {
            $entry{name_index} = read_unsigned_short();
            $entry{descriptor_index} = read_unsigned_short();
        }    
        push @constant_pool_entries, +{
            tag => $tag,
            %entry,
        };
    }
    use DDP; p @constant_pool_entries;
    

    my $access_flags = read_unsigned_short();
    die 'access_flag is wrong' unless $access_flags == 20;
   
    my $this_class = read_unsigned_short();
    print $this_class."\n"; # HelloWorld: 0x0005(Constant pool #5 // HelloWorld)
    my $super_class = read_unsigned_short();
    print $super_class."\n"; # HelloWorld: 0x0006(Constant pool #6 // java/lang/Object

    my $interfaces_count = read_unsigned_short();
    print $interfaces_count."\n"; # 0
    read($fh, my $buf, $interfaces_count);
    my @interfaces = unpack("n[$interfaces_count]", $buf); # unpackはスカラコンテキストでは最初の値しか返さない http://www5b.biglobe.ne.jp/~sgi/perl/framec/pl511.html
    print @interfaces; # (0)

    my $fields_count = hex(read_unsigned_short());
    print $fields_count."\n"; # 0
    for my $i (1..$fields_count) {
        # TODO
    }
    my $methods_count = hex(read_unsigned_short());
    print $methods_count."\n"; # 2

    my @methods;
    for my $i (1..$methods_count) {
        my %method;
        $method{access_flags} = read_unsigned_short();
        $method{name_index}   = read_unsigned_short();
        $method{descriptor_index} = read_unsigned_short();
        my $attributes_count = hex(read_unsigned_short());

        push @methods, \%method;
    }
}

main();

close($fh);
