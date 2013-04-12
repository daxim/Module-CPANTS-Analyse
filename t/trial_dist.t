use strict;
use warnings;
use Test::More tests => 1;
use Data::Dump qw/dump/;
use Module::CPANTS::Analyse;

my $context = Module::CPANTS::Analyse->new({
    dist => 'L/LO/LOCAL/Foo-Bar-0.01-TRIAL.tar.gz',
});

Module::CPANTS::Kwalitee::Distname->analyse($context);

my ($metric) = grep { $_->{name} eq 'has_proper_version' } @{ Module::CPANTS::Kwalitee::Distname->kwalitee_indicators };

ok $metric->{code}->($context->{d}), "TRIAL is a proper version";
