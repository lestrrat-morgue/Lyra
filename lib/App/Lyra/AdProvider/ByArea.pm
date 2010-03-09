package App::Lyra::AdProvider::ByArea;
use Moose;
use Lyra::Server::AdProvider::ByArea;
use namespace::autoclean;

with 'Lyra::Trait::PsgiAppCmd';

has '+psgi_server' => (
    default => 'Twiggy'
);

has dbh_dsn => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub build_app {
    my $self = shift;
    Lyra::Server::AdProvider::ByArea->new(
        dbh_dsn => $self->dbh_dsn
    )->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;
