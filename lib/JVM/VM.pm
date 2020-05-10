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

has frame_stack => (
    is        => 'ro',
    isa       => 'ArrayRef',
    default   => sub {
        my $self = shift;
        return [JVM::Frame->new(+{
            constant_pools => $self->classfile_info->constant_pools,
            opcode_modules => $self->get_opcode_modules(),
        })];
    },
);

sub execute {
    my ($self) = @_;

    while (scalar(@{$self->frame_stack}) > 0) {
        my $frame = pop @{$self->frame_stack};
        $frame->run($self->frame_stack);
    }
}

sub get_opcode_modules {
    return [map { Mouse::Util::load_class("JVM::Opcode::$_") } JVM::Util->get_valid_opcode_names()];
};

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
