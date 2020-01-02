package java::io::PrintStream;
use Mouse;
use feature qw/say/;

sub println {
    my ($self, $args) = @_;
    warn $args;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;