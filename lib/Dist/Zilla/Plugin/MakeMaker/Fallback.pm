use strict;
use warnings;
package Dist::Zilla::Plugin::MakeMaker::Fallback;
# ABSTRACT: ...
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';
with 'Dist::Zilla::Role::BeforeBuild';
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

    return "warn <<'EOW';\n\n"
        . join('', <DATA>)
        . "\nEOW\n\nsleep 10 if -t STDIN;\n\n"
        . $self->$orig(@_);
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

=head1 SYNOPSIS

    use Dist::Zilla::Plugin::MakeMaker::Fallback;

    ...

=head1 DESCRIPTION

...

=head1 FUNCTIONS/METHODS

=over 4

=item * C<foo>

...

=back

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-MakeMaker-Fallback>
(or L<bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org|mailto:bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

Peter Rabbitson (ribasushi), whose persistent ...

=head1 SEE ALSO

=begin :list

* L<Dist::Zilla::Plugin::ModuleBuildTiny>

=end :list

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
