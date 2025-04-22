# Tutorials

## 介绍

本模块是一个在安卓设备上运行的 AdGuardHome 模块，提供了一个本地 DNS 服务器，能够屏蔽广告、恶意软件和跟踪器。

它可以与其他代理软件（如 NekoBox、FlClash、box for magisk 等）共存，提供更好的隐私保护和网络安全。

## 简易教程

前往 [Release](https://github.com/twoone-3/AdGuardHomeForRoot/releases/latest) 页面下载模块

检查 Android 设置 -> 网络和互联网 -> 高级 -> 私人 DNS，确保 `私人 DNS` 关闭

在 root 管理器中安装模块，重启设备

## 高级教程

### 安装

本模块仅适用于已经 root 的安卓设备，支持 [Magisk](https://github.com/topjohnwu/Magisk) / [KernelSU](https://github.com/tiann/KernelSU) / [APatch](https://github.com/bmax121/APatch) 等 root 工具

目前来说，KernelSU 是最适配的 root 工具，因为隐藏性好，兼容性强，且作者也在使用

在 Release 页面下载 zip 文件，提供了 arm64 和 armv7 两个版本。一般推荐使用 arm64 版，因为它在性能上更优，并且与大多数现代设备兼容。

---

### 配置

模块默认的 AdGuardHome 后台地址为 `http://127.0.0.1:3000`，可以通过浏览器直接访问，默认账号和密码均为 `root`。

在 AdGuardHome 后台，你可以执行以下操作：

- 查看 DNS 查询统计信息
- 修改各种 DNS 配置
- 查看日志
- 添加自定义规则

如果你更倾向于使用移动设备管理模块，可以尝试使用 [AdGuard Home Manager](https://github.com/JGeek00/adguard-home-manager) 应用。

---

### 模块控制

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

### 与代理软件共存

代理软件主要分为两类：

1. **代理应用**：如 [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid)、[FlClash](https://github.com/chen08209/FlClash) 等。这些应用通常具有图形化界面，便于用户配置和管理代理规则。

2. **代理模块**：如 [box for magisk](https://github.com/taamarin/box_for_magisk)。这些模块通常运行在系统层级，适合需要更高权限或更深度集成的场景。

代理应用的 `分应用代理/访问控制` 功能非常实用。通过将国内应用设置为绕过模式，可以减少不必要的流量经过代理，同时这些绕过的应用仍然能够正常屏蔽广告。

如果使用代理模块，强烈建议禁用模块的 iptables 转发规则。禁用后，模块仅运行 AdGuardHome 本身。随后，将代理模块的上游 DNS 服务器配置为 `127.0.0.1:5591`，即可确保代理软件的所有 DNS 查询通过 AdGuardHome 进行广告屏蔽。

以下是 Mihomo 的配置示例：

```yaml
dns:
  enable: true
  ipv6: true

  default-nameserver:
    - 127.0.0.1:5591

  listen: 0.0.0.0:1053
  use-hosts: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*.lan'

  nameserver:
    - 127.0.0.1:5591
```

---

### 模块目录与配置文件

模块的文件结构主要分为以下两个目录：

- **`/data/adb/agh`**：包含 AdGuardHome 的核心文件，包括二进制文件、工具脚本和配置文件。
- **`/data/adb/modules/AdGuardHome`**：存储模块的启动脚本和运行时数据文件。

模块的配置文件也分为两部分：

- **`/data/adb/agh/bin/AdGuardHome.yaml`**：AdGuardHome 的主配置文件。
- **`/data/adb/agh/script/config.sh`**：模块的配置文件，具体说明请参考文件内的注释。

在更新模块时，用户可以选择是否保留原有的配置文件。如果选择不保留，系统会自动将原配置文件备份到 **`/data/adb/agh/backup`** 目录，以确保数据安全。

---

### 模块打包

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

### 常见问题

#### **Q: 模块安装后无法正常运行怎么办？**  

**A:**  

- 检查 AdGuardHome 是否在运行：  
  使用以下命令查看进程状态：  

  ```shell
  ps | grep AdGuardHome
  ```

- 确保设备的 **私人 DNS** 功能已关闭：  
  前往 **设置 -> 网络和互联网 -> 高级 -> 私人 DNS**，并将其设置为关闭。

#### **Q: 如何更改 AdGuardHome 的默认端口？**  

**A:**  

- 打开 **`/data/adb/agh/bin/AdGuardHome.yaml`** 文件。  
- 修改 `bind_host` 的端口号为所需值。  
- 保存文件后，重启模块以应用更改。

#### **Q: 如何禁用模块的 iptables 转发规则？**  

**A:**  

- 编辑 **`/data/adb/agh/script/config.sh`** 文件。  
- 将 `ENABLE_IPTABLES` 参数设置为 `false`。  
- 保存文件后，重启模块。

#### **Q: 使用代理模块时，广告屏蔽无效怎么办？**  

**A:**  

- 确保代理模块的上游 DNS 服务器配置为 **`127.0.0.1:5591`**。  
- 检查代理模块的配置文件，确保所有 DNS 查询通过 AdGuardHome。

#### **Q: 模块是否会影响设备性能？**  

**A:**  

- 模块对性能的影响较小，但在低性能设备上可能会有轻微延迟。  
- 推荐使用 **arm64** 版本以获得更好的性能。

---
