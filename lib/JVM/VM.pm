package JVM::VM;
use warnings;
use strict;
use utf8;

use Mouse;

use JVM::ClassFile;
use JVM::Frame;
use JVM::Util;

has classfile_info => (
    is       => 'ro',
    isa      => 'JVM::ClassFile',
    required => 1,
);

has opcode_modules => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

sub execute {
    my ($self) = @_;

    my $main_method = $self->classfile_info->get_method('main', '([Ljava/lang/String;)V');
    JVM::Frame->new(+{
        constant_pool_entries => $self->classfile_info->constant_pool_entries,
        opcode_modules        => $self->opcode_modules,
        code_array            => JVM::Util->get_code_arrayref(
            $main_method->{attribute_info}->[0]->{code},
            $main_method->{attribute_info}->[0]->{code_length}
        ),
    })->run();
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;