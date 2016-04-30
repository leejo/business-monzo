# NAME

Business::Mondo - Perl library for interacting with the Mondo API
(https://api.getmondo.co.uk)

<div>

    <a href='https://travis-ci.org/leejo/business-mondo?branch=master'><img src='https://travis-ci.org/leejo/business-mondo.svg?branch=master' alt='Build Status' /></a>
    <a href='https://coveralls.io/r/leejo/business-mondo?branch=master'><img src='https://coveralls.io/repos/leejo/business-mondo/badge.png?branch=master' alt='Coverage Status' /></a>
</div>

# VERSION

0.02

# DESCRIPTION

Business::Mondo is a library for easy interface to the Mondo banking API,
it implements all of the functionality currently found in the service's API
documentation: [https://getmondo.co.uk/docs](https://getmondo.co.uk/docs)

**You should refer to the official Mondo API documentation in conjunction**
**with this perldoc**, as the official API documentation explains in more depth
some of the functionality including required / optional parameters for certain
methods.

Please note this library is very much a work in progress, as is the Mondo API.

All objects within the Business::Mondo namespace are immutable. Calls to methods
will, for the most part, return new instances of objects.

# SYNOPSIS

    my $mondo = Business::Mondo->new(
        token   => $token, # REQUIRED
        api_url => $url,   # optional
    );

    # transaction related information
    my @transactions = $mondo->transactions( account_id => $account_id );

    my $Transaction  = $mondo->transaction( id => 1 );

    $Transaction->annotate(
        foo => 'bar',
        baz => 'boz,
    );

    my $annotations = $Transaction->annotations;

    # account related information
    my @accounts = $mondo->accounts;

    foreach my $Account ( @accounts ) {

        my @transactions = $Account->transactions;

        $Account->add_feed_item(
            params => {
                title     => 'My Feed Item',
                image_url => 'http://...',
            }
        );

        # balance information
        my $Balance = $Account->balance;

        # webhooks
        my @webhooks = $Account->webhooks;

        my $Webhook = $Account->register_webhook(
            callback_url => 'http://www.foo.com',
        );

        $Webhook->delete
    }

    # attachments
    my $Attachment = $mondo->upload_attachment(
        file_name => 'foo.png',
        file_type => 'image/png',
    );

    $Attachment->register(
        external_id => 'my_id'
    );

    $Attachment->deregister;

# ERROR HANDLING

Any problems or errors will result in a Business::Mondo::Exception
object being thrown, so you should wrap any calls to the library in the
appropriate error catching code (TryCatch in the below example):

    use TryCatch;

    try {
        ...
    }
    catch ( Business::Mondo::Exception $e ) {
        # error specific to Business::Mondo
        ...
        say $e->message;  # error message
        say $e->code;     # HTTP status code
        say $e->response; # HTTP status message

        # ->request may not always be present
        say $e->request->{path}    if $e->request
        say $e->request->{params}  if $e->request
        say $e->request->{headers} if $e->request
        say $e->request->{content} if $e->request
    }
    catch ( $e ) {
        # some other failure?
        ...
    }

You can view some useful debugging information by setting the MONDO\_DEBUG
env varible, this will show the calls to the Mondo endpoints as well as a
stack trace in the event of exceptions:

    $ENV{MONDO_DEBUG} = 1;

# ATTRIBUTES

## token

Your Mondo access token, this is required

## api\_url

The Mondo url, which will default to https://api.getmondo.co.uk

## client

A Business::Mondo::Client object, this will be constructed for you so
you shouldn't need to pass this

# METHODS

In the following %query\_params refers to the possible query params as shown in
the Mondo API documentation. For example: limit=100.

    # transactions in the previous month
    my @transactions = $mondo->transactions(
        since => DateTime->now->subtract( months => 1 ),
    );

## transactions

    $mondo->transactions( %query_params );

Get a list of transactions. Will return a list of [Business::Mondo::Transaction](https://metacpan.org/pod/Business::Mondo::Transaction)
objects. Note you must supply an account\_id in the params hash;

## balance

    my $Balance = $mondo->balance( account_id => $account_id );

Get an account balance Returns a [Business::Mondo::Balance](https://metacpan.org/pod/Business::Mondo::Balance) object.

## transaction

    my $Transaction = $mondo->transaction(
        id     => $id,
        expand => 'merchant'
    );

Get a transaction. Will return a [Business::Mondo::Transaction](https://metacpan.org/pod/Business::Mondo::Transaction) object

## accounts

    $mondo->accounts;

Get a list of accounts. Will return a list of [Business::Mondo::Account](https://metacpan.org/pod/Business::Mondo::Account)
objects

# EXAMPLES

See the t/002\_end\_to\_end.t test included with this distribution. you can run
this test against the Mondo emulator by running end\_to\_end\_emulated.sh (this
is advised, don't run it against a live endpoint).

# SEE ALSO

[Business::Mondo::Account](https://metacpan.org/pod/Business::Mondo::Account)

[Business::Mondo::Attachment](https://metacpan.org/pod/Business::Mondo::Attachment)

[Business::Mondo::Balance](https://metacpan.org/pod/Business::Mondo::Balance)

[Business::Mondo::Transaction](https://metacpan.org/pod/Business::Mondo::Transaction)

[Business::Mondo::Webhook](https://metacpan.org/pod/Business::Mondo::Webhook)

# AUTHOR

Lee Johnson - `leejo@cpan.org`

# LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-mondo
