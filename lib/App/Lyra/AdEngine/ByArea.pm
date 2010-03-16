package App::Lyra::AdEngine::ByArea;
use Moose;
use Lyra::Server::AdEngine::ByArea;
use Lyra::Log::Storage::File;
use namespace::autoclean;

with 'Lyra::Trait::PsgiAppCmd'; # StandaloneServer';

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
    required => 1,
);

sub build_app {
    my $self = shift;

    # XXX make it possible to change the storage type depending on
    # command line parameters
    my $request_log = Lyra::Log::Storage::File->new();
    my $impression_log = Lyra::Log::Storage::File->new();


    Lyra::Server::AdEngine::ByArea->new(
        dbh_dsn => $self->dsn,
        dbh_user => $self->user,
        request_log_storage => $request_log,
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
