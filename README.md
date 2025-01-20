# homeproxy-autogen-configuration



An alternative way to generate your dedicated [homeproxy](https://github.com/immortalwrt/homeproxy) configuration and simplify the setup process significantly.

Steps:

* Customize your dedicated configurations via GitHub repository, Gist or some other available links by referring to the `rules.sh` script;
* Execute the given script on your ImmortalWrt/OpenWrt(23.05.x+) system:

```bash
bash "$(curl -kfsSl https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* You will be asked for the link of your exclusive `rules.sh` script during the execution.
* Done!

Please submit an issue for the purpose of soliciting feedback.

<br/>

<br/>

一个更方便地生成 ImmortalWrt/OpenWrt(23.05.x+) [homeproxy](https://github.com/immortalwrt/homeproxy) 插件大多数常用配置的脚本。

使用步骤：

* 通过 GitHub 仓库、Gist 或其它可被正常访问的链接定制你的专属 `rule.sh` 配置内容(可参考本仓库下的 `rules.sh` 脚本)；
* 执行以下命令：

```bash
bash "$(curl -kfsSl https://ghp.p3terx.com/https://raw.githubusercontent.com/thisIsIan-W/homeproxy-autogen-configuration/refs/heads/main/generate_homeproxy_rules.sh)"
```

* 脚本执行期间会要求你提供定制好的配置链接；
* 完成！

更多细节，请参阅 [说明书](https://thisisian-w.github.io/2024/10/30/homeproxy-one-click-configure-scripts) 。

任何问题，请直接提 issue！
