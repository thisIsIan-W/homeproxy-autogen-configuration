#!/bin/bash

RULESET_URLS=(
  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  "hk_node_1|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/telegram.srs"

  "hk_node_2|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs"

  "direct_out|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/cn.srs"
)

DNS_SERVERS=(
  "Cloudflare|https://cloudflare-dns.com/dns-query"
  "Google|https://dns.google/dns-query"
)