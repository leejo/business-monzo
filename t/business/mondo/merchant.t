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

use_ok( 'Business::Mondo::Merchant' );
isa_ok(
    my $Merchant = Business::Mondo::Merchant->new(
        "address" => {
            "address"   => "98 Southgate Road",
            "city"      => "London",
            "country"   => "GB",
            "latitude"  => 51.54151,
            "longitude" => -0.08482400000002599,
            "postcode"  => "N1 3JD",
            "region"    => "Greater London"
        },
        "created"  => "2015-08-22T12:20:18Z",
        "group_id" => "grp_00008zIcpbBOaAr7TTP3sv",
        "id"       => "merch_00008zIcpbAKe8shBxXUtl",
        "logo"     => "https://pbs.twimg.com/profile_images/527043602623389696/68_SgUWJ.jpeg",
        "emoji"    => "🍞",
        "name"     => "The De Beauvoir Deli Co.",
        "category" => "eating_out",
        'client'   => Business::Mondo::Client->new(
            token      => 'foo',
        ),
    ),
    'Business::Mondo::Merchant'
);

can_ok(
    $Merchant,
    qw/
        url
        get
        to_hash
        to_json
        TO_JSON

        id
        address
        created
        group_id
        id
        logo
        emoji
        name
        category
    /,
);

is(
    $Merchant->url,
    'https://api.getmondo.co.uk/merchants/merch_00008zIcpbAKe8shBxXUtl',
    'url'
);

throws_ok(
    sub { $Merchant->get },
    'Business::Mondo::Exception'
);

is(
    $@->message,
    'Mondo API does not currently support getting merchant data',
    ' ... with expected message'
);

isa_ok( $Merchant->address,'Business::Mondo::Address' );
isa_ok( $Merchant->created,'DateTime' );

done_testing();

# vim: ts=4:sw=4:et
