package Module::CPANTS::Kwalitee::Distros;
use warnings;
use strict;

our $VERSION = '0.90_02'; $VERSION = eval $VERSION;

sub order { 800 }

##################################################################
# Analyse
##################################################################
my $debian;

sub analyse {
    my $class=shift;
    my $me=shift;

    # NOTE: The data source of these debian metrics has not been
    # updated for more than a year, and mirroring stuff from
    # external source every time you test is very nasty.

    # These metrics are deprecated and actually removed to
    # reduce unwanted dependencies for Test::Kwalitee users.

    # Note also that this stub should not be removed so that
    # this can replace the old ::Distro module, and the old
    # metrics will not be loaded while loading plugins.

    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [];
}

q{Favourite record of the moment:
  Lili Allen - Allright, still};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Distros - Information retrieved from the various Linux and other distributions

=head1 SYNOPSIS

The metrics here were based on data provided by the various downstream packaging systems, but are deprecated now. The list is only preserved for historical reasons.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

=head3 analyse

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * distributed_by_debian

True if the module (package) is repackaged by the Debian-Perl team and 
you can install it using the package management system of Debian.

=item * latest_version_distributed_by_debian

True if the latest version of the module (package) is repackaged by Debian

=item * has_no_bugs_reported_in_debian

True for if the module is distributed by Debian and no bugs were reported.

=item * has_no_patches_in_debian

True for if the module is distributed by Debian and no patches applied.

=back

=head1 Caveats

CPAN_dist, the name of CPAN distribution is inferred from the download location,
for Debian packages. It works 99% of the time, but it is not completely reliable.
If it fails to detect something, it will spit out the known download location.

CPAN_vers, the version number reported by Debian is inferred from the debian version.
This fails a lot, since Debian has a mechanism for "unmangling" upstream versions which
is non-reversible. We have to use that many times to fix versioning problems, 
and those packages will show a different version (e.g. 1.080 vs 1.80)

The first problem is something the Debian people like to solve by adding 
metadata to the packages, for many other useful stuff 
(like automatic upstream bug tracking and handling). About the second... well, 
it's a difficult one.

CPANTS does not yet handle the second issue.

=head1 LINKS

Basic homepage: http://packages.debian.org/src:$pkgname

Detalied homepage: http://packages.qa.debian.org/$pkgname

Bugs report: http://bugs.debian.org/src:$pkgname

Public SVN repository: http://svn.debian.org/wsvn/pkg-perl/trunk/$pkg

From that last URL, you might be interested in the debian/ and
debian/patches subdirectories.

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>
and L<Gábor Szabó|https://metacpan.org/author/szabgab>
with the help of Martín Ferrari and the
L<Debian Perl packaging team|http://pkg-perl.alioth.debian.org/>.

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2009 L<Thomas Klausner|https://metacpan.org/author/domm>

Copyright © 2006–2008 L<Gábor Szabó|https://metacpan.org/author/szabgab>

You may use and distribute this module according to the same terms
that Perl is distributed under.
