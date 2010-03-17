use strict;
use Test::More tests => 7;
use FindBin;

use_ok "Lyra::Server::AdEngine::ByArea";

{
    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh_dsn => $ENV{TEST_DSN},
        templates_dir => $FindBin::Bin . '/../templates',
    );

    my $lat = 34.616233;
    my $lng = 135.532560;

    my @range = $engine->_calc_range( $lat, $lng, 2000 );
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
