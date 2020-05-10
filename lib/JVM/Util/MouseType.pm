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

no Mouse::Util::TypeConstraints;
1;
