package App::Lyra::DeployDB;
use Moose;
use MongoDB;
use namespace::autoclean;

with 'MooseX::Getopt';

has hostname => (is => 'ro', isa => 'Str', default => '127.0.0.1');
has port     => (is => 'ro', isa => 'Int', default => 27017);
has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has data_source => (is => 'ro', isa => 'Str');

sub run {
    my $self = shift;

    my $mongodb = MongoDB::Connection->new(
        host => $self->hostname,
        port => $self->port
    );

    if (my $data_source = $self->data_source) {
        Class::MOP::load_class( $data_source );
        my $source = $data_source->new();
        $source->deploy( $mongodb );
    }
}

1;

__END__

=head1 NAME

App::Lyra::DeployDB - Deploy Database Schema

=head1 SYNOPSIS

    use App::Lyra::DeployDB;

    App::Lyra::DeployDB->new_with_options->run();

    # or explicitly
    App::Lyra::DeployDB->new(
        dsn => 'dbi:mysql:dbname=...',
        username => '...',
        password => '...',
        source => \@monikers, # if you want to selectively deploy
        drop_table => $bool, # if you want to add a DROP TABLE before CREATE TABLe
        schema_class => 'Lyra::Schema', # if you want to use a different schema
    )->run();

=cut
