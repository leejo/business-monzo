#!perl

use strict;
use warnings;

use Test::Most;
use Test::Deep;
use Test::Exception;
use Business::Mondo;

use FindBin qw/ $Bin /;

plan skip_all => "MONDO_ENDTOEND required"
    if ! $ENV{MONDO_ENDTOEND};

# this is an "end to end" test - it will call the Mondo API
# using the details defined in the ENV variables below.
my ( $token,$url,$skip_cert ) = @ENV{qw/
    MONDO_TOKEN
    MONDO_URL
    SKIP_CERT_CHECK
/};

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = !$skip_cert;

# this makes Business::Mondo::Exception show a stack
# trace when any error is thrown so i don't have to keep
# wrapping stuff in this test in evals to debug
$ENV{MONDO_DEBUG} = 1;

my $Mondo = Business::Mondo->new(
    token   => $token,
    api_url => $url
);

isa_ok( $Mondo,'Business::Mondo' );

isa_ok(
    my $Transaction = $Mondo->transaction( id => 1, expand => 'merchant' ),
    'Business::Mondo::Transaction'
);

isa_ok(
    $Transaction->get,
    'Business::Mondo::Transaction',
);

isa_ok(
    $Transaction->annotate( foo => 'bar' ),
    'Business::Mondo::Transaction',
);

cmp_deeply(
    $Transaction->annotations,
    {
        stuff      => 'yes',
        more_stuff => 'yep',
    },
    '->annotations',
);

isa_ok(
    ( $Mondo->transactions( account_id => 1 ) )[1],
    'Business::Mondo::Transaction',
);

isa_ok(
    my $Account = ( $Mondo->accounts )[0],
    'Business::Mondo::Account',
);

ok( $Account->add_feed_item(
    params => {
        title     => 'foo',
        image_url => 'bar',
    }
),'->add_feed_item' );

isa_ok( my $Webhook = $Account->register_webhook(
    callback_url => 'http://www.foo.com',
),'Business::Mondo::Webhook' );

ok( my @webhooks = $Account->webhooks,'->webhooks' );
ok( $Webhook->delete,'->delete' );

done_testing();
