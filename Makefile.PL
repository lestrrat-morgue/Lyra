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
requires 'Math::Round';

build_requires 'Module::Install::Bundle::LocalLib';

test_requires 'Test::mysqld';
test_requires 'Test::Memcached';

# if you want to deploy the database schema
features(
    'Automatic DB Deployment' => [
        -default => 0,
        recommends ('DBIx::Class'),
        recommends ('DBIx::Class::TimeStamp'),
    ]
);

auto_install;
auto_set_repository;
bundle_local_lib;

WriteAll;

if (-f 'Makefile') {
    open (my $fh, '<', 'Makefile') or die "Could not open Makefile: $!";
    my $makefile = do { local $/; <$fh> };
    close $fh or die $!;

    $makefile =~ s/"-e" "(test_harness\(\$\(TEST_VERBOSE\), )/"-I\$(INST_LIB)" "-I\$(INST_ARCHLIB)" "-It\/lib" "-Mlocal::lib=extlib" "-MTest::mysqld" "-MTest::Memcached" "-e" "\\\$\$SIG{INT} = sub { CORE::exit }; my \\\$\$m = Test::mysqld->new(); \\\$\$ENV{TEST_DSN} = \\\$\$m->dsn(); my \\\$\$memd; if (! \\\$\$ENV{TEST_MEMCACHED_PORT} ) { \\\$\$memd = Test::Memcached->new(); \\\$\$memd->start(); \\\$\$ENV{TEST_MEMCACHED_PORT} = \\\$\$memd->option('tcp_port'); } $1't\/lib', 'base\/lib', /;

    open (my $fh, '>', 'Makefile') or die "Could not open Makefile: $!";
    print $fh $makefile;
    close $fh or die $!;
}
