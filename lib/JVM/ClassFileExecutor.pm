package JVM::ClassFileExecutor;
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

    for my $method (@{$self->classfile_info->methods}) {
        next if $method->{access_flags} == 0; # FIXME # do not call constuctor

        for my $attribute_info (@{$method->{attribute_info}}) {
            JVM::Frame->new(+{
                constant_pool_entries => $self->classfile_info->constant_pool_entries,
                opcode_modules        => $self->opcode_modules,
                code_array            => JVM::Util->get_code_arrayref($attribute_info->{code}, $attribute_info->{code_length}),
            })->run();
        }
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;