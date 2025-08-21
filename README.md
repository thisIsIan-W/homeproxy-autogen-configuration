# homeproxy-autogen-configuration

## English

An alternative way to generate your dedicated [HomeProxy](https://github.com/immortalwrt/homeproxy) configuration on ImmortalWrt/OpenWrt(23.05.x+) and simplify the major setup process significantly.

### Introduction

* Save substantial time for repetitive chores in configuration;
* Provide an alternative solution to solve the potential issues that homeproxy cannot start or be used normally due to incorrect operations and other reasons.



### Steps

#### 1. Execute the Script

Prepare the runtime environment necessary for the script execution via (Skip this step if it has already been prepared):

```bash
opkg update
opkg install bash jq curl
```

, then:

* (Required) Customize your dedicated [rules.sh](https://gist.github.com/thisIsIan-W/2c582a751e56c1a3f36d9ce48e312b31) configuration by using Secret Gist or other private links;
* Execute the given script on your ImmortalWrt/OpenWrt(23.05.x+) system (You will be asked for the URL of your dedicated 'rules.sh' script during the execution):

```bash
bash -c "$(curl -fsSl https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* Done!

<br/>

#### 2. Manual Configuration

**In your browser,** open the ImmortalWrt/OpenWrt admin panel. (**For a clean session, it's recommended to use an incognito/private window and refresh the page.)**

*   Client Settings
    *   Routing Settings
        *   Select one of the Default Outbound nodes
        *   Save
    *   Routing Nodes
        *   Select the Outbound Node(s)
        *   Save
    *   DNS Settings
        *   Modify the Default DNS Server
        *   Save
    *   DNS Servers (Optional)
        *   Manually select the `Address Resolver` for each entry (i.e., which DNS server to use for resolving the current DNS server's URL/hostname)
        *   Save
    *   DNS Rules (Optional)
        *   Manually select the `Server` for each entry (i.e., which DNS server to use for resolving all domains under the current DNS rule)
        *   Save
    *   Save & Apply

All done!

<br/>

---

<br/>

## 中文

一个更方便地生成 ImmortalWrt/OpenWrt(23.05.x+) [HomeProxy](https://github.com/immortalwrt/homeproxy) 插件大多数常用配置的脚本。

### 简介

* 节省大量重复配置所需的时间；
* 提供替代方案，解决由于潜在的配置不当等原因导致 HomeProxy 无法启动或正常使用的问题。



### 使用步骤

#### 1. 执行脚本

准备脚本运行时所需环境（如已准备，则跳过此步）：

```bash
opkg update
opkg install bash jq curl
```

，然后：

* (必备) 通过私密 Gist 或其它可被正常访问的私有链接定制你的专属 [rules.sh](https://gist.github.com/thisIsIan-W/2c582a751e56c1a3f36d9ce48e312b31) 配置内容；
* 执行以下命令（脚本执行期间会向你索要你的定制配置URL）：

```bash
bash -c "$(curl -fsSl https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* 完成！

<br/>

#### 2. 界面操作

回到浏览器 (推荐使用无痕标签页重新登陆后台，并刷新 HomeProxy 界面)：

* 客户端设置
  * 路由设置
    * 默认出站
      * 若 `rules.sh` 的规则集仅匹配直连其余全部走代理，选择`你自定义的某个代理节点`
      * 若 `rules.sh` 的规则集仅匹配代理其余全部走直连，选择`直连`
    * 保存
  * 路由节点
    * 选择出站节点
    * 保存
  * DNS 设置
    * 修改默认 DNS 服务器
    * 若 `rules.sh` 的规则集匹配直连其余全部走代理，选择`境外 DNS 服务器`
    * 若 `rules.sh` 的规则集匹配代理其余全部走直连，选择`国内 DNS 服务器`
    * 保存
  * DNS 服务器 (可选)
    * 手动为每一个条目选择 `地址解析器`，也就是用哪个 DNS 服务器解析当前 DNS 服务器 URL
    * 保存
  * DNS 规则 (可选)
    * 手动为每一个条目选择 `服务器`，也就是用哪个 DNS 服务器解析当前 DNS 规则下的所有域名
    * 保存
  * 保存并应用

结束！



更多细节，请参阅 [说明书](https://thisisian-w.github.io/2024/10/30/homeproxy-one-click-configure-scripts) 。
