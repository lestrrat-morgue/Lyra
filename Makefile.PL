use inc::Module::Install;

name 'Lyra';
all_from 'lib/Lyra.pm';

requires 'Moose';
requires 'MooseX::Getopt';
requires 'AnyEvent';
requires 'AnyEvent::DBI';
requires 'Cache::Memcached::AnyEvent';
requires 'URI';
requires 'namespace::autoclean';

requires 'Plack';
requires 'Twiggy';
requires 'Server::Starter';

build_requires 'Module::Install::Bundle::LocalLib';

# if you want to deploy the database schema
recommends 'DBIx::Class';

auto_set_repository;
bundle_local_lib;

WriteAll;