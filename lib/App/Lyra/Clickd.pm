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
    my $storage = Lyra::Log::Storage::File->new(
        prefix => File::Spec->catfile(File::Spec->tmpdir, 'clickd.CHANGEME')
    );

    my $cv = AE::cv;
    my $dbh = AnyEvent::DBI->new(
        $self->dsn,
        $self->user,
        $self->password,
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
        on_connect => sub {
            if ($_[1]) {
                $cv->send(
                Lyra::Server::Click->new(
                    dbh => $_[0],
                    log_storage => $storage,
                )->psgi_app );
            }
            else {
                warn $@;
                exit;
            }
        }
    );

    return $cv->recv;
}

__PACKAGE__->meta->make_immutable();

1;

