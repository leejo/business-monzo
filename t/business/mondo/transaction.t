#!perl

use strict;
use warnings;

use Test::Most;
use Test::Deep;
use Test::Exception;
use JSON;

use Business::Mondo::Client;

use_ok( 'Business::Mondo::Transaction' );
isa_ok(
    my $Transaction = Business::Mondo::Transaction->new(
        'id'              => 1,
        'client'          => Business::Mondo::Client->new(
            token      => 'foo',
        ),
    ),
    'Business::Mondo::Transaction'
);

can_ok(
    $Transaction,
    qw/
        url
        get
        to_hash
        to_json
        TO_JSON

        id
        description
        notes
        account_balance
        amount
        metadata
        is_load
        settled
        merchant
        currency
        created
    /,
);

is( $Transaction->url,'https://api.getmondo.co.uk/transactions/1','url' );

no warnings 'redefine';

*Business::Mondo::Client::api_get = sub {
    {
        "transaction" => {
            "account_balance" => 13013,
            "amount"          => -510,
            "created"         => "2015-08-22T12:20:18Z",
            "currency"        => "GBP",
            "description"     => "THE DE BEAUVOIR DELI C LONDON        GBR",
            "id"              => "tx_00008zIcpb1TB4yeIFXMzx",
            "merchant"        => {
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
                "logo"  => "https://pbs.twimg.com/profile_images/527043602623389696/68_SgUWJ.jpeg",
                "emoji" => "🍞",
                "name"  => "The De Beauvoir Deli Co.",
                "category" => "eating_out"
            },
            "metadata" => {},
            "notes"    => "Salmon sandwich 🍞",
            "is_load"  => JSON::false,
            "settled"  => JSON::true
        }
    };
};

ok( $Transaction->get,'->get' );
isa_ok( $Transaction->merchant,'Business::Mondo::Merchant' );
isa_ok( $Transaction->merchant->address,'Business::Mondo::Address' );
isa_ok( $Transaction->currency,'Data::Currency' );
isa_ok( $Transaction->created,'DateTime' );

done_testing();

# vim: ts=4:sw=4:et
