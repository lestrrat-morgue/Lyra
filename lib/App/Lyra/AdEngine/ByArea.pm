package App::Lyra::AdEngine::ByArea;
use Moose;
use Lyra::Server::AdEngine::ByArea;
use Lyra::Log::Storage::File;
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

    # XXX make it possible to change the storage type depending on
    # command line parameters
    my $request_log = Lyra::Log::Storage::File->new();
    my $impression_log = Lyra::Log::Storage::File->new();

    my $dbh = AnyEvent::DBI->new(
        $self->dsn,
        $self->user,
        $self->password,
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
    Lyra::Server::AdEngine::ByArea->new(
        dbh => $dbh,
        impression_log_storage => $impression_log,
    )->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;

__END__

=head1 NAME

App::Lyra::AdEngine::ByArea - Area-based AdEngine

=head1 SYNOPSIS

    lyra_adengine_byarea --dsn=dbi:mysql:dbname=lyra 

    # if you need to pass PSGI parameters, do so after --
    lyra_adengine_byarea \
        --dsn=dbi:mysql:dbname=lyra  \
        -- \
        --port=9999

=cut
