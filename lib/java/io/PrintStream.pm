package java::io::PrintStream;
use Mouse;
use feature qw/say/;

sub println {
    my ($self, $args) = @_;
    say $args;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;