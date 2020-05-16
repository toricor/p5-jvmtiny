package java::lang::System;
use Mouse;
use java::io::PrintStream;

has out => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => sub {
        return 'java::io::PrintStream';
    },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
