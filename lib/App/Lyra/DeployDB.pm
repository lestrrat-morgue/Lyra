package App::Lyra::DeployDB;
use Moose;
use namespace::clean;

with 'MooseX::Getopt';

has dsn => (is => 'ro', isa => 'Str', required => 1);
has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has source => (is => 'ro', isa => 'ArrayRef', predicate => 'has_source');
has drop_table => (is => 'ro', isa => 'Bool', default => 0);
has schema_class => (is => 'ro', isa => 'Str', default => 'Lyra::Schema');

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

    my $schema = $schema_class->connect( $self->dsn, $self->username, $self->password );
    $schema->deploy(\%deploy_args);
}

1;