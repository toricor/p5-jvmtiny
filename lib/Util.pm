package Util;

use warnings;
use strict;
use utf8;

sub get_code_arrayref {
    my ($class, $bin_code, $bin_code_length) = @_;
    return [map {sprintf("%02x", $_)} unpack("C[$bin_code_length]", $bin_code)];
}

sub get_valid_opcode_names {
    my ($class) = @_;
    return grep {
        # Opcode::Base is not target
        $_ !~ /Base/
    } map {
        $_ =~ /(\w+)\.pm/
    } glob "lib/Opcode/*.pm";
}

sub get_java_packages {
    my ($class) = @_;
    return map {
        my $s = $_; $s =~ s/\//::/g; $s;
    } map {
        $_ =~ /lib\/(.*)\.pm/
    } glob "lib/java/**/*.pm";
}
1;