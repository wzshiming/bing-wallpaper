#!/usr/bin/env bash

# https://www.searchapi.io/docs/parameters/bing/market-code
function get_locales() {
  curl "https://www.searchapi.io/docs/parameters/bing/market-code.json" | jq .
}

get_locales >locales.json
