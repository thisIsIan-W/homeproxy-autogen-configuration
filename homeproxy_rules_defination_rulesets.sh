#!/bin/bash

# 注意:
# 格式为: 标签名|urls
# ****************************************************************************************************
# **                                                                                                **
#             1. 执行脚本前请先将本文件名称修改为: homeproxy_rules_defination.sh
#             2. 标签顺序、标签内的url顺序 可以随意调整, 且可以随意新增标签、删除已有标签
#             3. 所有标签名 及 url 不允许重复, 标签名允许包含纯英文大小写、数字和 "_" 字符！
#             4. 如果规则集中只存在一条url, 请确保行末尾的双引号处于当前行的末尾
#             5. 其余错误写法和注意事项请参考手册
# **                                                                                                **
# ****************************************************************************************************

RULESET_URLS=(
  # 注意 adguard 相关规则需要 sing-box 1.10.0-alpha.25 及以上版本支持
  # reject_out(拒绝出站 & 屏蔽DNS解析) 为保留名称不允许更改，但如果不希望使用该类型规则集，则直接删除 "reject_out|xxx" 行即可
  "reject_out|/etc/homeproxy/ruleset/adblockdns.srs"

  # 可以单独为其它国内出站新增多条规则集配置，也可以全部放到 direct_out 标签内
  # 单独配置的国内出站规则集分类更细致，脚本执行后可以到节点处手动更改出站节点为Direct
  "bilibili|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/bilibili.srs"
  "apple_cn|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/apple-cn.srs"
  "microsoft|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/microsoft.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/microsoft@cn.srs"

  # direct_out(直连出站 & 国内DNS解析) 为保留名称不允许更改，但如果不希望使用该类型规则集，则直接删除 "direct_out|xxx" 行即可
  # 写在 direct_out 内的规则集会自动配置为直连出站
  "direct_out|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/cn.srs"

  "google|
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs"

  "telegram|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/telegram.srs
  https://github.com/DustinWin/ruleset_geodata/raw/sing-box-ruleset/telegramip.srs"

  "discord|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/discord.srs"

  "twitch|
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-twitch.srs
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-amazon.srs
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-amazon@cn.srs
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-amazontrust.srs"

  "twitter|
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs"

  "ai|
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-openai.srs
  https://github.com/SagerNet/sing-geosite/raw/rule-set/geosite-bing.srs
  https://github.com/KaringX/karing-ruleset/raw/sing/geo/geoip/ai.srs"

  "tiktok|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/tiktok.srs"
)

DNS_SERVERS=(
  # 多个相同url的 DNS 服务器，可单独为不同的规则集分配不同的出站(可选)
  "OpenDNS_HK|https://doh.opendns.com/dns-query"
  "OpenDNS_JP|https://doh.opendns.com/dns-query"
  "OpenDNS_SG|https://doh.opendns.com/dns-query"
  "OpenDNS_US|https://doh.opendns.com/dns-query"
  "google|https://8.8.8.8/dns-query"
)