package java::io::PrintStream;

sub println {
    my ($self, $arg) = @_;
    print "$arg\n";
}

1;
