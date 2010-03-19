use strict;
use Test::More tests => 1;
use URI;
use t::Lyra::Test qw(start_daemons click_server adengine_byarea find_program);

my $ab = $ENV{TEST_AB} || find_program('ab') ||
    die "Could not find 'ab' program for testing";
my $ab_params = $ENV{TEST_AB_PARAMS} || '-n 1000 -c 100';

my $guard;
if (! $ENV{TEST_DSN} || ! $ENV{TEST_MEMCACHED_PORT}) {
    $guard = start_daemons();
    subtest 'deploy' => sub {
        require 't/001_deploy.t';
    };
}

my $click_server = click_server
    base_dir => 'xt',
    name => 'benchmark_click_server',
;

my $adengine = adengine_byarea
    base_dir => 'xt',
    click_server => "http://127.0.0.1:" . $click_server->port,
    name => 'benchmark_adengine',
;

my $ad_engine_url = URI->new("http://127.0.0.1");
$ad_engine_url->port($adengine->port);
$ad_engine_url->path("/");
$ad_engine_url->query_form(
    lat => 35.678603,
    lng => 139.67450,
);

diag( "Running benchmarks....");
my $output = qx($ab $ab_params '$ad_engine_url');
ok($? == 0);
diag( "Benchmark done, waiting for cleanup" );
$guard->stop;

diag( $output );
