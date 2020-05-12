package java::io::PrintStream;
use Mouse;

sub println {
    my ($self, $arg) = @_;
    print "$arg\n";
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
