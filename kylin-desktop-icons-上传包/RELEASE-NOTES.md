## v1.0.0 麒麟桌面系统图标管理 / Kylin Desktop Icons v1.0.0

**中文**

首个版本发布。一键隐藏 / 恢复银河麒麟 V10 桌面上的「计算机 / 回收站 / 主文件夹」三个内置系统图标（这些图标不是快捷方式、右键删不掉，但可隐藏）。

特性：
- 支持 `hide` / `restore` / `status` / `check` 四个子命令
- 自动探测并同时写入 `org.ukui.peony.settings` 与 `org.ukui.control-center.desktop` 两套 schema，写后校验、锁定键自动跳过
- 经 D-Bus 广播变更，即时生效，无需注销/重启
- 附带桌面双击图标安装器（`install-desktop.sh`），可一键安装/卸载
- 身份/D-Bus 环境自检，root 误用会明确提示

实测：银河麒麟桌面 V10 SP1（2503）/ aarch64 / UKUI 3.x / peony。

使用：解压后运行 `bash install-desktop.sh` 安装桌面图标，或 `bash hide-desktop-icons.sh hide` 直接隐藏。详见 README。

---

**English**

First release. One-click hide/restore of the three built-in desktop icons (Computer / Trash / Home) on Galaxy Kylin V10 — these are not shortcuts and cannot be deleted via right-click, but they can be hidden.

Features:
- Four subcommands: `hide` / `restore` / `status` / `check`
- Auto-detects and writes to both `org.ukui.peony.settings` and `org.ukui.control-center.desktop`, with post-write verification and automatic skip of locked keys
- Changes broadcast over D-Bus — effective immediately, no logout/reboot needed
- Includes a desktop icon installer (`install-desktop.sh`) for one-click install/remove
- Identity/D-Bus self-check with clear warning on root misuse

Tested on: Galaxy Kylin Desktop V10 SP1 (2503) / aarch64 / UKUI 3.x / peony.

Usage: run `bash install-desktop.sh` to install desktop icons, or `bash hide-desktop-icons.sh hide` directly. See README for details.
