package Lyra::Extlib;
use strict;
use Cwd ();
use File::Spec;
use File::Basename ();
our $BASE;

sub find_base {
    my $package = __PACKAGE__;
    $package =~ s/::/\//g;
    $package =~ s/$/\.pm/;

    my $path = $INC{ $package };
    my $base;

    if ($ENV{HARNESS_ACTIVE}) {
        # I'm at $HOME/blib/lib/Lyra
        #         (0) (1)  (2)  (3)
        # that's 4 directories up
        $base = File::Spec->catdir(
            File::Basename::dirname($path),
            File::Spec->updir,
            File::Spec->updir,
            File::Spec->updir,
        );
    } else {
        # I'm at $HOME/lib/Lyra
        #         (0)  (1)  (2)
        # that's 3 directories up
        $base = File::Spec->catdir(
            File::Basename::dirname($path),
            File::Spec->updir,
            File::Spec->updir,
        );
    }
    return Cwd::realpath( $base );
}

sub extlib (&;$) {
    local $BASE = @_ >= 2 ? pop : find_base();
    $_[0]->();
    unshift @INC, File::Spec->catfile($BASE, 'lib');
}

sub submodule (@) {
    unshift @INC,
        map { File::Spec->catdir( $BASE, 'module', $_, 'lib' ) } @_;
}

sub locallib (@) {
    my @paths = @_ ?  @_ : (File::Spec->catdir( $BASE, 'extlib' ) );
    require local::lib;
    foreach my $path (@paths) {
        local::lib->import( $path );
    }
}

BEGIN {
    extlib {
        locallib;
    };
}

1;
