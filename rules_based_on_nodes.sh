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
# 统一出站节点设置(如果不需要, 请注释或删除 UNIFIED_OUTBOUND_NODES() 括号中所有内容)
# 1. 在这里定义统一出站节点(For 'Routing Nodes' and 'Node Settings')
# 2. 仅支持纯英文大小写、数字和 "_" 字符。不允许重复！
# 3. 举例：
#    假设你有多个地区的节点(例如机场)，并且你在 RULESET_URLS 中定义了10个标签，执行脚本后，以下方提供的3个统一出站节点为例：
#    1) 你可以在 '节点设置(Node Settings)' 功能中为 HK/SG/US 出站节点分别选中你的机场中对应地区的节点
#    2) 分别为 RULESET_URLS 中的规则集选择不同的地区作为出站以实现个性化定制
#
#
#
# Define unified outbound nodes here (For 'Routing Nodes' and 'Node Settings').
# If you don't need them, please either comment out or delete all entries in the UNIFIED_OUTBOUND_NODES array.
#
# Only uppercase and lowercase English letters, numbers, and the '_' character are allowed, with no duplicates permitted.
# Example:
#    Suppose you have multiple nodes from different regions, and you have defined 10 tags in RULESET_URLS.
#    After excuting the script, using the three unified outbound nodes provided below as an example:
#    1. You can use the 'Node Settings' feature to select the corresponding nodes in your airport for the SG/US/JP outbound nodes.
#    2. Assign different regions as outbound nodes for the rule sets in RULESET_URLS to achieve personalized customization.


#  "SG"
#  "US_01"
#  "US_02"
#  "JP_01"
#  "CA"


)



RULESET_URLS=(

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