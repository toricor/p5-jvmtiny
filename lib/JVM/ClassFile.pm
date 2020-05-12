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

has constant_pools => (
    is      => 'rw',
    isa     => 'ArrayRef[HashRef]',
    default => sub {[+{}]},
);

sub get_method {
    my ($self, $method_name, $method_descriptor) = @_; # "main", "([Ljava/lang/String;)V"

    for my $method (@{$self->methods}) {
        if ( $method->{name_index} eq $method_name && $method->{descriptor_index} eq $method_descriptor ) {
            return $method;
        }
    }
    die "the method is not defined; name: $method_name, descriptor: $method_descriptor";
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
