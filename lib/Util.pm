package Util;

use warnings;
use strict;
use utf8;

sub get_code_arrayref {
    my ($class, $bin_code, $bin_code_length) = @_;
    return [map {sprintf("%02x", $_)} unpack("C[$bin_code_length]", $bin_code)];
}

1;