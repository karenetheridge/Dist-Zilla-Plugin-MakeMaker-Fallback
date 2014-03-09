# NAME

Dist::Zilla::Plugin::MakeMaker::Fallback - Generate a Makefile.PL containing a warning for legacy users

# VERSION

version 0.007

# SYNOPSIS

In your `dist.ini`, when you want to ship a `Build.PL` as well as a fallback
`Makefile.PL` in case the user's `cpan` client is so old it doesn't recognize
`configure_requires`:

    [ModuleBuildTiny]
    [MakeMaker::Fallback]

# DESCRIPTION

This plugin is a derivative of `[MakeMaker]`, generating a `Makefile.PL` in
your dist, with an added preamble that is printed when it is run:

> \*\*\* WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING \*\*\*
>
> If you're seeing this warning, your toolchain is really, really old\* and you'll
> almost certainly have problems installing CPAN modules from this century. But
> never fear, dear user, for we have the technology to fix this!
>
> If you're using CPAN.pm to install things, then you can upgrade it using:
>
>     cpan CPAN
>
> If you're using CPANPLUS to install things, then you can upgrade it using:
>
>     cpanp CPANPLUS
>
> If you're using cpanminus, you shouldn't be seeing this message in the first
> place, so please file an issue on github.
>
> If you're installing manually, please retrain your fingers to run Build.PL
> when present instead.
>
> This public service announcement was brought to you by the Perl Toolchain
> Gang, the irc.perl.org #toolchain IRC channel, and the number 42.
>
> \----
>
> \* Alternatively, you are doing something overly clever, in which case you
> should consider setting the 'prefer\_installer' config option in CPAN.pm, or
> 'prefer\_makefile' in CPANPLUS, to 'mb" and '0' respectively.
>
> You can also silence this warning for future installations by setting the
> PERL\_MM\_FALLBACK\_SILENCE\_WARNING environment variable.

Additionally, the `build` and `test` functionalities of the plugin
(`perl Makefile.PL && make` and `make test` respectively) are
disabled, making it convenient to develop under multiple installer plugins,
without `dzil test` running tests twice.

It is a fatal error to use this plugin when there is not also another
plugin enabled that generates a `Build.PL` (such as
[\[ModuleBuildTiny\]](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuildTiny)).

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-MakeMaker-Fallback)
(or [bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org](mailto:bug-Dist-Zilla-Plugin-MakeMaker-Fallback@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# ACKNOWLEDGEMENTS

Peter Rabbitson (ribasushi), whose concerns that low-level utility modules
were shipping with install tools that did not work out of the box with perls
5.6 and 5.8 inspired the creation of this module.

Matt Trout (mst), for realizing a simple warning would be sufficient, rather
than a complicated detection heuristic, as well as the text of the warning
(but it turns out that we still need a _simple_ detection heuristic, so -0.5
for that...)

# SEE ALSO

- [Dist::Zilla::Plugin::ModuleBuildTiny](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuildTiny)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
