package App::Lyra::Clickd;
use Moose;
use Lyra::Server::Click;
use Lyra::Server::Click::Storage::File;
use File::Spec;
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

    # XXX Make this configurable
    my $storage = Lyra::Server::Click::Storage::File->new(
        prefix => File::Spec->catfile(File::Spec->tmpdir, 'clickd.CHANGEME')
    );

    Lyra::Server::Click->new(
        dbh_dsn => $self->dbh_dsn,
        log_storage => $storage,
    )->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;

