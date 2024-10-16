#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             Please rename this file to 'rules.sh' before execution!
#             请在执行脚本前把当前文件重命名为 'rules.sh'!
#
#             You may remove all # symbols along with the content that follows.
#             所有 # 符号及其后的内容都可以删除。
#
# **                                                                                                **
# ****************************************************************************************************




UNIFIED_OUTBOUND_NODES=(

#
#
# 规则集设置。格式为：标签名|URL(s)/Linux绝对路径/两者
# 1. 标签顺序、标签内的url顺序 可以随意调整, 且可以随意新增标签、删除已有标签
# 2. 所有标签名 及 所有url 不允许重复, 标签名允许包含纯英文大小写、数字和 "_" 字符！
# 3. 请确保行末双引号紧挨着最后一个字符
# 4. reject_out(拒绝出站 & 屏蔽DNS解析) 和 direct_out(直连出站 & 国内DNS解析)为保留名称不允许更改，
#    如果不希望使用该类型规则集，则直接删除 "xxx_out|URL(s)" 行即可
#
#
#
# Rule sets.
# The format should be: "Tag name|URL(s), Linux absolute paths, or both"
# 1. You can freely adjust the order of the tags and the URLs within each tag, as well as add or delete tags at will.
# 2. All tag names and URL(s) must be unique; tag names may consist of uppercase and lowercase English letters, numbers, and underscores ("_").
# 3. Make sure that the double quotes at the end of the line are right next to the last character.
# 4. The "reject_out" tag(for rejecting outbound connections & blocking DNS resolution, This feature is supported in sing-box version 1.10.0-alpha.25 and above)
#    and the "direct_out" tag (for direct outbound connections & domestic DNS resolution) are reserved and unchangeable.
#    If you do not wish to use either of these two types of rule sets, simply delete the line 'xxx_out|URL(s)'.


  "SG"
  "US_01"
  "US_02"
  "JP_01"
  "CA"


)



RULESET_URLS=(


#
#
# 规则集设置。格式为：标签名|URL(s)/Linux绝对路径/两者
# 1. 标签顺序、标签内的url顺序 可以随意调整, 且可以随意新增标签、删除已有标签
# 2. 所有标签名 及 所有url 不允许重复, 标签名允许包含纯英文大小写、数字和 "_" 字符！
# 3. 请确保行末双引号紧挨着最后一个字符
# 4. 脚本会按照你指定的规则集顺序在界面生成相应的内容
# 5. 脚本会自动生成 clash_direct 和 clash_global 的出站规则、DNS规则并自动为你设置好规则,
#    如需更多 clash 规则，请在 EXTRA_OUTBOUND_NODES 模块中定义
# 6. reject_out(拒绝出站 & 屏蔽DNS解析) 和 direct_out(直连出站 & 国内DNS解析)为保留名称不允许更改，+
#    如果不希望使用该类型规则集，则直接删除 "xxx_out|URL(s)" 行即可
#
#
#
# Rule sets.
# The format should be: "Tag name|URL(s), Linux absolute paths, or both"
# 1. You can freely adjust the order of the tags and the URLs within each tag, as well as add or delete tags at will.
# 2. All tag names and URL(s) must be unique; tag names may consist of uppercase and lowercase English letters, numbers, and underscores ("_").
# 3. Make sure that the double quotes at the end of the line are right next to the last character.
# 4. The script will generate the corresponding content on the interface according to the order of the rule sets you specify.
# 5. The script will automatically create outbound rules for clash_direct and clash_global,
#    along with DNS rules, and set them up for you. If you require additional clash rules, please define them in the EXTRA_OUTBOUND_NODES module.
# 6. The "reject_out" tag(for rejecting outbound connections & blocking DNS resolution, This feature is supported in sing-box version 1.10.0-alpha.25 and above)
#    and the "direct_out" tag (for direct outbound connections & domestic DNS resolution) are reserved and unchangeable.
#    If you do not wish to use either of these two types of rule sets, simply delete the line 'xxx_out|URL(s)'.


  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  "direct_out|https://cn.srs"

  "bilibili|https://bilibili.srs"

  "apple|https://apple.srs"

  "microsoft|https://microsoft.srs
  https://microsoft-all.srs"

  "google|
  https://google.srs
  https://youtube.srs"

  "telegram|https://telegram.srs
  https://telegramip.srs"

  "discord|https://discord.srs"

  "twitch|
  https://geosite-twitch.srs
  https://geosite-amazon.srs
  https://geosite-amazon@cn.srs
  https://geosite-amazontrust.srs"

  "twitter|
  https://geosite-twitter.srs
  https://x.srs
  https://twitter.srs"

  "ai|https://geosite-openai.srs
  https://bing.srs"

  "tiktok|https://tiktok.srs"
)

DNS_SERVERS=(
  # Support UDP, TCP, DoT, DoH and RCode.


  "OpenDNS_HK|https://doh.opendns.com/dns-query"
  "OpenDNS_SG|https://doh.opendns.com/dns-query"
  "OpenDNS_US|https://doh.opendns.com/dns-query"

  "google|https://8.8.8.8/dns-query
  8.8.8.8
  tls://dns.google"

  "aliyun|223.5.5.5
  2400:3200:baba::1"

  "reject_dns|rcode://refused"
)