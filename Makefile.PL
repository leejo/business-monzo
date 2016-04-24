#!perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Business::Mondo',
    VERSION_FROM     => 'lib/Business/Mondo/Version.pm',
    AUTHOR           => 'Lee Johnson <leejo@cpan.org>',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.10.1',
    PREREQ_PM => {
        'Moo'                  => 1.006,
        'Carp'                 => 0, # Carp was first released with perl 5
        'Throwable'            => 0.200011,
        'MIME::Base64'         => 0, # MIME::Base64 was first released with perl v5.7.3
        'LWP::UserAgent'       => 6.00,
        'LWP::Protocol::https' => 6.00,
        'Cpanel::JSON::XS'     => 3.0115,
        'Try::Tiny'            => 0.22,
        'Types::Standard'      => 1.000005,
        'Data::Currency'       => 0.06000,
        'DateTime::Format::DateParse' => 0.05,
    },
    TEST_REQUIRES => {
        'Test::Most'       => 0.31,
        'Test::Deep'       => 0.112,
        'Test::Exception'  => 0.32,
        'Test::MockObject' => 1.20140408,
        'DateTime::Tiny'   => 1.04,
    },
    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://metacpan.org/module/Business::Mondo',
            bugtracker => 'https://github.com/leejo/business-mondo/issues',
            repository => 'https://github.com/leejo/business-mondo'
        },
    },
    test => {
        RECURSIVE_TEST_FILES => 1,
    },
);

# vim: ts=4:sw=4:et
