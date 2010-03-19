package t::Lyra::Test::Plackup;
use strict;
use warnings;
use Class::Accessor::Lite;
use Cwd;
use File::Temp qw(tempdir);
use IO::Socket::INET;
use Plack::Runner;
use Time::HiRes;

# process does not die when received SIGTERM, on win32.
my $TERMSIG = $^O eq 'MSWin32' ? 'KILL' : 'TERM';

my %DEFAULTS = (
    name       => 'plackup',
    base_dir   => undef,
    pid        => undef,
    _owner_pid => undef,
    port       => undef,
    server     => 'HTTP::Server::PSGI',
    options    => undef,
);

Class::Accessor::Lite->mk_accessors(keys %DEFAULTS);

sub new {
    my $class = shift;
    my $self  = bless {
        %DEFAULTS,
        @_ == 1 ? %{ $_[0] } : @_,
        _owner_pid => $$,
    }, $class;

    if (defined $self->base_dir) {
        $self->base_dir(cwd . '/' . $self->base_dir)
            if $self->base_dir !~ m|^/|;
    } else {
        $self->base_dir(
            tempdir(
                CLEANUP => $ENV{TEST_PLACKUP_PRESERVE} ? undef : 1,
            ),
        );
    }

    return $self;
}


sub start {
    my $self = shift;

    return if defined $self->pid;

    # find a port
    my $port = 10000;
    $port = 19000 unless $port =~ /^[0-9]+$/ && $port < 19000;

    while ( $port++ < 20000 ) {
        my $sock = IO::Socket::INET->new(
            Listen    => 5,
            LocalAddr => '127.0.0.1',
            LocalPort => $port,
            Proto     => 'tcp',
            (($^O eq 'MSWin32') ? () : (ReuseAddr => 1)),
        );
        last if $sock;
    }
    die "empty port not found" unless $port;

    unshift @{ $self->{options} }, ("--host=127.0.0.1", "--port=$port");

    open my $logfh, '>>', $self->base_dir . "/$self->{name}.log"
        or die 'failed to create log file:' . $self->base_dir
            . "/$self->{name}.log:$!";
    my $pid = fork;
    die "fork(2) failed:$!"
        unless defined $pid;
    if ($pid == 0) {
        open STDOUT, '>&', $logfh
            or die "dup(2) failed:$!";
        open STDERR, '>&', $logfh
            or die "dup(2) failed:$!";
        close $logfh;
        my $plack = Plack::Runner->new(server => $self->{server}, env => 'development');
        $plack->parse_options( @{$self->{options}} );
        if (my $cb = $self->{app}) {
            $plack->run($cb->());
        } else {
            $plack->run();
        }
        exit;
    }

    _wait_port( $port );
    $self->port( $port );
    $self->pid( $pid );
}

sub stop {
    my ($self, $sig) = @_;

    return unless defined $self->pid;
    $sig ||= $TERMSIG;
    kill $sig, $self->pid;

    local $?;
    while (waitpid($self->pid, 0) <= 0) {
    }

    $self->pid(undef);
}

sub DESTROY {
    my $self = shift;
    $self->stop
        if defined $self->pid && $$ == $self->_owner_pid;
}

sub _check_port {
    my ($port) = @_;

    my $remote = IO::Socket::INET->new(
        Proto    => 'tcp',
        PeerAddr => '127.0.0.1',
        PeerPort => $port,
    );
    if ($remote) {
        close $remote;
        return 1;
    }
    else {
        return 0;
    }
}

sub _wait_port {
    my $port = shift;

    my $retry = 100;
    while ( $retry-- ) {
        return if _check_port($port);
        Time::HiRes::sleep(0.1);
    }
    die "cannot open port: $port";
}

1;
