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
  "proxy_server_01_OpenDNS|https://doh.opendns.com/dns-query"
  "proxy_server_02_OpenDNS|https://doh.opendns.com/dns-query"
  "proxy_server_03_OpenDNS|https://doh.opendns.com/dns-query"


  "backup_server_01|https://223.5.5.5/dns-query"

  "backup_server_02|
  223.5.5.5
  2400:3200:baba::1
  rcode://refused"
)