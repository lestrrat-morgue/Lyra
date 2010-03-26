use strict;
use Test::More tests => 3;

use_ok "App::Lyra::DeployAds";
use_ok "App::Lyra::DeployDB";

eval {
    # Deploy to master DB
    App::Lyra::DeployDB->new(
        data_source => 't::Lyra::Test::Fixture::TestDB',
    )->run();
};
ok(! $@, "Done deploy") or diag($@);
