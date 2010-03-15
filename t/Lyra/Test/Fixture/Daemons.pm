package t::Lyra::Test::Fixture::Daemons;
use Moose;
use Test::mysqld;
use Test::Memcached;
use namespace::autoclean;

# call me from Makefile!
sub start {
    my $self = shift;

    # XXX Bad manners, but I'm pretty sure this is okay in this context
    $SIG{INT} = sub { CORE::exit };

    if (! $ENV{ TEST_DSN }) {
        my $mysql = Test::mysqld->new();
        $ENV{TEST_DSN} = $mysql->dsn();
        $self->{_mysql} = $mysql;
    }

    if ( ! $ENV{ TEST_MEMCACHED_PORT } ) {
        my $memd = Test::Memcached->new();
        $memd->start();
        $ENV{ TEST_MEMCACHED_PORT } = $memd->option('tcp_port' );

        $self->{_memcached} = $memd;
    }
}

sub stop {
    my $self = shift;

    delete $self->{ _mysql };
    delete $self->{ _memcached };
}

sub DEMOLISH {
    my $self = shift;
    $self->stop;
}

__PACKAGE__->meta->make_immutable();

1;