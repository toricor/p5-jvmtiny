package JVM::ClassFile;
use warnings;
use strict;
use utf8;

use Mouse;

use JVM::Util::MouseType qw/Int Str ArrayRef UInt PositiveInt/;

has minor => (
    is       => 'ro',
    isa      => UInt,
    required => 1,
);

has major => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 1,
);

has access_flags => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has this_class => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has super_class => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has interfaces => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub {[]},
);

has fields => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub {[]},
);

has methods => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has attributes => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub {[]},
);


has constant_pool_entries => (
    is      => 'rw',
    isa     => 'ArrayRef[HashRef]',
    default => sub {[+{}]},
);

no Mouse;
__PACKAGE__->meta->make_immutable;

1;