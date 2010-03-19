package t::Lyra::Test;
use strict;
use base qw(Exporter);
use AnyEvent::DBI;
use Cache::Memcached::AnyEvent;
use t::Lyra::Test::Plackup;

our @EXPORT_OK = qw(async_dbh click_server adengine_byarea);

sub async_dbh(@) {
    return AnyEvent::DBI->new(
        $ENV{TEST_DSN},
        $ENV{TEST_USERNAME},
        $ENV{TEST_PASSWORD},
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
}

sub async_memcached(@) {
    return Cache::Memcached::AnyEvent->new(
        servers => [ "127.0.0.1:$ENV{ TEST_MEMCACHED_PORT }" ],
        compress_threshld => 10_000,
        namespace => join('.', 'lyra', 'test', $$, {}, rand())
    );
}

sub plackup(@) {
    my $plackup = t::Lyra::Test::Plackup->new(@_);
    $plackup->start or die "Could not start server";
    return $plackup;
}

sub click_server(@) {
    return plackup(
        base_dir => 't/',
        server => 'Twiggy',
        app => sub {
            require Lyra::Log::Storage::Null;
            require Lyra::Server::Click;

            Lyra::Server::Click->new(
                dbh => async_dbh(),
                log_storage => Lyra::Log::Storage::Null->new(),
            )->psgi_app
        },
        @_,
    );
}

sub adengine_byarea(@) {
    my %args = @_;
    my $click_uri = delete $args{click_server}
        or die "You need to specify a click server URL";
    return plackup(
        base_dir => 't/',
        server => 'Twiggy',
        app => sub {
            require Lyra::Log::Storage::Null;
            require Lyra::Server::AdEngine::ByArea;

            Lyra::Server::AdEngine::ByArea->new(
                dbh => async_dbh(),
                cache => async_memcached(),
                click_uri => $click_uri,
                request_log_storage => Lyra::Log::Storage::Null->new(),
                impression_log_storage => Lyra::Log::Storage::Null->new(),
            )->psgi_app
        },
        %args,
    );
}

1;