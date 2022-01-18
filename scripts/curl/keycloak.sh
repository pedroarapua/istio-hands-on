#!/usr/bin/env bash

KEYCLOACK_HOST="" # set keycloack_host
CLIENT_SECRET="" # set client_secret credential

## user with scope 'match:read'
curl -v -X POST "http://${KEYCLOACK_HOST}/auth/realms/istio/protocol/openid-connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "client_id=bets" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=teste1' \
    --data-urlencode 'password=teste1' \
    --data-urlencode "client_secret=${CLIENT_SECRET}" \
    -s -w '\n%{time_total}s %{http_code}\n'


CLIENT_SECRET="" # set client_secret credential
## user with scopes 'players:read' 'bet:write' 'matches:read' 'championship:read'
curl -v -X POST "http://${KEYCLOACK_HOST}/auth/realms/istio/protocol/openid-connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "client_id=matches" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=teste2' \
    --data-urlencode 'password=teste2' \
    --data-urlencode "client_secret=${CLIENT_SECRET}" \
    -s -w '\n%{time_total}s %{http_code}\n'
