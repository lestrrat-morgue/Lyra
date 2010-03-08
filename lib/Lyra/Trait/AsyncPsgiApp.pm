package Lyra::Trait::AsyncPsgiApp;
use Any::Moose '::Role';
use namespace::autoclean;

requires 'process';

sub psgi_app {
    my $self = shift;
    return sub {
        my $env = shift;
        return sub {
            my $start_response = shift;
            $self->process($start_response, $env);
        }
    }
}

1;
