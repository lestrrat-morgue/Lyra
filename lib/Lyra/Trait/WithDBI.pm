package Lyra::Trait::WithDBI;
use Moose::Role;
use AnyEvent::DBI;
use namespace::autoclean;

has dbh => (
    is => 'ro',
    isa => 'AnyEvent::DBI',
    lazy_build => 1,
);

sub execsql {
    my $self = shift;
    $self->dbh->exec(@_);
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
        $self->execsql($sql, @binds, $cb);
    }


    MyClass->new(
        dbh => AnyEvent::DBI->new(
            $dsn,
            $username,
            $password,
            exec_server => 1, # recommended
            RaiseError => 1,
            AutoCommit => 1,
        )
    );

=head1 METHODS

=head2 execsql($sql, @binds, $cb->($dbh, $rows, $rv))

Simple delegate to AnyEvent::DBI::exec.

=cut
