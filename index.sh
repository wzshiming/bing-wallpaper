#!/usr/bin/env bash

base="https://global.bing.com"

today="$(date '+%Y-%m-%d')"
last_month="$(date --date="${today} -1 month" '+%Y-%m')"

curr_month="$(date '+%Y-%m')"

function index_month_page() {
  local dir="${1}"
  local mkt="${2}"
  local year="${3}"
  local month="${4}"

  local files="$(find "${dir}" -mindepth 1 -maxdepth 1 -type f | sort)"
  local data
  local url

  echo "# index ${mkt} ${year} ${month}"
  for file in ${files}; do
    if [[ "${file}" != *.json ]]; then
      continue
    fi

    data="$(cat "${file}")"
    url="$(echo "${data}" | jq -r ".url")"
    echo
    echo "<a href=\"${base}${url}&rf=LaDigue_UHD.jpg&pid=hp&w=3840&h=2160&rs=1&c=4\">"
    echo "<img src=\"${base}${url}&rf=LaDigue_UHD.jpg&pid=hp&w=384&h=216&rs=1&c=4\" align=\"left\" loading=\"lazy\">"
    echo "</a>"
  done
}

function index_year_page() {
  local dir="${1}"
  local mkt="${2}"
  local year="${3}"

  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort)"

  echo "# index ${mkt} ${year}"
  for d in ${dirs}; do
    month="$(basename "${d}")"
    echo
    echo "<a href=\"./${month}\">${mkt} ${year} ${month}</a>"
  done
}

function index_mkt_page() {
  local dir="${1}"
  local mkt="${2}"

  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort)"

  echo "# index ${mkt}"
  for d in ${dirs}; do
    year="$(basename "${d}")"
    echo
    echo "<a href=\"./${year}\">${mkt} ${year}</a>"
  done
}

function index_page() {
  local dir="${1}"

  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort)"

  echo "# index"
  for d in ${dirs}; do
    mkt="$(basename "${d}")"
    echo
    echo "<a href=\"./${mkt}\">${mkt}</a>"
  done
}

function index_year() {
  local dir="${1}"
  local mkt="${2}"
  local year="${3}"
  local month
  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort -n)"
  local out
  for d in ${dirs}; do
    month="$(basename "${d}")"
    if [[ "${year}-${month}" != "${curr_month}" && "${year}-${month}" != "${last_month}" ]]; then
      continue
    fi
    out="./content/${d#.\/assets\/}"
    mkdir -p "${out}"
    index_month_page "${d}" "${mkt}" "${year}" "${month}" >"${out}/README.md"
  done

  index_year_page "${dir}" "${mkt}" "${year}" >"./content/${dir#.\/assets\/}/README.md"
}

function index_mkt() {
  local dir="${1}"
  local mkt="${2}"
  local year
  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort -n)"
  for d in ${dirs}; do
    year="$(basename "${d}")"
    index_year "${d}" "${mkt}" "${year}"
  done

  index_mkt_page "${dir}" "${mkt}" >"./content/${dir#.\/assets\/}/README.md"
}

function index() {
  local dir="${1}"
  local mkt
  local dirs="$(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort -n)"
  for d in ${dirs}; do
    mkt="$(basename "${d}")"
    index_mkt "${d}" "${mkt}"
  done
  index_page "${dir}" >"./content/README.md"
}

index ./assets
