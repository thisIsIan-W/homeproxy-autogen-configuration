# homeproxy-autogen-configuration

## English

An alternative way to generate your dedicated [homeproxy](https://github.com/immortalwrt/homeproxy) configuration and simplify the major setup process significantly.

### Introduction

* Save substantial time for repetitive chores in configuration;
* Provide an alternative solution to solve the potential issues that homeproxy cannot start or be used normally due to incorrect operations and other reasons.



### Steps

* (Required) Customize your dedicated [rules.sh](https://gist.github.com/thisIsIan-W/3d4343c6e61e49f4c5ae6aa9115045bf) configuration by using Secret Gist or other private links;
* Execute the given script on your ImmortalWrt/OpenWrt(23.05.x+) system (You will be asked for the URL of your dedicated 'rules.sh' script during the execution):

```bash
bash -c "$(curl -kfsSl https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* Done!

Please submit an issue for the purpose of soliciting feedback.

<br/>

<br/>

---

## 中文

一个更方便地生成 ImmortalWrt/OpenWrt(23.05.x+) [homeproxy](https://github.com/immortalwrt/homeproxy) 插件大多数常用配置的脚本。

### 简介

* 节省大量重复配置所需的时间；
* 提供替代方案，解决由于潜在的配置不当等原因导致 homeproxy 无法启动或正常使用的问题。



### 使用步骤

* (必备) 通过私密 Gist 或其它可被正常访问的私有链接定制你的专属 [rules.sh](https://gist.github.com/thisIsIan-W/3d4343c6e61e49f4c5ae6aa9115045bf) 配置内容；
* 执行以下命令（脚本执行期间会向你索要你的定制配置URL）：

```bash
bash -c "$(curl -kfsSl https://ghp.p3terx.com/https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* 脚本执行期间会要求你提供定制好的配置链接；
* 完成！

更多细节，请参阅 [说明书](https://thisisian-w.github.io/2024/10/30/homeproxy-one-click-configure-scripts) 。

任何问题，请直接提 issue！
