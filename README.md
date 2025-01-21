# homeproxy-autogen-configuration

## English

An alternative way to generate your dedicated [homeproxy](https://github.com/immortalwrt/homeproxy) configuration and simplify the major setup process significantly.

### Introduction

* Save substantial time for repetitive chores in configuration;
* Provide an alternative solution to solve the potential issues that homeproxy cannot start or be used normally due to incorrect operations and other reasons.



### Steps

Prepare the runtime environment necessary for the script execution via (Skip this step if it has already been prepared):

```bash
opkg update
opkg install bash jq curl
```

, then:

* (Required) Customize your dedicated [rules.sh](https://gist.github.com/thisIsIan-W/2c582a751e56c1a3f36d9ce48e312b31) configuration by using Secret Gist or other private links;
* Execute the given script on your ImmortalWrt/OpenWrt(23.05.x+) system (You will be asked for the URL of your dedicated 'rules.sh' script during the execution):

```bash
bash -c "$(curl -kfsSl https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* Done!

<br/>

<br/>

---

<br/>

## 中文

一个更方便地生成 ImmortalWrt/OpenWrt(23.05.x+) [homeproxy](https://github.com/immortalwrt/homeproxy) 插件大多数常用配置的脚本。

### 简介

* 节省大量重复配置所需的时间；
* 提供替代方案，解决由于潜在的配置不当等原因导致 homeproxy 无法启动或正常使用的问题。



### 使用步骤

准备脚本运行时所需环境（如已准备，则跳过此步）：

```bash
opkg update
opkg install bash jq curl
```

，然后：

* (必备) 通过私密 Gist 或其它可被正常访问的私有链接定制你的专属 [rules.sh](https://gist.github.com/thisIsIan-W/2c582a751e56c1a3f36d9ce48e312b31) 配置内容；
* 执行以下命令（脚本执行期间会向你索要你的定制配置URL）：

```bash
bash -c "$(curl -kfsSl https://ghp.p3terx.com/https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* 完成！

更多细节，请参阅 [说明书](https://thisisian-w.github.io/2024/10/30/homeproxy-one-click-configure-scripts) 。
