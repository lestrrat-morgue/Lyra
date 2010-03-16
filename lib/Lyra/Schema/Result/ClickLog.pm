package Lyra::Schema::Result::ClickLog;
use strict;
use warnings;
use base qw(Lyra::Schema::Result);

__PACKAGE__->engine( 'QUEUE' );
__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table('lyra_click_log');
__PACKAGE__->add_columns(
    ad_id => {
        data_type => 'CHAR',
        size      => 36,
        is_nullable => 0,
    },
    data => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    created_on => {
        data_type => 'DATETIME',
        set_on_create => 1,
    }
);

1;