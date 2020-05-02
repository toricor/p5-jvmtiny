package ClassFileExecutor;
use warnings;
use strict;
use utf8;

use Mouse;
#use feature qw/state say/;

use ClassFile;
use Util;

has classfile_info => (
    is       => 'ro',
    isa      => 'ClassFile',
    required => 1,
);

sub execute {
    my $self = shift;

    for my $method (@{$self->classfile_info->methods}) {
        next if $method->{access_flags} == 0; # FIXME # do not call constuctor

        for my $attribute_info (@{$method->{attribute_info}}) {
            Frame->new(+{
                constant_pool_entries => $self->classfile_info->constant_pool_entries,
                code_array            => Util->get_code_arrayref($attribute_info->{code}, $attribute_info->{code_length}),
            })->run();
        }
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;