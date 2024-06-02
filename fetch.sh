#!/usr/bin/env bash

base="https://global.bing.com"

function get_today_image() {
  local mkt="${1}"
  local lang="${2:-${mkt}}"
  local data="$(curl "${base}/HPImageArchive.aspx?format=js&idx=0&n=9&pid=hp&uhd=1&uhdwidth=3840&uhdheight=2160&setmkt=${mkt}&setlang=${lang}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'cache-control: no-cache' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0')"

  local dates="$(echo "${data}" | jq -r '.images[] | .enddate')"
  local year
  local month
  local day

  for date in ${dates}; do
    year="${date::4}"
    month="${date:4:2}"
    day="${date:6}"
    mkdir -p "./assets/${mkt}/${year}/${month}"
    echo "${data}" | jq -r ".images[] | select(.enddate == \"${date}\") | { \"enddate\": .enddate, \"url\": .url, \"copyright\": .copyright, \"copyrightlink\": .copyrightlink }" |
      sed 's#&rf=LaDigue_UHD.jpg&pid=hp&w=3840&h=2160&rs=1&c=4##g' \
        >"./assets/${mkt}/${year}/${month}/${day}.json"
  done
}

regions="$(cat ./locales.json | jq -r '.[].market_code')"

for region in ${regions}; do
  get_today_image "${region}"
done
