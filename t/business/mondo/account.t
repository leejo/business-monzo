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

throws_ok(
    sub { $Account->add_feed_item },
    'Business::Mondo::Exception'
);

is(
    $@->message,
    'add_feed_item requires params: title, image_url',
    ' ... with expected message'
);

no warnings 'redefine';
*Business::Mondo::Client::api_post = sub { {} };

ok( $Account->add_feed_item(
    params => {
        title => "My custom item",
        image_url => "www.example.com/image.png",
        background_color => "#FCF1EE",
        body_color => "#FCF1EE",
        title_color => "#333",
        body => "Some body text to display",
    },
),'->add_feed_item' );

done_testing();

# vim: ts=4:sw=4:et
