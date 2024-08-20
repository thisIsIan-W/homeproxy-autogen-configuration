# homeproxy-autogen-configuration
一种更简单的生成 [luci-app-homeproxy](https://github.com/muink/luci-app-homeproxy) 配置的方法。<br/>
可以做到除节点配置项以外的其它绝大部分配置全部自动按照自定义规则集模板生成。

## 使用手册
1. 下载2个脚本文件到你的设备上；
2. 自定义 `homeproxy_rules_definations.sh` 文件中的配置;
3. 把2个脚本上传到你需要执行透明代理的设备上，目录随意，并赋予其执行权限;
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

RULESET_URLS 中的规则配置为：**规则集自定义名称(小写)|规则集urls** <br/>
由于 luci 的限制，规则集自定义名称不允许包含 "-" 等特殊字符，如果发现刷新网页后提示 luci 错误，把特殊字符删掉重新生成再试! <br/>
以下 3 种方式三选一，请严格参照已存在规则集格式新增！<br/>


#### 按照机场分组

```shell
RULESET_URLS=(
  "airport_01|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
  ... 可以添加更多"

  "airport_02|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
  ... 可以添加更多"
)
```


#### 按照代理节点分组
```shell
RULESET_URLS=(
  "us_node|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs
  ... 可以添加更多"

  "sg_node|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
  ... 可以添加更多"
)
```

#### 按照规则集合分组

```shell
RULESET_URLS=(
  "google|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/googlefcm.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/google.srs
  ... 可以添加更多"

  "twitter|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geoip/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/twitter.srs
  https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/x.srs
  ... 可以添加更多"
)
```

### DNS_SERVERS

在这里配置你想要使用的DNS服务商，命名方式、规则和前面的规则集配置相同。

```shell
DNS_SERVERS=(
  "google|https://dns.google/dns-query
  8.8.8.8
  ...可以添加更多"

  "cloudflare|https://cloudflare-dns.com/dns-query
  1.1.1.1"

  "tencent|https://doh.pub/dns-query
  https://1.12.12.12/dns-query"

  "aliyun|https://dns.alidns.com/dns-query
  https://223.5.5.5/dns-query
  223.5.5.5"

  "opendns|https://doh.opendns.com/dns-query
  https://dns.umbrella.com/dns-query"
)
```
