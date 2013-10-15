use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Fatal;
use Test::DZil;
use Test::Deep;
use Path::Tiny;
use File::Find;
use File::Spec;

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                'source/dist.ini' => simple_ini(
                    [ 'MakeMaker::Fallback' ],
                ),
            },
        },
    );

    like(
        exception { $tzil->build },
        qr/\Q[MakeMaker::Fallback] another InstallTool plugin is required!\E/,
        'build aborted when no additional installer is provided',
    );
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                'source/dist.ini' => simple_ini(
                    [ 'MakeMaker::Fallback' ],
                    [ 'ModuleBuildTiny' ],
                ),
            },
        },
    );

    $tzil->build;
    my $build_dir = $tzil->tempdir->subdir('build');

    my @expected_files = qw(
        Build.PL
        Makefile.PL
    );

    my @found_files;
    find({
            wanted => sub { push @found_files, File::Spec->abs2rel($_, $build_dir) if -f  },
            no_chdir => 1,
         },
        $build_dir,
    );

    cmp_deeply(
        \@found_files,
        bag(@expected_files),
        'both Makefile.PL and Build.PL are generated',
    );

    my $Makefile_PL = path($tzil->tempdir->subdir('build'), 'Makefile.PL');
    my $Makefile_PL_content = $Makefile_PL->slurp;

    my $preamble = join('', <*Dist::Zilla::Plugin::MakeMaker::Fallback::DATA>);

    like($Makefile_PL_content, qr/\Q$preamble\E/ms, 'preamble is found in makefile');
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does_not_exist' },
        {
            add_files => {
                'source/dist.ini' => simple_ini(
                    [ 'GatherDir' ],
                    [ 'MakeMaker::Fallback' ],
                    [ 'ModuleBuildTiny' ],
                    [ 'MetaJSON' ],         # MBT requires a META.* file
                ),
                path(qw(source/t/test.t)) => "use Test::More tests => 1; pass('passing test');\n",
            },
        },
    );

    $tzil->test;

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            re(qr/all's well/),
        ),
       'the test method does not die',
    );
}

done_testing;
