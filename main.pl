#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use lib './lib';

use Mouse::Util;

use JVM::ClassFileReader;
use JVM::VM;
use JVM::Util;

sub main {
    # 1) LOAD MODULES
    # 2) READ A CLASS FILE
    # 3) EXECUTE THE CODE
    
    # 1. LOAD MODULES
    my @java_packages  = map { Mouse::Util::load_class($_) } JVM::Util->get_java_packages();

    # 2. READ A CLASS FILE
    my $classfile_path = $ARGV[0];
    my $classfile_info = JVM::ClassFileReader->new(
        classfile_path => $classfile_path
    )->read_class_file();

    # 3. EXECUTE THE CODE
    JVM::VM->new(+{
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
