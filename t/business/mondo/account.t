#!perl

use strict;
use warnings;

use Test::Most;
use Test::Deep;
use Test::Exception;
use JSON;

use Business::Mondo::Client;

$Business::Mondo::Resource::client = Business::Mondo::Client->new(
    token      => 'foo',
);

use_ok( 'Business::Mondo::Account' );
isa_ok(
    my $Account = Business::Mondo::Account->new(
        "id"          => "acc_00009237aqC8c5umZmrRdh",
        "description" => "Peter Pan's Account",
        "created"     => "2015-08-22T12:20:18Z",
        'client'      => Business::Mondo::Client->new(
            token      => 'foo',
        ),
    ),
    'Business::Mondo::Account'
);

can_ok(
    $Account,
    qw/
        url
        get
        to_hash
        to_json
        TO_JSON

        id
        description
        created
    /,
);

throws_ok(
    sub { $Account->get },
    'Business::Mondo::Exception'
);

is(
    $@->message,
    'Mondo API does not currently support getting account data',
    ' ... with expected message'
);

throws_ok(
    sub { $Account->url },
    'Business::Mondo::Exception'
);

is(
    $@->message,
    'Mondo API does not currently support getting account data',
    ' ... with expected message'
);

done_testing();

# vim: ts=4:sw=4:et
