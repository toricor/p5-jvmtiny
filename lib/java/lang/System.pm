package java::lang::System;
use Mouse;
use java::io::PrintStream;

has out => (
    is      => 'ro',
    isa     => 'java::io::PrintStream',
    builder => sub {
        my $self = shift;
        return java::io::PrintStream->new();
    },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
