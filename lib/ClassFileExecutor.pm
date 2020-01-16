package ClassFileExecutor;
use warnings;
use strict;
use utf8;

use Mouse;
#use feature qw/state say/;

use ClassFile;

has classfile_info => (
    is      => 'ro',
    isa     => 'ClassFile',
    required => 1,
);

sub execute {
    my $self = shift;

    for my $method (@{$self->classfile_info->methods}) {
        next if $method->{access_flags} == 0; # FIXME # do not call constuctor

        for my $attribute_info (@{$method->{attribute_info}}) {
            my $code = Frame->new(+{
                constant_pool_entries => $self->classfile_info->constant_pool_entries,
                raw_code              => $attribute_info->{code},
                raw_code_length       => $attribute_info->{code_length},
            });
            $code->run();
        }
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;