package Lyra::Server::AdProvider::ByArea;
use Any::Moose;
use namespace::autoclean;

with qw(Lyra::Trait::AsyncPsgiApp Lyra::Trait::WithMemcached);

sub process {
    my ($self, $start_response, $env) = @_;


    


}

__PACKAGE__->meta->make_immutable();

1;
