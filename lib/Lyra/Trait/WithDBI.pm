package Lyra::Trait::WithDBI;
use Moose::Role;
use AnyEvent::DBI;
use namespace::autoclean;

has dbh => (
    is => 'ro',
    isa => 'AnyEvent::DBI',
    lazy_build => 1,
);

has dbh_dsn => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has dbh_user => (
    is => 'ro',
    isa => 'Str',
);

has dbh_password => (
    is => 'ro',
    isa => 'Str',
);

sub _build_dbh {
    my $self = shift;
    return AnyEvent::DBI->new(
        $self->dbh_dsn,
        $self->dbh_user,
        $self->dbh_password,
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
}

1;

__END__

=head1 NAME

Lyra::Trait::WithDBI - Adds Asynchronous DBI Access

=head1 SYNOPSIS

    package MyClass;
    use Moose;
    with 'Lyra::Trait::WithDBI';

    sub whatever {
        my $self = shift;
        $self->cache->exec($sql, @binds, $cb);
    }

=cut
