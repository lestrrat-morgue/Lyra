package t::Lyra::Test;
use strict;
use base qw(Exporter);
use AnyEvent::DBI;
use Cache::Memcached::AnyEvent;
use t::Lyra::Test::Plackup;
use t::Lyra::Test::Fixture::Daemons;

our @EXPORT_OK = qw(start_daemons async_dbh click_server adengine_byarea find_program);

sub null_log {
    require Lyra::Log::Storage::Null;
    Lyra::Log::Storage::Null->new();
}

sub start_daemons(@) {
    my $guard = t::Lyra::Test::Fixture::Daemons->new();
    $guard->start();
    return $guard;
}

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
            require Lyra::Server::Click;

            Lyra::Server::Click->new(
                dbh => async_dbh(),
                log_storage => null_log(),
            )->psgi_app
        },
        @_,
    );
}

sub adengine_byarea(@) {
    my %args = @_;
    my $click_uri = delete $args{click_server}
        or die "You need to specify a click server URL";
    my $templates_dir = delete $args{templates_dir} || 'templates';
    my $request_log = delete $args{request_log};
    my $impression_log = delete $args{impression_log};
    return plackup(
        base_dir => 't/',
        server => 'Twiggy',
        app => sub {
            require Lyra::Server::AdEngine::ByArea;

            Lyra::Server::AdEngine::ByArea->new(
                dbh => async_dbh(),
                cache => async_memcached(),
                click_uri => $click_uri,
                request_log_storage => $request_log || null_log(),
                impression_log_storage => $impression_log || null_log(),
                templates_dir => $templates_dir,
            )->psgi_app
        },
        %args,
    );
}

sub find_program($) {
    my $prog = shift;
    my $path = _get_path_of($prog);
    return $path
        if $path;
    die "could not find $prog, please set appropriate PATH";
}

sub _get_path_of {
    my $prog = shift;
    my $path = `which $prog 2> /dev/null`;
    chomp $path
        if $path;
    $path = ''
        unless -x $path;
    $path;
}


1;