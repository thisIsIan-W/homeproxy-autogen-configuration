#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             更多模板请参考 rules_templates 文件夹下的文件！
# **                                                                                                **
# ****************************************************************************************************


SUBSCRIPTION_URLS=(
  # Define your subscription url(s) here.
  # The format should be: "URL#Your_proxy_server_name"

  "https://abc.xyz#airport01"
  "https://123.abc#airport02"

)


RULESET_URLS=(

  "reject_out|
  /etc/homeproxy/ruleset/adblockdns.srs
  /etc/homeproxy/ruleset/reject-ruleset1.json
  https://reject-ruleset2.json
  https://reject-ruleset3.srs"

  "direct_out|
  https://cn.srs"

  "HongKong_common|
  https://google.srs
  https://youtube.srs"

  "HongKong_others|
  https://telegram.srs
  https://telegramip.json"

  "Japan_01|
  https://geosite-twitter.srs
  https://x.srs
  https://twitter.srs"

  "USA|
  https://geosite-openai.srs
  https://bing.srs"
  
  # ------------------ Start 特殊规则集单独选择节点出站(按需使用) ------------------
  "google_ruleset01|
  https://google.srs
  https://google-cn.srs"
  
  "google_ruleset02|
  https://google-trust-services@cn.srs"
  # ------------------ End   特殊规则集单独选择节点出站(按需使用) ------------------

  # More...

)


DNS_SERVERS=(

  "HongKong_common_cf_DoH|https://1.1.1.1/dns-query"
  "HongKong_others_cf_UDP|1.1.1.1"

  "Japan_01|https://doh.opendns.com/dns-query"
  "USA|https://doh.opendns.com/dns-query"

  # ------------------ Start 特殊规则集单独选择DNS服务器 ------------------
  "google_ruleset01|https://8.8.8.8/dns-query"
  "google_ruleset02_google_DoT|https://1.1.1.1/dns-query"
  # ------------------ End   特殊规则集单独选择DNS服务器 ------------------

  "my_cn_direct_TencentUDP|119.29.29.29"

  # 223.5.5.5 会作为默认DNS服务器被选中
  "backup_servers|
  223.5.5.5
  8.8.8.8
  rcode://refused"
)