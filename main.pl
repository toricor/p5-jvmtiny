#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use lib './lib';

use JVM::ClassFileReader;
use JVM::VM;
use JVM::Util;

sub main {
    my $classfile_path = $ARGV[0];
    my $classfile_info = JVM::ClassFileReader->new(
        classfile_path => $classfile_path
    )->read_class_file();

    my $vm = JVM::VM->new(+{
        classfile_info => $classfile_info,
    });

    my $main_method = $classfile_info->get_method('main', '([Ljava/lang/String;)V');
    $vm->frame_stack->[0]->code_array(JVM::Util->get_code_arrayref(
        $main_method->{attribute_info}->[0]->{code},
        $main_method->{attribute_info}->[0]->{code_length},
    ));

    $vm->load_java_classes();
    $vm->execute();
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

    JVM in Perl5;
    read a *.class and run it

=cut
