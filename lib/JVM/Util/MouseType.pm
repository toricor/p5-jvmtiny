package JVM::Util::MouseType;

use warnings;
use strict;
use utf8;

use Mouse::Util::TypeConstraints;

# called at `use MouseX::Types -declare`, so write this code before the use;
my $storage;
sub type_storage {
    $storage //= +{
        # export Mouse builtin types from this package;
        (map { $_ => $_  } Mouse::Util::TypeConstraints->list_all_builtin_type_constraints),
    };
    return $storage;
};

use MouseX::Types
    -declare => [
        qw/
        UInt
        PositiveInt
        ByteStr
        OpcodeModuleName
        /,
    ];

# import builtin types
use MouseX::Types::Mouse qw/Int Str HashRef Object ArrayRef Maybe Undef/;

# type definition.
subtype UInt, 
    as Int, 
    where { $_ >= 0 },
    message { 'UInt must be >= 0' };

subtype PositiveInt, 
    as Int, 
    where { $_ > 0 },
    message { 'Int is not larger than 0' };

subtype OpcodeModuleName,
    as Str,
    where { $_ =~ /JVM::Opcode::[A-Z][a-z_0-9]+/ },
    message { "opcode module name is like 'JVM::Opcode::Getstatic'"};

# hexdumped: b6, 02, ...
subtype ByteStr,
    as Str,
    where { $_ =~ /[a-z0-9]{2}/ },
    message { 'exactly **2** chars are required' };

no Mouse::Util::TypeConstraints;
1;
