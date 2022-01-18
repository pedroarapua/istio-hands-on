#!/usr/bin/env bash

set -e

BETS_HOST="pedroarapua.com"

watch -n 0,1 "curl --location --request POST 'http://localhost/api/bets' \
             --header 'Content-Type: application/json' \
             --header 'Host: ${BETS_HOST}' \
             --data-raw '{}' -s -w '\n%{time_total}s %{http_code}\n' "


