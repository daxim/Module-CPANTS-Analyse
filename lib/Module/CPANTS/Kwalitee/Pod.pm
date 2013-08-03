package Module::CPANTS::Kwalitee::Pod;
use warnings;
use strict;

our $VERSION = '0.90_02'; $VERSION = eval $VERSION;

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    # NOTE: This test has moved to Module::CPANTS::SiteKwalitee
    # because in many cases the pod correctness is tested by
    # another (author) test using Test::Pod (as it has long been
    # encouraged). Let's double check only on the server side.

    # Note also that this stub should not be removed so that
    # this can replace the old ::Pod module, and the old
    # metrics will not be loaded while loading plugins.
}


##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Pod - Check Pod

=head1 SYNOPSIS

The check in this module has moved to L<Module::CPANTS::SiteKwalitee::Pod> to double-check the pod correctness on the server side.

If you do care, it is recommended to add a test to test pod (with L<Test::Pod>) in "xt/" directory in your distribution.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

Does nothing now.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
