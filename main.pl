#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use lib './lib';

use ClassFileReader;
use ClassFileExecutor;

sub main {
    # 1) READ A CLASS FILE
    # 2) EXECUTE THE CODE
    
    # READ A CLASS FILE
    my $classfile_path = $ARGV[0];

    my $classfile_info = ClassFileReader->new(
        classfile_path => $classfile_path
    )->read_class_file();

    # EXECUTE THE CODE
    ClassFileExecutor->new(+{
        classfile_info => $classfile_info,
    })->execute();
}

main();

__END__

=pod

=encoding utf8

=head1 SYNOPSIS

carton install
carton exec perl main.pl HelloWorld.class
or ./dev_env.sh perl main.pl HelloWorld.class (faster)

=head1 DESCRIPTION

    JVM by Perl5;
    read a *.class and run it

=cut
