package App::Lyra::Clickd;
use Any::Moose;
use Lyra::Server::Click;
use Plack::Runner;
use namespace::autoclean;

with any_moose('X::Getopt');

has dbh_dsn => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub run {
    my $self = shift;

    my $runner = Plack::Runner->new(server => 'Twiggy', env => 'deployment');
    $runner->parse_options( 
    $runner->run( 
        Lyra::Server::Click->new(
            dbh_dsn => $self->dbh_dsn
        )->psgi_app
    )
    );
}

__PACKAGE__->meta->make_immutable();

1;

