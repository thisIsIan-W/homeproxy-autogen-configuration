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