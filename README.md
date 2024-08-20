# homeproxy-autogen-configuration
一种更简单的生成 [luci-app-homeproxy](https://github.com/muink/luci-app-homeproxy) 配置的方法。

## 使用手册
1. 下载2个脚本文件到你的设备上；
2. 自定义 `homeproxy_rules_definations.sh` 文件中的配置;
3. 把2个脚本上传到你需要执行透明代理的设备上，并赋予其执行权限;
```shell
chmod +x homeproxy_rules.sh
chmod +x homeproxy_rules_defination.sh
```
4. 备份原有的 `/etc/config/homeproxy` 文件（**重要!!!**，脚本执行会直接覆盖原文件）；
5. 执行以下命令继续生成配置：
```shell
bash homeproxy_rules.sh
```
6. 刷新homeproxy界面，手动添加订阅，并更新`节点设置 - 节点` 中的配置为你自己的分流配置。


<br/>
<br/>
## 注意事项


### RULESET_URLS

套用以下规则前请删除每行行首的"#"字符。

```shell

# RULESET_URLS 中的规则配置为：规则集自定义名称(小写)|规则集urls

# 由于 luci 的限制，规则集自定义名称不允许包含 "-" 等特殊字符，如果发现刷新网页后提示 luci 错误，把特殊字符删掉重新生成再试！
# 以下 3 种方式三选一，请严格参照已存在规则集格式新增！


# 按照机场分组
# RULESET_URLS=(
#   "aiport_01|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
#   ... 可以添加更多"

#   "aiport_02|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
#   ... 可以添加更多"
# )

# 代理节点分组方法：
# RULESET_URLS=(
#   "us_node|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs
#   ... 可以添加更多"

#   "sg_node|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
#   ... 可以添加更多"
# )

# 规则集名称分组方法：
# RULESET_URLS=(
#   "google|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs
#   ... 可以添加更多"

#   "twitter|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
#   https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
#   ... 可以添加更多"
# )
```

### DNS_SERVERS

```shell
DNS_SERVERS=(
  "google|https://dns.google/dns-query"

  "cloudflare|https://cloudflare-dns.com/dns-query
  1.1.1.1"
)
```
