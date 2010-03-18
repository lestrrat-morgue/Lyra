package Lyra::Schema::Result::AdsMaster;
use strict;
use warnings;
use base qw(Lyra::Schema::Result);

# Hold the master ad data. This table does not get used when searching.

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table('lyra_ads_master');
__PACKAGE__->add_columns(
    id => {
        data_type => 'CHAR',
        size      => 36,
        is_nullable => 0,
    },
    landing_uri => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    # XXX Title? isn't this the "label" ?
    title => {
        data_type => 'VARCHAR',
        size      => 64,
        is_nullable => 0,
    },
    content => {
        data_type => 'TEXT',
    },
    status  => {
        data_type => 'INT',
        is_nullable => 0,
    },
    location => {
        data_type => 'POINT',
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