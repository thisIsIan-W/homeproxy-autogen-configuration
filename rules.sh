#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#
#             更多模板请参考 rules_templates 文件夹下的文件！
#
# **                                                                                                **
# ****************************************************************************************************


SUBSCRIPTION_URLS=(
  # Define your subscription url(s) here.
  # The format should be: "URL#Your_proxy_server_name"
  # Note:
  #   If 'Your_proxy_server_name' includes Chinese or other non-utf8 characters, make sure to change the encoding of this file to UTF-8.

  "https://abc.xyz#my_proxy_server_01"
  "https://456.com#my_proxy_server_02"

)


RULESET_URLS=(

  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs
  https://raw.githubusercontent.com/privacy-protection-tools/anti-ad.github.io/master/docs/anti-ad-sing-box.srs"

  "HK_proxy_server_01|
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/googlefcm.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google-play.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google-cn.srs
  https://raw.githubusercontent.com/KaringX/karing-ruleset/sing/geo/geosite/google-trust-services@cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google-gemini.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/google.srs"

  "SG_proxy_server_01|
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-openai.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-bing.srs
  https://raw.githubusercontent.com/KaringX/karing-ruleset/sing/geo/geoip/ai.srs"

  "SG_proxy_server_02|
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-discord.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-twitch.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-amazon.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-amazon@cn.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-amazontrust.srs"

  "US_proxy_server_02|
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-twitter.srs
  https://raw.githubusercontent.com/SagerNet/sing-geosite/refs/heads/rule-set/geosite-x.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/twitter.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/telegram.srs
  https://github.com/DustinWin/ruleset_geodata/raw/sing-box-ruleset/telegramip.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/tiktok.srs"

  "direct_out|
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/cn.srs
  https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/cn.srs"

  # More...
)


DNS_SERVERS=(

  "HongKong_common_your_suffix|Your_dns_server_url"
  "HongKong_others_your_suffix|Your_dns_server_url"
  "Japan_01|Your_dns_server_url"
  "USA|Your_dns_server_url"
  "google_ruleset01|Your_dns_server_url"
  "google_ruleset02|Your_dns_server_url"

  # The first URL in the last tag of this array will be the default dns server's URL.
  # In this case, Your_dns_server_url1 will be chosen to be the one.
  "backup_servers|
  Your_dns_server_url1
  Your_dns_server_url2
  Your_dns_server_url3"
)