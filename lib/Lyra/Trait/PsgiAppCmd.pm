package Lyra::Trait::PsgiAppCmd;
use Moose::Role;
use Plack::Runner;
use namespace::autoclean;

with 'MooseX::Getopt';

has psgi_server => (
    traits => [ 'NoGetopt' ],
    is => 'ro',
    required => 1,
);

sub run {
    my $self = shift;

    my $runner = Plack::Runner->new(server => $self->psgi_server, env => $ENV{PSGI_ENV} || 'deployment');
    $runner->parse_options( @{ $self->extra_argv } );
    $runner->run( $self->build_app );
}

1;
