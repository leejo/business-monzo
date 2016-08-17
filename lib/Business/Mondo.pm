package Business::Mondo;

=head1 NAME

Business::Mondo - Perl library for interacting with the Mondo API
(https://api.getmondo.co.uk)

=for html
<a href='https://travis-ci.org/leejo/business-mondo?branch=master'><img src='https://travis-ci.org/leejo/business-mondo.svg?branch=master' alt='Build Status' /></a>
<a href='https://coveralls.io/r/leejo/business-mondo?branch=master'><img src='https://coveralls.io/repos/leejo/business-mondo/badge.png?branch=master' alt='Coverage Status' /></a>

=head1 VERSION

0.05

=head1 DESCRIPTION

Business::Mondo is a library for easy interface to the Mondo banking API,
it implements all of the functionality currently found in the service's API
documentation: L<https://getmondo.co.uk/docs>

B<You should refer to the official Mondo API documentation in conjunction>
B<with this perldoc>, as the official API documentation explains in more depth
some of the functionality including required / optional parameters for certain
methods.

Please note this library is very much a work in progress, as is the Mondo API.

All objects within the Business::Mondo namespace are immutable. Calls to methods
will, for the most part, return new instances of objects.

=head1 SYNOPSIS

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

=head1 ERROR HANDLING

Any problems or errors will result in a Business::Mondo::Exception
object being thrown, so you should wrap any calls to the library in the
appropriate error catching code (ideally a module from CPAN):

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

You can view some useful debugging information by setting the MONDO_DEBUG
env varible, this will show the calls to the Mondo endpoints as well as a
stack trace in the event of exceptions:

    $ENV{MONDO_DEBUG} = 1;

=cut

use strict;
use warnings;

use Moo;
with 'Business::Mondo::Version';

use Carp qw/ confess /;

use Business::Mondo::Client;
use Business::Mondo::Account;
use Business::Mondo::Attachment;

=head1 ATTRIBUTES

=head2 token

Your Mondo access token, this is required

=head2 api_url

The Mondo url, which will default to https://api.getmondo.co.uk

=head2 client

A Business::Mondo::Client object, this will be constructed for you so
you shouldn't need to pass this

=cut

has [ qw/ token / ] => (
    is       => 'ro',
    required => 1,
);

has api_url => (
    is       => 'ro',
    required => 0,
    default  => sub { $Business::Mondo::API_URL },
);

has client => (
    is       => 'ro',
    isa      => sub {
        confess( "$_[0] is not a Business::Mondo::Client" )
            if ref $_[0] ne 'Business::Mondo::Client';
    },
    required => 0,
    lazy     => 1,
    default  => sub {
        my ( $self ) = @_;

        # fix any load order issues with Resources requiring a Client
        $Business::Mondo::Resource::client = Business::Mondo::Client->new(
            token   => $self->token,
            api_url => $self->api_url,
        );
    },
);

=head1 METHODS

In the following %query_params refers to the possible query params as shown in
the Mondo API documentation. For example: limit=100.

    # transactions in the previous month
    my @transactions = $mondo->transactions(
        since => DateTime->now->subtract( months => 1 ),
    );

=cut

=head2 transactions

    $mondo->transactions( %query_params );

Get a list of transactions. Will return a list of L<Business::Mondo::Transaction>
objects. Note you must supply an account_id in the params hash;

=cut

sub transactions {
    my ( $self,%params ) = @_;

    # transactions requires account_id, whereas transaction doesn't
    # the Mondo API is a little inconsistent at this point...
    $params{account_id} || Business::Mondo::Exception->throw({
        message => "transactions requires params: account_id",
    });

    return Business::Mondo::Account->new(
        client => $self->client,
        id     => $params{account_id},
    )->transactions( 'expand[]' => 'merchant' );
}

=head2 balance

    my $Balance = $mondo->balance( account_id => $account_id );

Get an account balance Returns a L<Business::Mondo::Balance> object.

=cut

sub balance {
    my ( $self,%params ) = @_;

    $params{account_id} || Business::Mondo::Exception->throw({
        message => "balance requires params: account_id",
    });

    return Business::Mondo::Account->new(
        client => $self->client,
        id     => $params{account_id},
    )->balance( %params );
}

=head2 transaction

    my $Transaction = $mondo->transaction(
        id     => $id,
        expand => 'merchant'
    );

Get a transaction. Will return a L<Business::Mondo::Transaction> object

=cut

sub transaction {
    my ( $self,%params ) = @_;

    if ( my $expand = delete( $params{expand} ) ) {
        $params{'expand[]'} = $expand;
    }

    return $self->client->_get_transaction( \%params );
}

=head2 accounts

    $mondo->accounts;

Get a list of accounts. Will return a list of L<Business::Mondo::Account>
objects

=cut

sub accounts {
    my ( $self ) = @_;
    return $self->client->_get_accounts;
}

sub upload_attachment {
    my ( $self,%params ) = @_;

    return Business::Mondo::Attachment->new(
        client => $self->client,
    )->upload( %params );
}

=head1 EXAMPLES

See the t/002_end_to_end.t test included with this distribution. you can run
this test against the Mondo emulator by running end_to_end_emulated.sh (this
is advised, don't run it against a live endpoint).

=head1 SEE ALSO

L<Business::Mondo::Account>

L<Business::Mondo::Attachment>

L<Business::Mondo::Balance>

L<Business::Mondo::Transaction>

L<Business::Mondo::Webhook>

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-mondo

=cut

1;

# vim: ts=4:sw=4:et
