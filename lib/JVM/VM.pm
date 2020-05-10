package JVM::VM;
use warnings;
use strict;
use utf8;

use Mouse;
use Mouse::Util;

use JVM::ClassFile;
use JVM::Frame;
use JVM::Util;
use JVM::Util::MouseType qw/ArrayRef/;


has classfile_info => (
    is       => 'ro',
    isa      => 'JVM::ClassFile',
    required => 1,
);

has _opcode_modules => (
    is       => 'ro',
    isa      => ArrayRef,
    builder  => sub {
        return [map { Mouse::Util::load_class("JVM::Opcode::$_") } JVM::Util->get_valid_opcode_names()];
    }
);

sub execute {
    my ($self) = @_;

    my $main_method = $self->classfile_info->get_method('main', '([Ljava/lang/String;)V');

    JVM::Frame->new(+{
        constant_pools => $self->classfile_info->constant_pools,
        opcode_modules => $self->_opcode_modules,
        code_array     => JVM::Util->get_code_arrayref(
            $main_method->{attribute_info}->[0]->{code},
            $main_method->{attribute_info}->[0]->{code_length}
        ),
    })->run();
}

sub load_java_classes {
    my $self = shift;
    return $self->load_classes([JVM::Util->get_java_packages()]);
}

sub load_classes {
    my ($self, $classes) = @_;
    return [map { Mouse::Util::load_class($_) } @$classes];
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;
