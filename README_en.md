# AdGuardHome for Root

English | [简体中文](README.md)

A Magisk/KernelSU/APatch module to block ads by redirecting and filtering DNS requests. It can be used as a local ad-blocking module or transformed into a tool that runs AdGuardHome alone by adjusting the configuration file.

![arm-64 support](https://img.shields.io/badge/arm--64-support-ef476f?logo=linux&logoColor=white&color=ef476f)
![arm-v7 support](https://img.shields.io/badge/arm--v7-support-ffa500?logo=linux&logoColor=white&color=ffa500)
![GitHub downloads](https://img.shields.io/github/downloads/twoone-3/AdGuardHomeForRoot/total?logo=github&logoColor=white&color=ffd166)
![License](https://img.shields.io/badge/License-MIT-9b5de5?logo=opensourceinitiative&logoColor=white)
[![Join Telegram Channel](https://img.shields.io/badge/Telegram-Join%20Channel-06d6a0?logo=telegram&logoColor=white)](https://t.me/+Q3Ur_HCYdM0xM2I1)
[![Join Telegram Group](https://img.shields.io/badge/Telegram-Join%20Group-118ab2?logo=telegram&logoColor=white)](https://t.me/twoone3_tech_tips_group)

Follow our channel for the latest news, or join our group for discussion!

## Features

- Optionally forward local DNS requests to the local AdGuardHome server
- Filter ads using [AWAvenue-Ads-Rule](https://github.com/TG-Twilight/AWAvenue-Ads-Rule) for lightweight, power-saving, and fewer false positives
- Access the AdGuardHome control panel from <http://127.0.0.1:3000>, supporting query statistics, modifying DNS upstream servers, and custom rules, etc.

## Tutorial

1. Go to the [Release](https://github.com/twoone-3/AdGuardHomeForRoot/releases/latest) page to download the module
2. Check Android Settings -> Network & Internet -> Advanced -> Private DNS, ensure `Private DNS` is turned off
3. Install the module in the root manager and reboot the device
4. If you see a successful module running prompt, you can access <http://127.0.0.1:3000> to enter the AdGuardHome backend
5. For usage tutorials and FAQs, please visit [docs](/docs/index.md).

## Acknowledgments

- [AWAwenue Ads Rule](https://github.com/TG-Twilight/AWAvenue-Ads-Rule)
- [AdguardHome_magisk](https://github.com/410154425/AdGuardHome_magisk)
- [akashaProxy](https://github.com/ModuleList/akashaProxy)
- [box_for_magisk](https://github.com/taamarin/box_for_magisk)
