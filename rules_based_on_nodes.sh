#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             Please rename this file to 'rules.sh' before execution!
#             请在执行脚本前把当前文件重命名为 'rules.sh'!
# **                                                                                                **
# ****************************************************************************************************


SUBSCRIPTION_URLS=(
  # Define your subscription url(s) here.
  # The format should be: "URL"

  "https://abc.xyz"
  "https://123.abc"

)


RULESET_URLS=(
# Rule sets.
# The format should be: "Tag name|URL(s), Linux absolute paths, or both"
# 1. You can freely adjust the order of the tags and the URLs within each tag, as well as add or delete tags at will.
# 2. All tag names and URL(s) must be unique; tag names may consist of uppercase and lowercase English letters, numbers, and underscores ("_").
# 3. The script will generate the corresponding content on the interface according to the order of the rule sets you specify.
# 4. The "reject_out" tag(for rejecting outbound connections & blocking DNS resolution, This feature is supported in sing-box version 1.10.0-alpha.25 and above)
#    and the "direct_out" tag (for direct outbound connections & domestic DNS resolution) are reserved and unchangeable.
#    If you do not wish to use either of these two types of rule sets, simply delete the line 'xxx_out|URL(s)'.

  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  "direct_out|https://cn.srs"

  "HK_01|
  https://google.srs
  https://youtube.srs"

  "HK_02|https://telegram.srs
  https://telegramip.srs"

  "SG_IPv4|https://discord.srs"

  "SG_IPv6|https://discord.srs"

  "JP_01|
  https://geosite-twitter.srs
  https://x.srs
  https://twitter.srs"

  "MY_01|https://geosite-openai.srs
  https://bing.srs"

)


DNS_SERVERS=(
  #
  # Tips 推荐写法( 可选 Optional )：
  #
  #    RULESET_URLS(
  #
  #       "HongKong_01|URL"
  #       "HK_02|URL"
  #       "USA_California|URL"
  #       "USA_Utah|URL"
  #
  #       "direct_out|URL"
  #       "reject_out|URL"
  #    )
  #
  #    DNS_SERVERS(
  #       # 格式："RULESET_URLS标签名_后缀(后缀可选)|URL"
  #
  #       "HongKong_01_Cloudflare|URL"
  #       "HK_02_Google|URL"
  #       "USA_California_OpenDNS|URL"
  #       "USA_Utah_OpenDNS|URL"
  #    )
  # 
  #
  # 如果你不想使用上述功能，则可以定义任意数量、任意标签名(需要符合命名规范)的DNS服务器。
  # 脚本会在 DNS规则(DNS Rules) 中为所有规则集标签选取 [最后一个标签下的第一条URL] 作为默认服务器(当前示例为 2400:3200:baba::1)。


  "HK_01_cf_DoH|https://1.1.1.1/dns-query"
  "HK_02_cf_DoH|https://1.1.1.1/dns-query"
  "SG_IPv4_GoogleDoH|https://8.8.8.8/dns-query"
  "SG_IPv6_GoogleDoT|tls://dns.google"

  "JP_01|https://doh.opendns.com/dns-query"
  "MY_01|https://doh.opendns.com/dns-query"

  # Other available backup DNS servers...
  "backup_server_01|https://223.5.5.5/dns-query"

  "backup_server_02|
  2400:3200:baba::1
  rcode://refused"
)