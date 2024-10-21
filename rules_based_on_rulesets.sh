#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             Please rename this file to 'rules.sh' before execution!
#             请在执行脚本前把当前文件重命名为 'rules.sh'!
# **                                                                                                **
# ****************************************************************************************************


UNIFIED_OUTBOUND_NODES=(
  "SG"
  "US_01"
  "US_02"
  "JP_01"
  "CA"
)


RULESET_URLS=(
  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  "direct_out|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/cn.srs"

  "google_ruleset01|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs"
  
  "google_ruleset02|
  https://github.com/KaringX/karing-ruleset/raw/sing/geo/geosite/google-trust-services@cn.srs"

  "AI|
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-openai.srs
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-bing.srs
  https://github.com/KaringX/karing-ruleset/raw/sing/geo/geoip/ai.srs"
  
  "telegram|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/telegram.srs"
  
  "my_cn_direct|
  /etc/homeproxy/ruleset/MyDirect.json"
)


DNS_SERVERS=(
  "google_ruleset01|https://8.8.8.8/dns-query"
  "google_ruleset02_google_DoT|tls://dns.google"
  "AI_cf|https://cloudflare-dns.com/dns-query"
  "telegram_OpenDNS_DoT|tls://dns.umbrella.com"
  "my_cn_direct_AliyunUDP|223.5.5.5"

  # Other available backup DNS servers...
  "backup_server_01|https://223.5.5.5/dns-query"

  "backup_server_02|
  2400:3200:baba::1
  rcode://refused"
)