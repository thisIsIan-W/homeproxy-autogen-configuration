#!/bin/bash

RULESET_URLS=(
  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  "LMY_HK|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/telegram.srs"

  "LMY_SG|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitch.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/discord.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/nvidia.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/category-porn.srs"

  "LMY_US|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/netflix.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/netflix.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/ai.srs
  https://raw.githubusercontent.com/Toperlock/sing-box-geosite/main/rule/OpenAI.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/bing.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/jetbrains-ai.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/jetbrains.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/tiktok.srs"

  "BYG_HK|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google@cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-trust-services@cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/googlefcm.json
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs"

  "direct_out|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/microsoft@cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/microsoft-dev@cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/microsoft-pki@cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/apple@cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/cn.srs"
)

DNS_SERVERS=(
  "Cloudflare|https://cloudflare-dns.com/dns-query"
  "Google|https://dns.google/dns-query"
)