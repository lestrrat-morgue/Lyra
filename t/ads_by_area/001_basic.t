use strict;
use Test::More tests => 3;

use_ok "Lyra::Server::AdEngine::ByArea";

{
    my $engine = 'Lyra::Server::AdEngine::ByArea';

    my $lat = 34.616233;
    my $lng = 135.532560;

    is( $engine->_convert_to_degree(
            $engine->_convert_to_msec($lat)
        ), $lat, 'convert coordinate 1' );

    is( $engine->_convert_to_degree(
            $engine->_convert_to_msec($lng)
        ), $lng, 'convert coordinate 2' );
    
}

