#!/bin/bash

RULESET_URLS=(
  "ads|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/category-ads-all.srs"

  "google|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs"

  "twitter|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs"

  "ai|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/ai.srs
  https://raw.githubusercontent.com/Toperlock/sing-box-geosite/main/rule/OpenAI.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/bing.srs"

  "telegram|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/telegram.srs"

  "tiktok|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/tiktok.srs"

  "twitch|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitch.srs"

  "nvidia|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/nvidia.srs"

  "discord|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/discord.srs"

  "netflix|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/netflix.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/netflix.srs"

  "cn|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/cn.srs"
)

DNS_SERVERS=(
  "google|https://dns.google/dns-query"

  "cloudflare|https://cloudflare-dns.com/dns-query
  1.1.1.1"
)