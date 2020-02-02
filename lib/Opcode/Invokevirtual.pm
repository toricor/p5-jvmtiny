package Opcode::Invokevirtual;
use warnings;
use strict;
use utf8;

use Mouse;

our $opcode = 'b6';

has operands => (
    is       => 'ro',
    isa      => 'ArrayRef[Int]',
    default  => sub {[]}
);

has operand_stack => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub run {
    my ($self, $constant_pool_entries) = @_;

    my $indexbyte1 = $self->operands->[0];
    my $indexbyte2 = $self->operands->[1];

    my $constant_pool_index   = $self->_index_by_byte1_and_byte2($indexbyte1, $indexbyte2);
    my $symbol_name_hash = $constant_pool_entries->[$constant_pool_index];

    my $callee_info = $constant_pool_entries->[$symbol_name_hash->{name_and_type_index}];
    my $method_name = $constant_pool_entries->[$callee_info->{name_index}]->{string};

    my $argments_string = $constant_pool_entries->[$callee_info->{descriptor_index}]->{string};
    # TODO: https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.3
    my $argments_size = 1;#(() = $argments_string =~ m/;/g); # https://shogo82148.github.io/blog/2015/04/09/count-substrings-in-perl/
    #use DDP;
    #p $argments_string; # AddInt: "(I)V"; HelloWorld: "(Ljava/lang/String;)V";
 
    #p $argments_size;   # AddInt: 0
    my @argments;
    for (1..$argments_size) {
        push @argments, pop @{$self->operand_stack}, # XXX: pop order (本当は逆からpopする必要がある) https://speakerdeck.com/memory1994/php-de-jvm-woshi-zhuang-site-hello-world-wochu-li-surumade?slide=150
    }

    my $method = pop @{$self->operand_stack};
#use DDP;
#p $method;
    my $return = $method->{callable}->$method_name(@argments);
}

sub _index_by_byte1_and_byte2 {
    my ($self, $indexbyte1, $indexbyte2) = @_;
    return (hex($indexbyte1) << 8) | hex($indexbyte2);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;