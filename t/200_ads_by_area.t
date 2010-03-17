use strict;
use Test::More tests => 7;
use AnyEvent;
use AnyEvent::DBI;
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


{
    my $cv  = AE::cv {};
    my $dbh = AnyEvent::DBI->new(
        $ENV{TEST_DSN},
        '',
        '',
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );

    while( my $sql = <DATA> ) {
        chomp($sql);
        $cv->begin;
        $dbh->exec ($sql, sub { $cv->end; });
    } 
   
    $cv->wait; 

    my $engine = Lyra::Server::AdEngine::ByArea->new(
        dbh => $dbh,
        templates_dir => $FindBin::Bin . '/../templates',
    );

    {
        my $lat   = 35.689265;
        my $lng   = 139.678481;
        my $range = 2000;
        my @range = $engine->_calc_range( $lat, $lng, $range);

        # XXX Test   httpクライアントからテストした方がいいかな・・・
        $engine->load_ad( $cv, \@range );
    }

    $dbh->exec('delete from lyra_ads_by_area', sub{ $cv->send });
}

__DATA__
INSERT INTO lyra_ads_by_area VALUES('test_ads_by_area001',  'http://127.0.0.1/test_ads_by_area001', 'オペラシティ', '最寄り駅は初台です',  1, GeomFromText('POINT(139.685945 35.683616)'), now(), now());
INSERT INTO lyra_ads_by_area VALUES('test_ads_by_area002',  'http://127.0.0.1/test_ads_by_area002', 'NTT東日本', '最寄り駅は初台です',  1, GeomFromText('POINT(139.678481 35.689265)'), now(), now());
INSERT INTO lyra_ads_by_area VALUES('test_ads_by_area003',  'http://127.0.0.1/test_ads_by_area003', '幡ヶ谷駅', '初台のとなりです',  1, GeomFromText('POINT(139.674506 35.678603)'), now(), now());
INSERT INTO lyra_ads_by_area VALUES('test_ads_by_area004',  'http://127.0.0.1/test_ads_by_area004', '明治大学', '最寄り駅は明大前です',  1, GeomFromText('POINT(139.641874 35.675566)'),now(), now());
