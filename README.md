# AdGuardHome for Magisk
[English](README_en.md) | 简体中文

一个通过重定向并过滤 DNS 请求来屏蔽广告的 Magisk/KernelSU 模块

![Static Badge](https://img.shields.io/badge/arm--64-support-blue)
![Static Badge](https://img.shields.io/badge/arm--v7-support-blue)
![GitHub all releases](https://img.shields.io/github/downloads/twoone-3/AdguardHome/total)
[![](https://img.shields.io/badge/Telegram-Join%20Channel-blue?logo=telegram)](https://t.me/adguardhome_for_magisk_release)
[![](https://img.shields.io/badge/Telegram-Join%20Group-blue?logo=telegram)](https://t.me/+mdZL11mJjxhkYjdl)

关注我们的频道以获取最新消息，或者加入我们的群组进行讨论！

# 用法
- 使用前需在设置里关闭 `私人/专用dns`，在 Magisk/KernelSU 刷入后即可使用，本模块默认后台管理地址为 http://127.0.0.1:3000 ，默认用户名/密码root
- 如果你从来没有接触过 AdGuardHome，你可以在这里找到[官方文档](https://github.com/AdguardTeam/AdGuardHome)，或者也可以看看这篇教程[AdGuard Home 中文指南](https://www.timochan.cn/posts/jc/adguard_home_configuration_guide)

# 特性
- DNS 服务器选用腾讯和阿里的公共 DNS，你也可以在 AdGuardHome 的 DNS 设置里更改来满足你的需求
- 仅内置[秋风广告规则](https://github.com/TG-Twilight/AWAvenue-Ads-Rule)，精准，轻量，少误杀
- 在 Magisk/KernelSU 中可以通过模块开关实时启动/关闭模块
- 可修改位于 `/data/adb/agh/scripts/config.sh` 的配置文件来调整配置
- 覆盖安装时会自动给原模块创建备份

# FAQ
> Q: 为什么模块无法屏蔽某些广告?

> A: 模块通过转发 53 端口的 DNS 请求来实现广告屏蔽，因此无法屏蔽通过 HTTPS 传输的广告，以及与正常内容同域名的广告，如 知乎，Youtube 等

> Q: 为什么装上模块后访问页面变慢?

> A: 因为模块会将所有 DNS 请求转发到 AdGuardHome，再由 AdGuardHome 转发到上游的公共 DNS，中间多了一层转发，但模块默认开启了乐观缓存，在第二次访问时将大大减少延迟

> Q: 为什么本来可以访问的页面一段时间后出现了无法访问?

> A: 由于公共 DNS 请求较慢，模块默认配置文件里开启了乐观缓存，可能导致一些过时的 IP 在过期后仍然被使用，可在后台清理DNS缓存来缓解，或者关闭乐观缓存

> Q: 模块可以与其它代理模块/软件一起使用吗?

> A: 可以，一般的代理app可以直接兼容，且 AdGuardHome 的 DNS 查询会经过 VPN，其它代理模块看情况使用，可关闭自动 iptables 规则当作普通 DNS 使用


# 鸣谢
- [AdguardHome_magisk](https://github.com/410154425/AdGuardHome_magisk)
- [akashaProxy](https://github.com/ModuleList/akashaProxy)
- [box_for_magisk](https://github.com/taamarin/box_for_magisk)