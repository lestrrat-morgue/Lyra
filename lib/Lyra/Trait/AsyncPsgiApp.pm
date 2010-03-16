package Lyra::Trait::AsyncPsgiApp;
use Moose::Role;
use namespace::autoclean;

requires 'process';

sub psgi_app {
    my $self = shift;
    return sub {
        my $env = shift;

        if (! $env->{'psgi.streaming'}) {
            return [ 500, ["Content-Type" => "text/plain"], "Internal Server Error (Server Implementation Mismatch)" ];
        }

        return sub {
            my $start_response = shift;
            $self->process($start_response, $env);
        }
    }
}

1;
