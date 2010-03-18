use strict;
use Test::More tests => 7;
use AnyEvent;
use AnyEvent::DBI;
use FindBin;
use t::Lyra::Test qw(async_dbh);

use_ok "Lyra::Server::AdEngine::ByArea";

sub test_ad_loading (@) {
    my ($lat, $lng, $range, $cb) = @_;

    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh => async_dbh(),
        click_uri => "http://127.0.0.1:9999",
        template_dir => $FindBin::Bin . '/../templates',
    );
    my $cv = AE::cv {
        $cb->( shift->recv );
    };
    my @range = Lyra::Util::calc_range( $lat, $lng, $range );
    $engine->load_ad( $cv, @range );
    $cv->recv;
}


{
    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh_dsn => $ENV{TEST_DSN},
        click_uri => "http://127.0.0.1:9999",
        templates_dir => $FindBin::Bin . '/../templates',
    );

    my $lat = 34.616233;
    my $lng = 135.532560;

    my @range = Lyra::Util::calc_range( $lat, $lng, 2000 );
    ok( abs(135.510858611 - $range[0]) < 0.0005, 'lat(start)');
    ok( abs(34.598253856 - $range[1]) < 0.0005, 'lng(end)');
    ok( abs(135.554261389 - $range[2]) < 0.0005, 'lat(start)');
    ok( abs(34.634212144 - $range[3]) < 0.0005, 'lat(end)');
}

{
    test_ad_loading 35.689265, 139.678481, 2000, sub {
        my $rows = shift;
        if (! is(scalar(@$rows), 3, "Expected number of ads 1") ) {
            diag( "Got these ads:\n", explain( $rows ) );
        }
    };
}

{ # 幡ヶ谷中心
    test_ad_loading 35.678603, 139.67450, 2500, sub {
        my $rows = shift;
        if (! is(scalar(@$rows), 4, "Expected number of ads 2") ) {
            diag( "Got these ads:\n", explain( $rows ) );
        }
    };
}

