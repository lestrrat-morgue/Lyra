#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include <math.h>

/* Original code, for reference */
/*
sub _calc_range {
    my ($self, $lat, $lng, $range) = @_;

    my @lat = split '\.', $lat;
    my %distance = (
        lat => sprintf('%.1f', 40054782 / (360*60*60)),
        lng => sprintf('%.1f', 6378150 * 
            cos($lat[0]/180*pi) * 2 * pi / (360*60*60)),
    ); 

    my %range;
    for my $key qw(lat lng) {
        $range{$key} = 
            sprintf('%.9f', (1/3600) * ($range/$distance{$key}));
    } 

    return (
        $lng - $range{lng},
        $lat - $range{lat},
        $lng + $range{lng},
        $lat + $range{lat},
    );
}
*/

MODULE = Lyra   PACKAGE = Lyra::Util PREFIX = LyraUtil_

PROTOTYPES: DISABLE

void
LyraUtil_calc_range( lat, lng, range );
        NV lat;
        NV lng;
        IV range;
    PREINIT:
        NV lat_dist, lng_dist, lat_range, lng_range;
    PPCODE:
        lat_dist = 40054782.0 / (360 * 60 * 60);
        lng_dist = 6378150.0 * cos(((IV) lat) / 180.0 * M_PI) * 2 * M_PI / (360 * 60 * 60);
        lat_range = (1.0/3600) * ( range / lat_dist);
        lng_range = (1.0/3600) * ( range / lng_dist);
#ifdef LYRA_DEBUG
        warn( "range = %d, lng = %0.6f, lng_dist = %f, lng_range = %f, lat = %f, lat_dist = %f, lat_range = %f",
            range, lng, lng_dist, lng_range, lat, lat_dist, lat_range );
#endif

        mPUSHn( lng - lng_range );
        mPUSHn( lat - lat_range );
        mPUSHn( lng + lng_range );
        mPUSHn( lat + lat_range );

