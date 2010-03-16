package App::Lyra::Clickd;
use Moose;
use Lyra::Server::Click;
use Lyra::Server::Click::Storage::File;
use File::Spec;
use namespace::autoclean;

with 'Lyra::Trait::StandaloneServer';

has '+psgi_server' => (
    default => 'Twiggy'
);

has dsn => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has user => (
    is => 'ro',
    isa => 'Str',
);

has password => (
    is => 'ro',
    isa => 'Str',
);

sub build_app {
    my $self = shift;

    # XXX Make this configurable
    my $storage = Lyra::Server::Click::Storage::File->new(
        prefix => File::Spec->catfile(File::Spec->tmpdir, 'clickd.CHANGEME')
    );

    my $dbh = AnyEvent::DBI->new(
        $self->dsn,
        $self->user,
        $self->password,
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
    Lyra::Server::Click->new(
        dbh => $dbh,
        log_storage => $storage,
    )->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;

