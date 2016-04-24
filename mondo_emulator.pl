#!perl

use strict;
use warnings;

use Mojolicious::Lite;
use Mojo::JSON;
use Data::Dumper;

$ENV{MOJO_LOG_LEVEL} = 'debug';

plugin 'OAuth2::Server' => {
    access_token_ttl   => 21600,
    authorize_route    => '/',
    access_token_route => '/oauth2/token',
    jwt_secret         => "ThisIsMyMondoJWTSecret",
    clients            => {
        test_client => {
            client_secret => 'test_client_secret',
            scopes        => {},
        },
    },
    users => {
        leejo => "Weeeee",
    }
};

group {

    # all routes must have an access token
    under '/' => sub {
        my ( $c ) = @_;
        return 1 if $c->oauth;
        $c->render( status => 401, text => 'Unauthorized' );
        return undef;
    };

    post '/ping/whoami' => sub {
        my ( $c ) = @_;

        $c->render( json => {
            authenticated => Mojo::JSON::true,
            client_id     => $c->oauth->{client},
            user_id       => $c->oauth->{user_id},
        } );

    };

    get '/accounts' => sub {
        my ( $c ) = @_;

        $c->render( json => {
            accounts => [
                {
                    id          => "acc_00009237aqC8c5umZmrRdh",
                    description => "Peter Pan's Account",
                    created     => "2015-11-13T12:17:42Z",
                },
            ],
        } );
    };

    get '/balance' => sub {
        my ( $c ) = @_;

        my $account_id = $c->param( 'account_id' )
            || return $c->render( status => 400, text => "account_id required" );

        $c->render( json => {
            balance     => 5000,
            currency    => "GBP",
            spend_today => 0,
        } );
    };

    get '/transactions/:transaction_id' => sub {
        my ( $c ) = @_;

        my $tid = $c->param( 'transaction_id' );

        $c->render( json => {
            "transaction" => _transactions( $c->param( 'expand[]' ) )->[1],
        } );
    };

    patch '/transactions/:transaction_id' => sub {
        my ( $c ) = @_;

        my $tid = $c->param( 'transaction_id' );

        my $metadata = _convert_map_params_to_hash( $c,'metadata' );

        $c->render( json => {
            "transaction" => _transactions( undef,$metadata )->[$tid - 1],
        } );
    };

    get '/transactions' => sub {
        my ( $c ) = @_;

        my $account_id = $c->param( 'account_id' )
            || return $c->render( status => 400, text => "account_id required" );

        $c->render( json => {
            "transactions" => _transactions(),
        } );
    };

    post '/feed' => sub {
        my ( $c ) = @_;

        my $account_id = $c->param( 'account_id' )
            || return $c->render( status => 400, text => "account_id required" );

        my $type = $c->param( 'type' )
            || return $c->render( status => 400, text => "type required" );

        my $params = _convert_map_params_to_hash( $c,'params' )
            || return $c->render( status => 400, text => "params required" );

        foreach my $required_param ( qw/ title image_url / ) {
            defined $params->{$required_param} 
                || return $c->render( status => 400, text => "params[$required_param] required" );
        }

        # no-op at present
        $c->render( json => {} );
    };

    post '/webhooks' => sub {
        my ( $c ) = @_;

        my $account_id = $c->param( 'account_id' )
            || return $c->render( status => 400, text => "account_id required" );

        my $url = $c->param( 'url' )
            || return $c->render( status => 400, text => "url required" );

        $c->render( json => {
            webhook => {
                account_id => $account_id,
                url        => $url,
                id         => time,
            }
        } );
    };

    get '/webhooks' => sub {
        my ( $c ) = @_;

        my $account_id = $c->param( 'account_id' )
            || return $c->render( status => 400, text => "account_id required" );

        $c->render( json => {
            webhooks => _webhooks( $account_id ),
        } );
    };

    del '/webhooks/:webhook_id' => sub {
        shift->render( json => {} );
    };

    post '/attachement/upload' => sub {
        my ( $c ) = @_;

        my $file_name = $c->param( 'file_name' )
            || return $c->render( status => 400, text => "file_name required" );

        my $file_type = $c->param( 'file_type' )
            || return $c->render( status => 400, text => "file_type required" );

        my $url = $c->req->url;

        my $entity_id = "user_00009237hliZellUicKuG1";
        $c->render( json => {
            "file_url" => $url->base . "/file/$entity_id/LcCu4ogv1xW28OCcvOTL-foo.png",
            "upload_url" => $url->base . "/upload/$entity_id/LcCu4ogv1xW28OCcvOTL-foo.png?AWSAccessKeyId=AKIAIR3IFH6UCTCXB5PQ\u0026Expires=1447353431\u0026Signature=k2QeDCCQQHaZeynzYKckejqXRGU%!D(MISSING)"
        } );
    };

    post '/attachement/register' => sub {
        my ( $c ) = @_;

        my $external_id = $c->param( 'external_id' )
            || return $c->render( status => 400, text => "external_id required" );

        my $file_url = $c->param( 'file_url' )
            || return $c->render( status => 400, text => "file_url required" );

        my $file_type = $c->param( 'file_type' )
            || return $c->render( status => 400, text => "file_type required" );

        $c->render( json => {
            "attachment" => {
                "id" => "attach_00009238aOAIvVqfb9LrZh",
                "user_id" => "user_00009238aMBIIrS5Rdncq9",
                "external_id" => "tx_00008zIcpb1TB4yeIFXMzx",
                "file_url" => $file_url,
                "file_type" => "image/png",
                "created" => "2015-11-12T18:37:02Z"
            }
        } );
    };

    post '/attachement/deregister' => sub {
        my ( $c ) = @_;

        my $id = $c->param( 'id' )
            || return $c->render( status => 400, text => "id required" );

        $c->render( json => {} );
    }
};

# convenience methods for file upload emulation, these endpoints
# do not exist in the Mondo API, they are here to fake uploads
get '/file/:entity_id/:file_name' => sub {
    my ( $c ) = @_;

    $c->render( text => "OK" );
};

post '/upload/:entity_id/:file_name' => sub {
    my ( $c ) = @_;

    $c->render( text => "OK" );
};

sub _convert_map_params_to_hash {
    my ( $c,$prefix ) = @_;

    # converts { params[foo] => bar } to { foo => bar }
    # (this is horrible! why not just send JSON in the request body?)

    my $params = $c->req->params->to_hash;

    my %extracted_params =
        map { my $v = $params->{$_}; s/^$prefix\[//g; chop; $_ => $v }
        grep { /^$prefix\[[^\[]+\]$/ } keys %{ $params // {} };

    return \%extracted_params;
}

sub _transactions {
    my ( $expand,$metadata ) = @_;

    $expand   //= 'none';
    $metadata //= {
        stuff      => 'yes',
        more_stuff => 'yep',
    };

    return [
        {
            "account_balance" => 13013,
            "amount" => -510,
            "created" => "2015-08-22T12:20:18Z",
            "currency" => "GBP",
            "description" => "THE DE BEAUVOIR DELI C LONDON                GBR",
            "id" => "tx_00008zIcpb1TB4yeIFXMzx",
            "merchant" => $expand eq 'merchant'
                ? _merchant()
                : "merch_00008zIcpbAKe8shBxXUtl",
            "metadata" => $metadata,
            "notes" => "Salmon sandwich 🍞",
            "is_load" => Mojo::JSON::false,
            "settled" => '2015-08-23T12:20:18Z',
        },
        {
            "account_balance" => 12334,
            "amount" => -679,
            "created" => "2015-08-23T16:15:03Z",
            "currency" => "GBP",
            "description" => "VUE BSL LTD            ISLINGTON     GBR",
            "id" => "tx_00008zL2INM3xZ41THuRF3",
            "merchant" => $expand eq 'merchant'
                ? _merchant()
                : "merch_00008zIcpbAKe8shBxXUtl",
            "metadata" => $metadata,
            "notes" => "",
            "is_load" => Mojo::JSON::false,
            "settled" => '2015-08-23T12:20:18Z',
            "category" => "eating_out"
        },
    ];
}

sub _merchant {

    return {
        "address" => {
            "address" => "98 Southgate Road",
            "city" => "London",
            "country" => "GB",
            "latitude" => 51.54151,
            "longitude" => -0.08482400000002599,
            "postcode" => "N1 3JD",
            "region" => "Greater London"
        },
        "created" => "2015-08-22T12:20:18Z",
        "group_id" => "grp_00008zIcpbBOaAr7TTP3sv",
        "id" => "merch_00008zIcpbAKe8shBxXUtl",
        "logo" => "https://pbs.twimg.com/profile_images/527043602623389696/68_SgUWJ.jpeg",
        "emoji" => "🍞",
        "name" => "The De Beauvoir Deli Co.",
        "category" => "eating_out"
    };
}

sub _webhooks {
    my ( $account_id ) = @_;

    $account_id //= "acc_000091yf79yMwNaZHhHGzp";

    return [
        {
            "account_id" => $account_id,
            "id" => "webhook_000091yhhOmrXQaVZ1Irsv",
            "url" => "http://example.com/callback"
        },
        {
            "account_id" => $account_id,
            "id" => "webhook_000091yhhzvJSxLYGAceC9",
            "url" => "http://example2.com/anothercallback"
        },
    ];
}

app->start;

# vim: ts=4:sw=4:et
