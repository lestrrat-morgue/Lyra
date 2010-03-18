package App::Lyra::DeployAds;
use Moose;
use POSIX ();
use Lyra::Schema;
use namespace::autoclean;

with 'MooseX::Getopt';

has dsn => (is => 'ro', isa => 'Str', required => 1, default => $ENV{TEST_DSN});
has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');

sub run {
    my $self = shift;

    my $schema = Lyra::Schema->connect(
        $self->dsn,
        $self->username || $ENV{TEST_USERNAME},
        $self->password || $ENV{TEST_PASSWORD},
        { RaiseError => 1, AutoCommit => 1 }
    );

    # Deploy a Dummy Table. This is a bit tricky
    my $source = $schema->source('AdsByArea');

    my $real_table = $source->from();
    my $temp_table = POSIX::strftime('ads_by_area_%Y%m%d%H%M%S', localtime);
    $source->name( $temp_table );

    my $guard = $schema->txn_scope_guard();
    $schema->deploy(
        {
            quote_field_names => 0,
            sources => [ 'AdsByArea' ]
        }
    );
    $source->name( $real_table );

    my $master_source = $schema->resultset('AdsMaster')->result_source;
    my $master_table  = $master_source->from;

    my $dbh = $schema->storage->dbh;
    $dbh->do( "INSERT INTO $temp_table SELECT * FROM $master_table");
    $dbh->do( "RENAME TABLE $real_table TO ${real_table}_old, $temp_table TO $real_table" );
    $guard->commit;
}

1;
