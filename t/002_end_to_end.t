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

note( "Mondo" );
my $Mondo = Business::Mondo->new(
    token   => $token,
    api_url => $url
);

isa_ok( $Mondo,'Business::Mondo' );

note( "Transaction" );
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

note( "Account" );
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

note( "Webhook" );
isa_ok( my $Webhook = $Account->register_webhook(
    callback_url => 'http://www.foo.com',
),'Business::Mondo::Webhook' );

ok( my @webhooks = $Account->webhooks,'->webhooks' );
ok( $Webhook->delete,'->delete' );

note( "Balance" );
isa_ok(
	my $Balance = $Mondo->balance( account_id => 1 ),
	'Business::Mondo::Balance'
);

is( $Balance->account_id,'1','->account_id' );
is( $Balance->balance,5000,'->balance' );
isa_ok( $Balance->currency,'Data::Currency','->currency' );
is( $Balance->spend_today,0,'->spend_today' );

note( "Attachement" );
isa_ok( my $Attachment = $Mondo->upload_attachment(
	file_name => 'foo.png',
	file_type => 'image/png',
),'Business::Mondo::Attachment' );

is( $Attachment->file_name,'foo.png','->file_name' );
is( $Attachment->file_type,'image/png','->file_type' );
is( $Attachment->file_url,'https://127.0.0.1:3000/file/user_00009237hliZellUicKuG1/LcCu4ogv1xW28OCcvOTL-foo.png','->file_url' );
is( $Attachment->upload_url,'https://127.0.0.1:3000/upload/user_00009237hliZellUicKuG1/LcCu4ogv1xW28OCcvOTL-foo.png?AWSAccessKeyId=AKIAIR3IFH6UCTCXB5PQ0026Expires=14473534310026Signature=k2QeDCCQQHaZeynzYKckejqXRGU%!D(MISSING)','->upload_url' );

isa_ok( $Attachment = $Attachment->register(
	external_id => 'my_id'
),'Business::Mondo::Attachment' );

is( $Attachment->user_id,'user_00009238aMBIIrS5Rdncq9','->user_id' );
isa_ok( $Attachment->created,'DateTime' );
is( $Attachment->external_id,'my_id','->id' );
is( $Attachment->id,'attach_00009238aOAIvVqfb9LrZh','->id' );
is( $Attachment->file_name,'foo.png','->file_name' );
is( $Attachment->file_type,'image/png','->file_type' );
is( $Attachment->file_url,'https://127.0.0.1:3000/file/user_00009237hliZellUicKuG1/LcCu4ogv1xW28OCcvOTL-foo.png','->file_url' );
is( $Attachment->upload_url,'https://127.0.0.1:3000/upload/user_00009237hliZellUicKuG1/LcCu4ogv1xW28OCcvOTL-foo.png?AWSAccessKeyId=AKIAIR3IFH6UCTCXB5PQ0026Expires=14473534310026Signature=k2QeDCCQQHaZeynzYKckejqXRGU%!D(MISSING)','->upload_url' );

ok( $Attachment->deregister,'->deregister' );

done_testing();
