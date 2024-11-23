#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             Please rename this file to 'rules.sh' before execution
#             请在执行脚本前把当前文件重命名为 rules.sh
# **                                                                                                **
# ****************************************************************************************************


SUBSCRIPTION_URLS=(
  # Define your subscription url(s) here.
  # The format should be: "URL#Your_proxy_server_name"

  "https://abc.xyz#airport01"
  "https://123.abc#airport02"

)


RULESET_URLS=(
  # Rule sets.
  #
  # The format should be: "Tag name|URL(s), Linux absolute paths, or both"
  # 1. You can freely adjust the order of the tags and the URLs within each tag, as well as add or delete tags at will.
  # 2. All tag names and URL(s) must be unique; tag names may consist of uppercase and lowercase English letters, numbers, and underscores ("_").
  # 3. The script will generate the corresponding content on the interface according to the order of the rule sets you specify.
  # 4. The "reject_out" tag(for rejecting outbound connections & blocking DNS resolution, This feature is supported in sing-box version 1.10.0-alpha.25 and above)
  #    and the "direct_out" tag (for direct outbound connections & domestic DNS resolution) are reserved and unchangeable.
  #    If you do not wish to use either of these two types of rule sets, simply delete the line 'xxx_out|URL(s)'.

  "reject_out|
  /etc/homeproxy/ruleset/adblockdns.srs
  /etc/homeproxy/ruleset/reject-ruleset1.json
  https://reject-ruleset2.json
  https://reject-ruleset3.srs"

  "direct_out|
  https://cn.srs
  https://cn.srs"

  "google_ruleset01|
  https://google.srs
  https://google-cn.srs"
  
  "google_ruleset02|
  https://google-trust-services@cn.srs"

  "AI|
  https://geosite-openai.srs
  https://geosite-bing.srs
  https://ai.srs"
  
  "telegram|
  https://telegram.srs
  https://telegram-ip.json"
  
  "my_cn_direct|
  /etc/homeproxy/ruleset/MyDirect.json"

  # More...

)


DNS_SERVERS=(
  #
  # Tips 推荐写法( 可选 Optional )：
  #
  #    RULESET_URLS(
  #       "HongKong_01|URL(s)"
  #       "HK_02|URL(s)"
  #       "USA_California|URL(s)"
  #       "USA_Utah|URL(s)"
  #
  #       "direct_out|URL(s)"
  #       "reject_out|URL(s)"
  #    )
  #
  #    DNS_SERVERS(
  #       格式："RULESET_URLS标签名_后缀|URL", 其中后缀可选
  #         如：HongKong_01_suffix|8.8.8.8
  #
  #       "HongKong_01_Cloudflare|URL"
  #       "HK_02_Google|URL"
  #       "USA_California_OpenDNS|URL"
  #       "USA_Utah_OpenDNS|URL"
  #    )
  #
  # 脚本会选取 [最后一个 DNS_SERVERS 标签下的第一条URL] 作为默认服务器 (当前示例为 https://223.5.5.5/dns-query).

  "google_ruleset01|https://8.8.8.8/dns-query"
  
  "google_ruleset02_google_DoT|https://1.1.1.1/dns-query"
  
  "AI|https://1.1.1.1/dns-query"
  
  "telegram|https://1.1.1.1/dns-querym"
  
  "my_cn_direct_AliyunUDP|119.29.29.29"

  # Other available backup DNS servers...
  "backup_servers|
  https://223.5.5.5/dns-query
  2400:3200:baba::1
  rcode://refused"
)