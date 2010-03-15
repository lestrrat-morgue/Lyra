package Lyra::Schema::Result::ClickLog;
use strict;
use warnings;
use base qw(Lyra::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table('lyra_click_log');
__PACKAGE__->add_columns(
    id => {
        data_type => 'CHAR',
        size      => 10,
        is_nullable => 0,
    },
    landing_uri => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    created_on => {
        data_type => 'DATETIME',
        set_on_create => 1,
    },
    modified_on => {
        data_type => 'TIMESTAMP',
        set_on_create => 1,
        set_on_update => 1,
    }
);
__PACKAGE__->set_primary_key('id');

1;