package Module::CPANTS::Kwalitee::Signature;
use strict;
use warnings FATAL => 'all';
use File::chdir;
use Module::Signature qw(verify SIGNATURE_OK SIGNATURE_MISSING);

sub order { 100 }

sub analyse {
    my ($class, $self) = @_;
    local $CWD = $self->distdir;
    local $SIG{__WARN__} = sub {};  # shut up M::S diagnostics
    $self->d->{error}{valid_signature} = verify;
}

sub kwalitee_indicators {
    return [{
        name    => 'valid_signature',
        error   => q{This dist failed its Module::Signature verification and does not to install automatically through the CPAN client if Module::Signature is installed. Note: unsigned dists will automatically pass this kwalitee check.},
        remedy  => q{Sign the dist as the last step before creating the archive. Take care not to modify/regenerate dist meta files or the manifest.},
        code    => sub {
            my $v = shift->{error}{valid_signature};
            return (SIGNATURE_OK == $v or SIGNATURE_MISSING == $v) ? 1 : 0;
        },
    }];
}

1;

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Signature - dist has a valid signature

=head1 SYNOPSIS

Check if the cryptographic signature of a dist is valid.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

Uses C<Module::Signature> to verify the validity of the dist signature.

Dists without signature pass automatically.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * valid_signature

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Lars Dɪᴇᴄᴋᴏᴡ C<< <daxim@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright © 2012, Lars Dɪᴇᴄᴋᴏᴡ C<< <daxim@cpan.org> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl 5.14.
