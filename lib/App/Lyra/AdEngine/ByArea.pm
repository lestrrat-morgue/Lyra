package App::Lyra::AdEngine::ByArea;
use Moose;
use Lyra::Server::AdEngine::ByArea;
use Lyra::Log::Storage::File;
use namespace::autoclean;

with 'Lyra::Trait::StandaloneServer';

has '+psgi_server' => (
    default => 'Twiggy'
);

has click_uri => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has hostname => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1',
);

has port => (
    is => 'ro',
    isa => 'Int',
    default => 27017
);

has dbname => (
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

    my $disable = 0;
    my $class = "File";
    local @ARGV = @{ $self->extra_argv };
    Getopt::Long::GetOptions(
        "$prefix-log-class=s" => \$class,
        "$prefix-log-disable!" => \$disable
    );

    if ($disable) {
        $class = "Lyra::Log::Storage::Null";
    } elsif ($class !~ s/^\+//) {
        $class = "Lyra::Log::Storage::$class";
    }

    if (! Class::MOP::is_class_loaded($class) ) {
        Class::MOP::load_class($class);
    }

    my $object;
    if ( $class->isa('Lyra::Log::Storage::File') ) {
        my $file_prefix = "adengine_byarea_$prefix";
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
    } else {
        $object = $class->new();
    }

    return $object;
}


sub build_app {
    my $self = shift;

    # XXX make it possible to change the storage type depending on
    # command line parameters
    my $request_log = $self->build_log( 'request' );
    my $impression_log = $self->build_log( 'impression' );

    my $cv = AE::cv;
    my $dbh = AnyEvent::MongoDB->new(
        host => $self->hostname,
        port => $self->port,
        exec_server => 1,
        on_connect => sub {
            my $db = shift;
            $cv->send( 
                Lyra::Server::AdEngine::ByArea->new(
                    db => $db,
                    click_uri => $self->click_uri,
                    templates_dir => './templates',
                    request_log_storage => $request_log,
                    impression_log_storage => $impression_log,
                )->psgi_app
            );
        }
    );

    return $cv->recv;
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
