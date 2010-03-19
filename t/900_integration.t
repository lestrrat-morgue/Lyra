use strict;
use Test::More tests => 1;
use t::Lyra::Test qw(async_dbh click_server adengine_byarea);
use t::Lyra::Test::Plackup;
use Lyra::Log::Storage::Null;

my $click_server = click_server
    name => '900_integration_click_server',
;

my $adengine = adengine_byarea
    click_server => "http://127.0.0.1:" . $click_server->port,
    name => '900_integration_adengine',
;

ok(1);
