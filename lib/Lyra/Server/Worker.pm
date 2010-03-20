package Lyra::Server::Worker;
use Moose;
use Router::Simple;
use JSON::XS;
use namespace::autoclean;

use constant NO_SUCH_WORKER => 
    [ 404, [ "Content-Type" => "application/json" ],
        [ q|{ "status" => 0, "message" => "no such worker" }| ] ];
use constant BAD_PAYLOAD =>
    [ 500, [ "Content-Type" => "application/json" ],
        [ q|{ "status" => 0, "message" => "bad payload" }| ] ];
use constant WORKER_ERROR =>
    [ 500, [ "Content-Type" => "application/json" ],
        [ q|{ "status" => 0, "message" => "worker error" }| ] ];
use constant WORKER_SUCCESS =>
    [ 200, [ "Content-Type" => "application/json" ],
        [ q|{ "status" => 1 }| ] ];

has router => (
    is => 'ro',
    isa => 'Router::Simple',
    default => sub { Router::Simple->new() }
);

sub register {
    my ($self, $path, $worker, $method) = @_;
    $method ||= 'process';
    $self->router->connect( $path, { controller => $worker, action => $method } );
}

sub psgi_app {
    my $self = shift;
    return sub {
        $self->process(@_);
    }
}

sub process {
    my ($self, $env) = @_;

    my $matched = $self->router->match( $env );
    if (! $matched) {
        return NO_SUCH_WORKER;
    }

    my $payload;
    eval {
        $payload = $self->fetch_payload( $env );
    };
    if ($@) {
        warn $@;
        return BAD_PAYLOAD;
    }

    my $response;
    eval {
        my $worker = $matched->{controller};
        my $method = $matched->{action};
        $response = $worker->$method( $payload );
    };
    if ($@) {
        warn $@;
        return WORKER_ERROR;
    }

    if (! $response ) {
        $response = WORKER_SUCCESS;
    }

    return $response;
}

sub fetch_payload {
    my ($self, $env) = @_;

    if ($env->{REQUEST_METHOD} ne 'POST') {
        return;
    }

    my $cl = $env->{ CONTENT_LENGTH };
    my $ct = $env->{ CONTENT_TYPE };

    # $ct should be application/json, but we're not checking this right now
    
    my $input = $env->{ 'psgi.input' };

    # Just in case if input is read by middleware/apps beforehand
    $input->seek(0, 0);

    my $buffer = '';
    my $spin = 0;
    while ($cl > 0) {
        $input->read(my $chunk, $cl < 8192 ? $cl : 8192);
        my $read = length $chunk;
        $cl -= $read;
        $buffer .= $chunk;
        if ($read == 0 && $spin++ > 2000) {
            Carp::croak "Bad Content-Length: maybe client disconnect? ($cl bytes remaining)";
        }
    }

    decode_json $buffer;
}

__PACKAGE__->meta->make_immutable();

1;

# 