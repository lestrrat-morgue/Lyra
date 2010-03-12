package Lyra::Schema::Result::AdsByArea;
use strict;
use warnings;
use base qw(Lyra::Schema::Result);

__PACKAGE__->mk_classdata(engine => 'MyISAM');
__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table('lyra_ads_by_area');
__PACKAGE__->add_columns(
    id => {
        data_type => 'CHAR',
        size      => 10,
        is_nullable => 0,
    },
    title => {
        data_type => 'VARCHAR',
        size      => 64,
    },
    content => {
        data_type => 'TEXT',
    },
    status  => {
        data_type => 'INT',
        is_nullable => 0,
    },
    location => {
        data_type => 'geometry',
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
__PACKAGE__->add_unique_constraint( 'unique_id' => [ 'id' ] );

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $self->next::method($sqlt_table);
    $sqlt_table->add_index(
        type => 'SPATIAL',
        name => 'lyra_ads_by_area_location_idx',
        fields => [ 'location' ]
    );
}

1;
