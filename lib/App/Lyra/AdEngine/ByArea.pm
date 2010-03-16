package App::Lyra::AdEngine::ByArea;
use Moose;
use Lyra::Server::AdEngine::ByArea;
use Lyra::Log::Storage::File;
use namespace::autoclean;

with 'Lyra::Trait::StandaloneServer';

has '+psgi_server' => (
    default => 'Twiggy'
);

has dsn => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has user => (
    is => 'ro',
    isa => 'Str',
);

has password => (
    is => 'ro',
    isa => 'Str',
);

sub build_log {
    my ($self, $prefix) = @_;

    my $class = "File";
    local @ARGV = @{ $self->extra_argv };
    Getopt::Long::GetOptions( "$prefix-log-class=s" => \$class );

    if ($class !~ s/^\+//) {
        $class = "Lyra::Log::Storage::$class";
    }

    if (! Class::MOP::is_class_loaded($class) ) {
        Class::MOP::load_class($class);
    }

    my $object;
    if ( $class->isa('Lyra::Log::Storage::File') ) {
        my $file_prefix = "adengine_byarea";
        Getopt::Long::GetOptions( "$prefix-log-prefix=s" => \$file_prefix );
        $object = $class->new(prefix => $file_prefix);
    } elsif ( $class->isa('Lyra::Log::Storage::Q4M') ) {
        my ($dsn, $username, $password, $sql);
        my $table = "${prefix}_log_queue";
        Getopt::Long::GetOptions( 
            "$prefix-log-dsn=s" => \$dsn,
            "$prefix-log-user=s" => \$username,
            "$prefix-log-password=s" => \$password,
            "$prefix-log-table=s" => \$table,
            "$prefix-log-sql=s" => \$sql,
        );

        my %args = (
            dbh => AnyEvent::DBI->new(
                $dsn,
                $username,
                $password,
                exec_server => 1,
                RaiseError => 1,
                AutoCommit => 1,
            )
        );
        $args{table} = $table if defined $table;
        $args{sql} = $table if defined $table;
        $object = $class->new(%args);
    }

    return $object;
}


sub build_app {
    my $self = shift;

    # XXX make it possible to change the storage type depending on
    # command line parameters
    my $request_log = $self->build_log( 'request' );
    my $impression_log = $self->build_log( 'impression' );

    my $dbh = AnyEvent::DBI->new(
        $self->dsn,
        $self->user,
        $self->password,
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
    Lyra::Server::AdEngine::ByArea->new(
        dbh => $dbh,
        request_log_storage => $request_log,
        impression_log_storage => $impression_log,
    )->psgi_app;
}

__PACKAGE__->meta->make_immutable();

1;

__END__

=head1 NAME

App::Lyra::AdEngine::ByArea - Area-based AdEngine

=head1 SYNOPSIS

    lyra_adengine_byarea --dsn=dbi:mysql:dbname=lyra 

    # if you need to pass PSGI parameters, do so after --
    lyra_adengine_byarea \
        --dsn=dbi:mysql:dbname=lyra  \
        -- \
        --port=9999

=cut
