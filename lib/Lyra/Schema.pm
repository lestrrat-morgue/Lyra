package Lyra::Schema;
use strict;
use warnings;
use base qw(DBIx::Class::Schema);

__PACKAGE__->load_namespaces();

1;

__END__

=head1 NAME 

Lyra::Schema - Database Schemas For Lyra

=head1 DESCRIPTION

This database schema is NOT used for the servers. The servers will do
asynchronous DB queries when required to do so.

=cut