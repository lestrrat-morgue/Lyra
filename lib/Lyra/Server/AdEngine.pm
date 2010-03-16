package Lyra::Server::AdEngine;
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

sub log_request {
}

sub log_impression {
}

__PACKAGE__->meta->make_immutable();

1;