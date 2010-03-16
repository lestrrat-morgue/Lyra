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
        $self->cache->exec($sql, @binds, $cb);
    }

=cut
