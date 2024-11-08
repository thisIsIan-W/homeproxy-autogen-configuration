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

  "direct_out|https://cn.srs"

  "proxy_server_01|
  https://google.srs
  https://youtube.srs"

  "proxy_server_02|
  https://telegram.srs
  https://telegramip.srs"

  "proxy_03|https://discord.srs"
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
  # 脚本会在 DNS规则(DNS Rules) 中为所有规则集标签选取 [最后一个标签下的第一条URL] 作为默认服务器(当前示例为 223.5.5.5)。

  "proxy_server_01_OpenDNS|https://doh.opendns.com/dns-query"
  "proxy_server_02_OpenDNS|https://doh.opendns.com/dns-query"
  "proxy_server_03_OpenDNS|https://doh.opendns.com/dns-query"


  "backup_server_01|https://223.5.5.5/dns-query"

  "backup_server_02|
  223.5.5.5
  2400:3200:baba::1
  rcode://refused"
)