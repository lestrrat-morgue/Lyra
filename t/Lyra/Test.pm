package t::Lyra::Test;
use strict;
use base qw(Exporter);
use AnyEvent::DBI;

our @EXPORT_OK = qw(async_dbh);

sub async_dbh {
    return AnyEvent::DBI->new(
        $ENV{TEST_DSN},
        $ENV{TEST_USERNAME},
        $ENV{TEST_PASSWORD},
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
}

1;