package App::Lyra::DeployDB;
use Moose;
use namespace::autoclean;

with 'MooseX::Getopt';

has dsn => (is => 'ro', isa => 'Str', required => 1, default => $ENV{TEST_DSN});
has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has source => (is => 'ro', isa => 'ArrayRef', predicate => 'has_source');
has drop_table => (is => 'ro', isa => 'Bool', default => 0);
has schema_class => (is => 'ro', isa => 'Str', default => 'Lyra::Schema');
has data_source => (is => 'ro', isa => 'Str');

sub run {
    my $self = shift;

    my $schema_class = $self->schema_class;
    if (! Class::MOP::is_class_loaded( $schema_class ) ) {
        Class::MOP::load_class( $schema_class );
    }

    my %deploy_args = (
        add_drop_table => $self->drop_table,
        quote_field_names => 0,
    );
    if ( $self->has_source ) {
        $deploy_args{ sources } = $self->source;
    }

    my $schema = $schema_class->connect(
        $self->dsn,
        $self->username || $ENV{TEST_USERNAME},
        $self->password || $ENV{TEST_PASSWORD},
        { RaiseError => 1, AutoCommit => 1 }
    );
    $schema->deploy(\%deploy_args);

    if (my $data_source = $self->data_source) {
        Class::MOP::load_class( $data_source );
        my $source = $data_source->new();
        $source->deploy( $schema );
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
