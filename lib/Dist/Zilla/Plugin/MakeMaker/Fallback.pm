use strict;
use warnings;
package Dist::Zilla::Plugin::MakeMaker::Fallback;
# ABSTRACT: Generate a Makefile.PL containing a warning for legacy users
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
extends 'Dist::Zilla::Plugin::MakeMaker::Awesome' => { -version => '0.13' };
with 'Dist::Zilla::Role::BeforeBuild';

use version;
use namespace::autoclean;

sub before_build
{
    my $self = shift;

    my @installers = @{$self->zilla->plugins_with(-InstallTool)};
    @installers > 1 or $self->log_fatal('another InstallTool plugin is required!');
}

around _build_MakeFile_PL_template => sub
{
    my $orig = shift;
    my $self = shift;

    my $configure_requires = $self->zilla->prereqs->as_string_hash->{configure}{requires};

    # prereq specifications don't always provide exact versions - we just weed
    # those out for now, as this shouldn't occur that frequently.
    my %check_modules = map {
        version::is_strict($configure_requires->{$_})
            ? ( $_ => $configure_requires->{$_} )
            : ()
    } keys %$configure_requires;

    my $code = <<'CODE'
BEGIN {
my %configure_requires = (
CODE
        . join('', map {
                "    '$_' => '$configure_requires->{$_}',\n"
            } keys %$configure_requires)
    . <<'CODE'
);

my @missing = grep {
    ! eval "require $_; $_->VERSION($configure_requires{$_}); 1"
} keys %configure_requires;

if (not @missing)
{
    print "Congratulations, your toolchain understands 'configure_requires'!\n\n";
}
else
{
    warn <<'EOW';
CODE
        . join('', <DATA>)
        . "\nEOW\n\n    sleep 10 if -t STDIN && (-t STDOUT || !(-f STDOUT || -c STDOUT));\n}\n}\n\n";

    my $string = $self->$orig(@_);

    # splice in our stuff after the preamble bits
    $string =~ m/use warnings;\n\n/g;
    return substr($string, 0, pos($string)) . $code . substr($string, pos($string));
};

sub build
{
    my $self = shift;
    $self->log_debug('doing nothing during build...');
}

sub test
{
    my $self = shift;
    $self->log_debug('doing nothing during test...');
}

__PACKAGE__->meta->make_immutable;

=pod

=for Pod::Coverage before_build build test

=head1 SYNOPSIS

In your F<dist.ini>, when you want to ship a F<Build.PL> as well as a fallback
F<Makefile.PL> in case the user's C<cpan> client is so old it doesn't recognize
C<configure_requires>:

    [ModuleBuildTiny]
    [MakeMaker::Fallback]

=head1 DESCRIPTION

This plugin is a derivative of C<[MakeMaker]>, generating a F<Makefile.PL> in
your dist, with an added preamble that is printed when it is run:

=over 4

=for comment This section was inserted from the DATA section at build time

{{ $DATA }}

=back

=for stopwords functionalities

Additionally, the C<build> and C<test> functionalities of the plugin
(C<< perl Makefile.PL && make >> and C<< make test >> respectively) are disabled.

It is a fatal error to use this plugin when there is not also another
C<InstallTool> plugin installed (for example, C<[ModuleBuildTiny]>), that must
not also generate a F<Makefile.PL>.

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-MakeMaker-Fallback>
(or L<bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org|mailto:bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

=for stopwords Peter Rabbitson ribasushi Matt Trout mst

Peter Rabbitson (ribasushi), whose concerns that low-level utility modules
were shipping with install tools that did not work out of the box with perls
5.6 and 5.8 inspired the creation of this module.

Matt Trout (mst), for realizing a simple warning would be sufficient, rather
than a complicated detection heuristic, as well as the text of the warning
(but it turns out that we still need a I<simple> detection heuristic, so -0.5
for that...)

=head1 SEE ALSO

=begin :list

* L<Dist::Zilla::Plugin::ModuleBuildTiny>

=end :list

=for stopwords cpanminus

=cut
__DATA__
*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***

If you're seeing this warning, your toolchain is really, really old and you'll
almost certainly have problems installing CPAN modules from this century. But
never fear, dear user, for we have the technology to fix this!

If you're using CPAN.pm to install things, then you can upgrade it using:

    cpan CPAN

If you're using CPANPLUS to install things, then you can upgrade it using:

    cpanp CPANPLUS

If you're using cpanminus, you shouldn't be seeing this message in the first
place, so please file an issue on github.

If you're installing manually, please retrain your fingers to run Build.PL
when present instead.

This public service announcement was brought to you by the Perl Toolchain
Gang, the irc.perl.org #toolchain IRC channel, and the number 42.
