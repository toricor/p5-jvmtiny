#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use lib './lib';
#use feature qw/say state/;

use ClassFileReader;
use Frame;

sub main {
    # 1) READ A CLASS FILE
    # 2) RUN OPCODES
    
    # READ A CLASS FILE
    # prepare: `javac -encoding UTF-8 example/HelloWorld.java 
    my $classfile_path = $ARGV[0];
    my $classfile_info = ClassFileReader->new(
        classfile_path => $classfile_path
    )->read_class_file();

    # RUN OPCODES
    # https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html
    for my $method (@{$classfile_info->methods}) {
        next if $method->{access_flags} == 0; # FIXME # do not call constuctor

        for my $attribute_info (@{$method->{attribute_info}}) {
            my $code = Frame->new(+{
                constant_pool_entries => $classfile_info->constant_pool_entries,
                raw_code              => $attribute_info->{code},
                raw_code_length       => $attribute_info->{code_length},
            });
            $code->run();
        }
    }
}

main();

__END__

=pod

=encoding utf8

=head1 SYNOPSIS

carton install
carton exec perl main.pl HelloWorld.class
or ./dev_env.sh perl main.pl HelloWorld.class

=head1 DESCRIPTION

    JVM by Perl5;
    read *.class and run it

=cut