#!/bin/bash

# start emulator
morbo mondo_emulator.pl -l 'https://*:3000' &
sleep 2;

# get an access token
ACCESS_TOKEN=$(http --verify no --form POST "https://127.0.0.1:3000/oauth2/token" \
    "grant_type=password" \
    "client_id=test_client" \
    "client_secret=test_client_secret" \
    "username=leejo" \
    "password=Weeeee" \
    | jq -r '.access_token' \
)

# run end_to_end tests
MONDO_DEBUG=1 \
    MONDO_ENDTOEND=1 \
    MONDO_TOKEN=$ACCESS_TOKEN \
    MONDO_URL='https://127.0.0.1:3000' \
    SKIP_CERT_CHECK=1 \
    prove -v -Ilib t/002_end_to_end.t

# stop emulator
pkill -f 'morbo mondo_emulator';
