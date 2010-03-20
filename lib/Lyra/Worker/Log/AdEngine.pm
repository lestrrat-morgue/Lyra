package Lyra::Worker::Log::AdEngine;
use Moose;
use namespace::autoclean;

has request_log_storage => (
    is => 'ro',
    isa => 'Lyra::Log::Storage',
);

has impression_log_storage => (
    is => 'ro',
    isa => 'Lyra::Log::Storage'
);

__PACKAGE__->meta->make_immutable();

1;
sub process {
    my ($self, $data) = @_;

        my $store;
        $store = $self->request_log_storage;
        $store->store(join("\t", $data->{lat}, $data->{lng}) . "\n");

        $store = $self->impression_log_storage;
        foreach my $ad (@{$data->{ads}}) {
            $store->store( 
                join("\t", @$ad) . "\n"
            );
        }
}

__PACKAGE__->meta->make_immutable();

1;

