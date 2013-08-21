package Module::CPANTS::Kwalitee::Manifest;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Array::Diff;

our $VERSION = '0.90_02';

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my @files=@{$me->d->{files_array} || []};
    if (my $ignore = $me->d->{ignored_files_array}) {
        push @files, @$ignore;
    }
    my $distdir=$me->distdir;
    my $manifest_file=catfile($distdir,'MANIFEST');

    if (-e $manifest_file) {
        # read manifest
        open(my $fh, '<', $manifest_file) || die "cannot read MANIFEST $manifest_file: $!";
        my @manifest;
        while (<$fh>) {
            chomp;
            next if /^\s*#/; # discard pure comments
            if (s/^'(\\[\\']|.+)+'\s*.*/$1/) {
                s/\\([\\'])/$1/g;
            } else {
                s/\s.*$//;
            } # strip quotes and comments
            next unless $_; # discard blank lines
            push(@manifest,$_);
        }
        close $fh;

        @manifest=sort @manifest;
        my @files=sort @files;

        my $diff=Array::Diff->diff(\@manifest,\@files);
        if ($diff->count == 0) {
            $me->d->{manifest_matches_dist}=1;
        }
        else {
            $me->d->{manifest_matches_dist}=0;
            my @error = ( 
                'MANIFEST ('.@manifest.') does not match dist ('.@files."):",
                "Missing in MANIFEST: ".join(', ',@{$diff->added}), 
                "Missing in Dist: " . join(', ',@{$diff->deleted}));
            $me->d->{error}{manifest_matches_dist} = \@error;
        }
    }
    else {
        $me->d->{manifest_matches_dist}=0;
        $me->d->{error}{manifest_matches_dist}=q{Cannot find MANIFEST in dist.};
    }
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'manifest_matches_dist',
            error=>q{MANIFEST does not match the contents of this distribution.},
            remedy=>q{Run a proper command ("make manifest" or "./Build manifest", maybe with a force option), or use a distribution builder to generate the MANIFEST. Or update MANIFEST manually.},
            code=>sub { shift->{manifest_matches_dist} ? 1 : 0 },
            details=>sub {
                my $d = shift;
                my $error = $d->{error}{manifest_matches_dist};
                return $error unless ref $error;
                return join "\n", @$error;
            },
        }
    ];
}


q{Listening to: YAPC::Europe 2007};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Manifest - Check MANIFEST

=head1 SYNOPSIS

Check if MANIFEST and dist contents match.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

Check if MANIFEST and dist contents match.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * manifest_matches_dist

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.plix.at

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
