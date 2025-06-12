# Tutorials

## 安装

本模块仅适用于已经 root 的安卓设备，支持 [Magisk](https://github.com/topjohnwu/Magisk) / [KernelSU](https://github.com/tiann/KernelSU) / [APatch](https://github.com/bmax121/APatch) 等 root 工具

目前来说，KernelSU 是最适配的 root 工具，因为隐藏性好，兼容性强，且作者也在使用

在 Release 页面下载 zip 文件，提供了 arm64 和 armv7 两个版本。一般推荐使用 arm64 版，因为它在性能上更优，并且与大多数现代设备兼容。

---

## 配置

模块默认的 AdGuardHome 后台地址为 `http://127.0.0.1:3000`，可以通过浏览器直接访问，默认账号和密码均为 `root`。

在 AdGuardHome 后台，你可以执行以下操作：

- 查看 DNS 查询统计信息
- 修改各种 DNS 配置
- 查看日志
- 添加自定义规则

如果你更倾向于使用移动设备管理模块，可以尝试使用 [AdGuard Home Manager](https://github.com/JGeek00/adguard-home-manager) 应用。

---

## 模块控制

模块的状态会实时显示在`module.prop`文件中，在root管理器中可以看到模块的状态信息（如果没刷新请手动刷新）

模块实时监测`/data/adb/modules/AdGuardHome`目录下的`disable`文件，如果存在则禁用模块，不存在则启用模块

如果你想用其他方法来启停，你可以在文件管理器中手动创建和删除文件，也可以使用shell命令

```shell
touch /data/adb/modules/AdGuardHome/disable
```

```shell
rm /data/adb/modules/AdGuardHome/disable
```

实际上本模块可以分为两部分，一部分是 AdGuardHome 本身，它在本地搭建了一个可自定义拦截功能的 DNS 服务器，另一部分是 iptables 转发规则，它负责将本机所有53端口出口流量重定向到 AdGuardHome

---

## 与代理软件共存

代理软件主要分为两类：

**代理应用**：如 [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid)、[FlClash](https://github.com/chen08209/FlClash) 等。这些应用通常具有图形化界面，便于用户配置和管理代理规则。

以下是我自用的 FlClash 配置文件示例：

```yaml
dns:
  enable: true
  listen: :1053
  ipv6: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*'
    - '+.lan'
    - '+.local'
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - 'https://1.1.1.1/dns-query'
    - 'https://8.8.8.8/dns-query'
  proxy-server-nameserver:
    - "https://223.5.5.5/dns-query"
    - "https://1.12.12.12/dns-query"
  nameserver-policy:
    "geosite:cn,private":
      - "https://223.5.5.5/dns-query"
      - "https://1.12.12.12/dns-query"

proxy-providers:
  provider1:
    type: http
    url: ""
    interval: 86400
    # proxy: PROXY

  provider2:
    type: http
    url: ""
    interval: 86400
    # proxy: DIRECT

proxy-groups:
  - name: PROXY
    type: select
    include-all: true

rules:
  # direct FCM
  - AND,((NETWORK,TCP),(DST-PORT,5228-5230),(OR,((DOMAIN-KEYWORD,google)))),DIRECT

  # direct ntp
  - AND,((NETWORK,UDP),(DST-PORT,123)),DIRECT

  # geosite rules
  - GEOSITE,private,DIRECT
  - GEOSITE,telegram,PROXY
  - GEOSITE,youtube,PROXY
  - GEOSITE,google,PROXY
  - GEOSITE,twitter,PROXY
  - GEOSITE,pixiv,PROXY
  - GEOSITE,category-scholar-!cn,PROXY
  - GEOSITE,bilibili,DIRECT
  - GEOSITE,onedrive,DIRECT
  - GEOSITE,microsoft@cn,DIRECT
  - GEOSITE,apple-cn,DIRECT
  - GEOSITE,steam@cn,DIRECT
  - GEOSITE,category-games@cn,DIRECT
  - GEOSITE,geolocation-!cn,PROXY
  - GEOSITE,cn,DIRECT

  # geoip rules
  - GEOIP,private,DIRECT,no-resolve
  - GEOIP,telegram,PROXY
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
```

**代理模块**：如 [box_for_magisk](https://github.com/taamarin/box_for_magisk)、[akashaProxy](https://github.com/akashaProxy/akashaProxy) 等。这些模块通常运行在系统层级，适合需要更高权限或更深度集成的场景。

代理应用的 `分应用代理/访问控制` 功能非常实用。通过将国内应用设置为绕过模式，可以减少不必要的流量经过代理，同时这些绕过的应用仍然能够正常屏蔽广告。

如果使用代理模块，强烈建议禁用模块的 iptables 转发规则。禁用后，模块仅运行 AdGuardHome 本身。随后，将代理模块的上游 DNS 服务器配置为 `127.0.0.1:5591`，即可确保代理软件的所有 DNS 查询通过 AdGuardHome 进行广告屏蔽。

```yaml
dns:
  # existing code...
  default-nameserver:
    - 223.5.5.5
  nameserver:
    - 127.0.0.1:5591
  # existing code...
```

---

## 模块目录与配置文件

模块的文件结构主要分为以下两个目录：

- **`/data/adb/agh`**：包含 AdGuardHome 的核心文件，包括二进制文件、工具脚本和配置文件。
- **`/data/adb/modules/AdGuardHome`**：存储模块的启动脚本和运行时数据文件。

模块的配置文件也分为两部分：

- **`/data/adb/agh/bin/AdGuardHome.yaml`**：AdGuardHome 的主配置文件。
- **`/data/adb/agh/settings.conf`**：模块的配置文件，具体说明请参考文件内的注释。

在更新模块时，用户可以选择是否保留原有的配置文件。如果选择不保留，系统会自动将原配置文件备份到 **`/data/adb/agh/backup`** 目录，以确保数据安全。

---

## 模块打包

模块根目录下提供了一个名为 `pack.ps1` 的打包脚本，用户可以通过它快速生成模块的安装包。

在 Windows 系统上，打开 PowerShell 并执行以下命令：

```powershell
.\pack.ps1
```

运行脚本后，以下操作将自动完成：

1. 创建 `cache` 目录（如果尚未存在）。
2. 下载并缓存最新版本的 AdGuardHome（仅在 `cache` 目录中未找到缓存时执行下载）。
3. 将 AdGuardHome 与模块的其他文件打包成一个 ZIP 文件。

该脚本的设计确保了高效性：如果 `cache` 目录中已存在 AdGuardHome 的缓存版本，则无需重复下载，从而节省时间和带宽。

## 常见问题

### **Q: 模块安装后无法正常运行怎么办？**  

**A:**  

- 检查 AdGuardHome 是否在运行：  
  使用以下命令查看进程状态：  

  ```shell
  ps | grep AdGuardHome
  ```

- 确保设备的 **私人 DNS** 功能已关闭：  
  前往 **设置 -> 网络和互联网 -> 高级 -> 私人 DNS**，并将其设置为关闭。

### **Q: 如何更改 AdGuardHome 的默认端口？**  

**A:**  

- 打开 **`/data/adb/agh/bin/AdGuardHome.yaml`** 文件。  
- 修改 `bind_host` 的端口号为所需值。  
- 保存文件后，重启模块以应用更改。

### **Q: 如何禁用模块的 iptables 转发规则？**  

**A:**  

- 编辑 **`/data/adb/agh/settings.conf`** 文件。  
- 将 `ENABLE_IPTABLES` 参数设置为 `false`。  
- 保存文件后，重启模块。

### **Q: 使用代理模块时，广告屏蔽无效怎么办？**  

**A:**  

- 确保代理模块的上游 DNS 服务器配置为 **`127.0.0.1:5591`**。  
- 检查代理模块的配置文件，确保所有 DNS 查询通过 AdGuardHome。

### **Q: 模块是否会影响设备性能？**  

**A:**  

- 模块对性能的影响较小，但在低性能设备上可能会有轻微延迟。  
- 推荐使用 **arm64** 版本以获得更好的性能。

### **Q：使用模块后，无法访问 Google 怎么办？**

**A:**

- 如果你用的是 FlClash，可以尝试以下配置：

```ini
ignore_src_list="172.19.0.1"
```
