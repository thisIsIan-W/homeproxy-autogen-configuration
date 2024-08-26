# homeproxy-autogen-configuration
一种更简单的生成 luci-app-homeproxy 配置的方法(aka 懒人脚本)。<br/>
请从 [下载链接](https://fantastic-packages.github.io/packages/releases/) 下载适用于你机器架构的安装包安装！
<br/>
<br/>

## 使用手册

推荐使用 VSCode 等编辑器更改配置内容。

1. 下载2个脚本文件到你的设备上；
2. 自定义 `homeproxy_rules_definations.sh` 文件中的配置(下方提供详细说明);
3. 把2个脚本上传到你需要执行透明代理的设备上，目录随意，并赋予其执行权限;
```shell
chmod +x homeproxy_rules.sh
chmod +x homeproxy_rules_defination.sh
```
4. 备份原有的 `/etc/config/homeproxy` 文件（**重要!!!** 脚本执行会直接覆盖原文件）；
5. 执行以下命令继续生成配置：
```shell
bash homeproxy_rules.sh
```
6. 刷新homeproxy界面，之后：
   1. 手动添加订阅，并在`节点设置 - 节点` 为每个自定义节点配置相应的出站；
   2. 若配置了 `reject_out` 规则集，则需要在 `DNS 规则(DNS Rules)` 以及 `路由规则(Routing Rules)` 中将该规则拖拽到合适的顺序上
7. 进入 `服务状态` 功能，点击 **Clash dashboard version** 右侧的更新按钮更新UI



<br/>
<br/>

## 注意事项

### RULESET_URLS

RULESET_URLS 中的规则配置为：**"规则集自定义名称|urls"** <br/>

最终生成的规则集、DNS规则、路由规则、路由节点等的顺序会 **严格按照规则集定义的顺序** 添加到列表中。

<br/>

<br/>

#### 写法

* ***规则集自定义名称*** 不允许重复！

* ***规则集自定义名称*** 及 ***URL***允许包含 "-" 和 "_" 字符，支持纯英文大小写及数字，但不支持 `@*#` 等特殊字符(比如 `google@cn.srs`/ `google#cn`)!；

* 所有规则集中的url都可以自行增删、替换；

* 如果规则集中只存在一条url，请确保行末尾的双引号处于当前行的末尾

  * 注意规则集的顺序

  ```shell
  # 单行写法示例
  RULESET_URLS=(
    "google|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google-cn.srs"
  )
  
  DNS_SERVERS=(
    "google|https://dns.google/dns-query"
  )
  ```

  ```shell
  # 多行写法示例
  RULESET_URLS=(
    "google|url1
    url2
    url3"
  )
  
  DNS_SERVERS=(
    "google|url1
    url2
    url3"
  )
  ```
  
  
  
* ***错误写法示例***

  ```shell
  # 错误写法一：
  RULESET_URLS=(
    "google|url
    "
  )
  # 错误写法二(不允许在url列表中使用注释符号 --> #)：
  RULESET_URLS=(
    "google|url1
    #url2
    url3"
  )
  # 错误写法三（不支持下载的规则集文件名中包含@等特殊符号）：
  RULESET_URLS=(
    "google|https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo/geosite/google@cn.srs"
  )
  ```

  

* 以下 3 种写法任选其一




#### 写法一：按照机场分组

把 `airport_0x` 以及 `url` 替换为你自己的机场名称和规则集url即可。

```shell
RULESET_URLS=(
  # reject_out 为保留名称不允许更改！
  # 如果不希望添加拒绝出站的规则集，直接删除 "reject_out|xxx" 行即可！
  "reject_out|url"

  "airport_01|url"

  "airport_02|url"

  "airport_03|url"

  # 可以添加更多...
  
  # direct_out 为保留名称不允许更改！
  # 不允许删除 direct_out 行，但可修改url内容！
  "direct_out|url"
)
```



#### 写法二：按照节点分组

替换节点名称和url为你的配置即可。

```shell
RULESET_URLS=(
  # reject_out 为保留名称不允许更改！
  # 如果不希望添加拒绝出站的规则集，直接删除 "reject_out|xxx" 行即可！
  "reject_out|url"
  
  "us_node|url"

  "sg_node|url"
  
  # direct_out 为保留名称不允许更改！
  # 不允许删除 direct_out 行，但可修改url内容！
  "direct_out|url"
)
```



#### 写法三：按照规则集合分组

替换名称和url为你的配置即可。

```shell
RULESET_URLS=(
  # 如果不希望添加拒绝出站的规则集，直接删除 "reject_out|xxx" 行即可！
  # reject_out 为保留名称不允许更改！
  "reject_out|url"
  
  "google|url"

  "twitter|url"
  
  # direct_out 为保留名称不允许更改！
  # 不允许删除 direct_out 行，但可修改url内容！
  "direct_out|url"
)
```

<br/>

<br/>

<br/>

### DNS_SERVERS

在这里配置你想要使用的 ***DNS服务商***。

* 命名规则为：***"DNS服务商自定义名称|urls"***；
* ***第一条配置里的第一个url*** 会被作为默认DNS服务器在 `DNS 规则` 中选中；
* 格式与上方自定义规则集列表中的格式相同；
* DNS 服务器可随意增删修改，不存在保留名称；

```shell
DNS_SERVERS=(
  "google|url"

  "cloudflare|url"

  "tencent|url1
  url2"

  "opendns|url"
  
  # 可以添加更多......
)
```
