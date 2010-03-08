use inc::Module::Install;

name 'Lyra';
all_from 'lib/Lyra.pm';

requires 'Any::Moose';
requires 'AnyEvent';
requires 'AnyEvent::DBI';
requires 'Cache::Memcached::AnyEvent';
requires 'URI';
requires 'namespace::autoclean';

requires 'Plack';
requires 'Twiggy';
requires 'Server::Starter';

# if you want to deploy the database schema
recommends 'DBIx::Class';

auto_set_repository;
bundle_local_lib;

WriteAll;