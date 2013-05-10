package Module::CPANTS::Kwalitee::Prereq;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);

our $VERSION = '0.87';

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    # NOTE: The analysis/metrics in this module have moved to
    # Module::CPANTS::SiteKwalitee because these requires databases
    # or decent network connection to resolve module names,
    # as well as a finalized META.yml to avoid parsing dist.ini
    # or cpanfile (or whatever private metafiles) by ourselves.
    # That said, it may be nice to move some of the previous
    # analysis back here.

    # Note also that this stub should not be removed so that
    # this can replace the old ::Prereq module, and the old
    # metrics will not be loaded while loading plugins.
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Prereq - Checks listed prerequistes

=head1 SYNOPSIS

Checks which other dists a dist declares as requirements.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::Prereq> checks C<META.yml>, C<Build.PL> or C<Makefile.PL> for prereq-listings. 

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * is_prereq (currently deactived)

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
