use inc::Module::Install;

name 'Lyra';
all_from 'lib/Lyra.pm';

requires 'Moose';
requires 'MooseX::Getopt';
requires 'AnyEvent';
requires 'AnyEvent::DBI';
requires 'Cache::Memcached::AnyEvent';
requires 'Math::Trig';
requires 'Math::Round';
requires 'URI';
requires 'namespace::autoclean';

requires 'Plack';
requires 'Twiggy';
requires 'Server::Starter';

build_requires 'Module::Install::Bundle::LocalLib';

test_requires 'Test::mysqld';
test_requires 'Test::Memcached';

# if you want to deploy the database schema
features(
    'Automatic DB Deployment' => [
        -default => 0,
        recommends ('DBIx::Class'),
        recommends ('DBIx::Class::TimeStamp'),
    ],
    'File Based Storage For Logs' => [
        -default => 0,
        recommends ('AnyEvent::AIO'),
        recommends ('IO::AIO'),
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

    $makefile =~ s/"-e" "(test_harness\(\$\(TEST_VERBOSE\), )/"-I\$(INST_LIB)" "-I\$(INST_ARCHLIB)" "-It\/lib" "-Mlocal::lib=extlib" "-Mt::Lyra::Test::Fixture::Daemons" "-e" "my \\\$\$daemon = t::Lyra::Test::Fixture::Daemons->new(); \\\$\$daemon->start(); $1't\/lib', 'base\/lib', /;

    open (my $fh, '>', 'Makefile') or die "Could not open Makefile: $!";
    print $fh $makefile;
    close $fh or die $!;
}
