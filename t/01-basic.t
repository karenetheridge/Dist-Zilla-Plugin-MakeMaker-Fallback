use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Fatal;
use Test::DZil;
use Test::Deep;
use Path::Tiny;
use Capture::Tiny 'capture';

{
    package Dist::Zilla::Plugin::BogusInstaller;
    use Moose;
    with 'Dist::Zilla::Role::InstallTool';
    sub setup_installer { }
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    'BogusInstaller',
                    'MakeMaker::Fallback',
                ),
            },
        },
    );

    like(
        exception { $tzil->build },
        qr/\Q[MakeMaker::Fallback] No Build.PL found to fall back from!\E/,
        'build aborted when no additional installer is provided',
    );
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ 'MakeMaker::Fallback' ],
                    [ 'ModuleBuildTiny' ],
                ),
            },
        },
    );

    $tzil->build;
    my $build_dir = path($tzil->tempdir)->child('build');

    my @expected_files = qw(
        Build.PL
        Makefile.PL
    );

    my @found_files;
    my $iter = $build_dir->iterator({ recurse => 1 });
    while (my $path = $iter->())
    {
        push @found_files, $path->relative($build_dir)->stringify if -f $path;
    }

    cmp_deeply(
        \@found_files,
        bag(@expected_files),
        'both Makefile.PL and Build.PL are generated',
    );

    my $Makefile_PL = path($tzil->tempdir)->child('build', 'Makefile.PL');
    my $Makefile_PL_content = $Makefile_PL->slurp_utf8;

    my $preamble = join('', <*Dist::Zilla::Plugin::MakeMaker::Fallback::DATA>);

    like($Makefile_PL_content, qr/\Q$preamble\E/ms, 'preamble is found in makefile');

    unlike(
        $Makefile_PL_content,
        qr/use\s+ExtUtils::MakeMaker\s/m,
        'ExtUtils::MakeMaker not used with VERSION',
    );

    like(
        $Makefile_PL_content,
        qr/^use ExtUtils::MakeMaker;$/m,
        'ExtUtils::MakeMaker is still used',
    );

    subtest 'ExtUtils::MakeMaker->VERSION not asserted (outside of an eval) either' => sub {
        while ($Makefile_PL_content =~ /^(.*)ExtUtils::MakeMaker\s*->\s*VERSION\s*\(\s*([\d._]+)\s*\)/mg)
        {
            like($1, qr/eval/, 'VERSION assertion (on ' . $2 . ') done inside an eval');
        }
        pass;
    };
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ 'GatherDir' ],
                    [ 'MakeMaker::Fallback' ],
                    [ 'ModuleBuildTiny' ],
                    [ 'MetaJSON' ],         # MBT requires a META.* file
                ),
                path(qw(source/t/test.t)) => "use Test::More tests => 1; pass('passing test');\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    my ($stdout, $stderr, @result) = capture {
        local $ENV{RELEASE_TESTING};
        local $ENV{AUTHOR_TESTING};
        $tzil->test;
    };

    $stdout =~ s/^/    /gm;
    print $stdout;

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            re(qr/\Q[MakeMaker::Fallback] doing nothing during test...\E/),
            re(qr/all's well/),
        ),
        'the test method does not die; correct diagnostics printed',
    ) or diag 'saw log messages: ', explain $tzil->log_messages;
}

done_testing;
