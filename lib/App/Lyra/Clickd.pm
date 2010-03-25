package App::Lyra::Clickd;
use Moose;
use Lyra::Server::Click;
use Lyra::Log::Storage::File;
use File::Spec;
use namespace::autoclean;

with 'Lyra::Trait::StandaloneServer';

has '+psgi_server' => (
    default => 'Twiggy'
);

has hostname => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1',
);

has port => (
    is => 'ro',
    isa => 'Int',
    default => 27017
);

has dbname => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has username => (
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
    my $storage = Lyra::Log::Storage::File->new(
        prefix => File::Spec->catfile(File::Spec->tmpdir, 'clickd.CHANGEME')
    );

    my $conn = MongoDB::Connection->new(
        host => $self->hostname,
        port => $self->port
    );
    if ( $self->username && $self->password ) {
        $conn->authenticate( $self->dbname, $self->username, $self->password );
    }

    my $db = $conn->get_database('lyra');

    my $server = Lyra::Server::Click->new(
        db => $db,
        log_storage => $storage
    );
    return $server->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;

