package Module::CPANTS::Kwalitee::CpantsErrors;
use warnings;
use strict;

our $VERSION = '0.87';

sub order { 1000 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;

    return if $me->opts->{no_capture} or $INC{'Test/More.pm'};

    my $sout=$me->capture_stdout;
    my $serr=$me->capture_stderr;
    $sout->stop;
    $serr->stop;

    my @eout=$sout->read;
    my @eerr=$serr->read;
    
    $me->d->{error}{cpants}= (@eerr || @eout) ? join("\n",'STDERR:',@eerr,'STDOUT:',@eout) : '';
}


##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    # NOTE: CPANTS error should be logged somewhere, but it
    # should not annoy people. If anything wrong or interesting
    # is found in the log, add some metrics (if it's worth),
    # or just fix our problems.

    return [];
}


q{Listeing to: FM4 the early years};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::CpantsErrors

=head1 SYNOPSIS

Checks if something strange happend during testing

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<1000>.

=head3 analyse

Uses C<IO::Capture::Stdout> to check for any strange things that might happen during testing

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * no_cpants_errors

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
