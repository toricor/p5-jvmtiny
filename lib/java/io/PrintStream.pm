package java::io::PrintStream;
use Mouse;

sub println {
    my ($self, $args) = @_;
    print "$args\n";
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
