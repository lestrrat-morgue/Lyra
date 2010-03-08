package Clicking::Schema;
use strict;
use warnings;
use base qw(DBIx::Class::Schema);

__PACKAGE__->load_namespaces();

__END__

=head1 NAME 

Clicking::Schema - Database Schemas For Clicking

=head1 DESCRIPTION

This database schema is NOT used for the servers. The servers will do
asynchronous DB queries when required to do so.

=cut