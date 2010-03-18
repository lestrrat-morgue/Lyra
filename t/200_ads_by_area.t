use strict;
use Test::More tests => 7;
use AnyEvent;
use AnyEvent::DBI;
use FindBin;
use t::Lyra::Test qw(async_dbh);

use_ok "Lyra::Server::AdEngine::ByArea";

{
    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh_dsn => $ENV{TEST_DSN},
        templates_dir => $FindBin::Bin . '/../templates',
    );

    my $lat = 34.616233;
    my $lng = 135.532560;

    my @range = Lyra::Util::calc_range( $lat, $lng, 2000 );
    is( 135.510858611, $range[0], 'lat(start)');
    is( 34.598253856, $range[1], 'lng(end)');
    is( 135.554261389, $range[2], 'lat(start)');
    is( 34.634212144, $range[3], 'lat(end)');

    my $js = $engine->_render_ads([
        ['foo','hogehoge'],
        ['bar','barbar']
    ]);    

    like($js, qr{target="_blank">bar</a> barbar</li>}, 'template 1');
    like($js, qr{document\.writeln\('</ul>'\);}, 'template 2');
}

{
    my $dbh = async_dbh();

    my $cv  = AE::cv {
        my $cv = shift;
        my $rows = $cv->recv;
        if (! is(scalar(@$rows), 4, "Expected number of ads") ) {
            diag( "Got these ads:\n", explain( $rows ) );
        }
    };
    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh => $dbh,
        templates_dir => $FindBin::Bin . '/../templates',
    );

    {
        my $lat   = 35.689265;
        my $lng   = 139.678481;
        my $range = 2000;
        my @range = Lyra::Util::calc_range( $lat, $lng, $range);

        # XXX Test   httpクライアントからテストした方がいいかな・・・
        $engine->load_ad( $cv, \@range );
    }

    $cv->recv;
}


