#!/bin/bash

# ****************************************************************************************************
# **                                                                                                **
#             Please rename this file to 'rules.sh' before execution!
#             请在执行脚本前把当前文件重命名为 'rules.sh'!
# **                                                                                                **
# ****************************************************************************************************




UNIFIED_OUTBOUND_NODES=(
#
#
# 多地区多节点统一出站设置。格式为："出站节点名称"。
# 要求：
#    所有节点名不允许重复, 每个名称允许包含纯英文大小写、数字和 "_" 字符！
# 多地区多节点用户(如机场)，可通过此功能统一配置地区出站节点。此处所有的节点会按照定义顺序以最高优先级(除Auto_Select节点外)生成至 '节点设置(Node Settings)' 功能中。
# 如果不想使用此功能，可直接删除 UNIFIED_OUTBOUND_NODES(xxx) 行。
#
#
#
# Unified node settings for multiple regions and nodes.
#
# All node names must be unique, and each name may include only uppercase and lowercase English letters, numbers, and underscores ("_").
#
# For users with multiple regions and nodes servers(such as airport-proxy services),
# this feature allows for unified regional outbound node configuration. The nodes defined here will be generated in the "Node Settings" section in the specified order,
# with the highest priority (excluding the Auto_Select node).
#
# If you do not need this feature, you can delete the whole UNIFIED_OUTBOUND_NODES(xxx) line.


#  "SG"
#  "US_01"
#  "US_02"
#  "JP_01"
#  "CA"


)



RULESET_URLS=(
#
#
# 规则集设置。格式为："标签名|URL(s)/Linux绝对路径/两者"
# 1. 标签顺序、标签内的url顺序 可以随意调整, 且可以随意新增标签、删除已有标签
# 2. 所有标签名 及 所有url 不允许重复, 标签名允许包含纯英文大小写、数字和 "_" 字符！
# 3. 脚本会按照你指定的规则集顺序在界面生成相应的内容
# 4. reject_out(拒绝出站 & 屏蔽DNS解析) 和 direct_out(直连出站 & 国内DNS解析)为保留名称不允许更改，+
#    如果不希望使用该类型规则集，则直接删除 "xxx_out|URL(s)" 行即可
#
#
#
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

  "SG_01|https://discord.srs"

  "JP_01|
  https://geosite-twitter.srs
  https://x.srs
  https://twitter.srs"

  "MY_01|https://geosite-openai.srs
  https://bing.srs"

)

DNS_SERVERS=(
  # Support UDP, TCP, DoT, DoH and RCode.


  "OpenDNS_HK|https://doh.opendns.com/dns-query"
  "OpenDNS_SG|https://doh.opendns.com/dns-query"
  "OpenDNS_JP|https://doh.opendns.com/dns-query"
  "OpenDNS_MY|https://doh.opendns.com/dns-query"

  "google|https://8.8.8.8/dns-query
  8.8.8.8
  tls://dns.google"

  "aliyun|223.5.5.5
  2400:3200:baba::1"

  "reject_dns|rcode://refused"
)