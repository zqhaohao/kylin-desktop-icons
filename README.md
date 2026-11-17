# Kylin Desktop Icons / 麒麟桌面系统图标管理

> 一键隐藏或恢复银河麒麟 V10 桌面上的「计算机 / 回收站 / 主文件夹」三个系统图标。
> One-click hide / restore of the three built-in desktop icons (Computer / Trash / Home) on Galaxy Kylin V10.

[中文](#中文说明) | [English](#english)

---

<a name="中文说明"></a>
## 中文说明

### 背景

麒麟 V10 桌面左上角的「计算机 / 回收站 / 主文件夹」三个图标（主文件夹图标的文字会显示为你自己的用户名，例如 `zqhaohao`），和 Windows 桌面的快捷方式不同：它们**不是** `.desktop` 文件，右键删不掉。它们是 UKUI 桌面（文件管理器 peony）直接渲染的**内置虚拟图标**，受 GSettings 开关控制；隐藏开关与用户名无关，任何用户名都能隐藏。

本工具把「隐藏 / 恢复」做成一键操作，并做成可双击的桌面图标，供有「桌面留白」偏好的用户使用。

### 实测环境与原理

| 项目 | 值 |
|---|---|
| 实测系统 | 银河麒麟桌面操作系统 V10 SP1（2503） |
| 架构 | aarch64（飞腾 D2000） |
| 桌面 | UKUI 3.x，`XDG_CURRENT_DESKTOP=UKUI` |
| 文件管理器 | peony（负责桌面图标渲染） |

**原理**：图标显隐由 `*-icon-visible` 键控制，涉及两套 schema：

- `org.ukui.peony.settings` —— `computer-icon-visible` / `home-icon-visible` / `trash-icon-visible`（**真正生效的开关**）
- `org.ukui.control-center.desktop` —— 同名键（部分版本/控制中心读取；部分键带 `*-icon-locking=true` 只读锁定，写入会被拒）

脚本对两套都尝试写入，写后校验，被系统锁定的键自动跳过，不影响结果。写入经 D-Bus 会话总线广播变更信号，**即时生效，无需注销或重启**。

### 适用范围（务必阅读）

| 系统 / 桌面 | 支持情况 |
|---|---|
| 银河麒麟桌面 V10 全系（SP1 2203 / SP2 / 2503 等，UKUI 桌面） | ✅ 支持，机制一致（peony 图标） |
| openKylin（开放麒麟，同为 UKUI + peony） | ✅ 大概率支持，欢迎反馈 |
| 银河麒麟服务器版（无桌面 / GNOME） | ❌ 不适用，脚本会检测并提示 |
| 其他桌面（DDE / GNOME / KDE） | ❌ 未支持，欢迎提 issue 贡献 schema |

关于可移植性的诚实说明：银河麒麟**桌面版** V10 各服务包均基于 UKUI 桌面，peony 始终负责桌面图标，因此机制在各版本一致。但不同版本的 schema 键名/锁定策略可能有差异，脚本已做「双 schema + 写后校验 + 自动探测」，最大程度兼容。**作者无法逐一实机验证所有版本**，欢迎按下文格式反馈。

### 用法

**方式一：桌面图标（推荐）**

```bash
bash install-desktop.sh
```

安装后桌面出现三个双击图标：`隐藏桌面系统图标`、`恢复桌面系统图标`、`桌面图标状态`。卸载：`bash install-desktop.sh remove`（只删图标，不改显隐状态）。

**方式二：命令行**

```bash
bash hide-desktop-icons.sh hide      # 隐藏三个图标
bash hide-desktop-icons.sh restore   # 恢复显示
bash hide-desktop-icons.sh status    # 查看当前状态
bash hide-desktop-icons.sh check     # 环境自检（排查不生效原因）
```

### 常见问题

**Q：双击后提示"未生效"？**
先运行 `bash hide-desktop-icons.sh check`。最常见原因是**用 root / sudo 运行**：gsettings 写入必须用它所属用户（桌面登录用户）的凭证，root 去连用户会话总线会因 D-Bus EXTERNAL 认证失败而写入无效。请直接双击图标，或在**自己的终端**里运行，**不要加 sudo**。

**Q：图标隐藏了，文件还能访问吗？**
完全可以。隐藏只是不显示桌面图标；从固定到任务栏的文件管理器里，回收站、主文件夹、计算机都能正常打开。

**Q：出现 KYSEC / 执行控制提示？**
麒麟的安全机制可能拦截外来脚本首次运行，选择「允许 / 信任 / 放行」即可（这是正常的安全提示，不是脚本问题）。

**Q：影响我自己的快捷方式吗？**
不影响。桌面上的 `.desktop` 快捷方式（你自己放的应用）照常显示，本工具只改那三个内置系统图标。

### 回滚 / 卸载

- 恢复三个图标：`bash hide-desktop-icons.sh restore` 或双击「恢复桌面系统图标」。
- 移除桌面图标：`bash install-desktop.sh remove`。
- 完全还原到未安装状态：执行上面两项即可，本工具不改动系统文件。

### 赞助

<a name="赞助"></a>

如果这个工具帮你省了事，欢迎随手支持一下，帮我继续更新和维护更多麒麟桌面工具。仓库右上角的 **Sponsor** 按钮会跳到这里。

赞助完全自愿，**不设固定金额**——一杯柠檬水、一包烟的钱就好，量力而行，一点心意就足够。

| 支付宝 | 微信 |
|:---:|:---:|
| <img src="assets/sponsors/alipay-placeholder.png" width="220" alt="支付宝收款码"> | <img src="assets/sponsors/wechat-placeholder.png" width="220" alt="微信收款码"> |

> 收款码是作者本人的支付宝 / 微信个人码，扫码后自行填写任意金额即可。没有最低门槛，力所能及就好。

### 反馈与贡献

欢迎反馈你的机型/版本与 `check` 输出，帮助完善适配：

```
系统版本：
架构：
桌面环境（XDG_CURRENT_DESKTOP）：
check 输出：
```

### 免责声明

本工具仅修改当前用户的 GSettings 显隐开关，不卸载软件、不改系统文件、不需要 root。使用前建议先运行 `check`。作者不对因环境差异导致的异常承担责任，欢迎 issue 反馈共同完善。

---

<a name="english"></a>
## English

### Background

The three icons at the top-left of the Kylin V10 desktop — Computer / Trash / Home — are **not** `.desktop` shortcuts like on Windows. They cannot be deleted by right-click. They are built-in virtual icons rendered directly by the UKUI desktop (the `peony` file manager) and controlled by GSettings keys.

This tool makes hiding/restoring them a one-click action, available as double-clickable desktop icons for users who prefer a clean desktop.

### Tested environment & principle

| Item | Value |
|---|---|
| Tested OS | Galaxy Kylin Desktop V10 SP1 (2503) |
| Architecture | aarch64 (Phytium D2000) |
| Desktop | UKUI 3.x, `XDG_CURRENT_DESKTOP=UKUI` |
| File manager | peony (renders desktop icons) |

**Principle**: icon visibility is controlled by `*-icon-visible` keys across two schemas:

- `org.ukui.peony.settings` — `computer-icon-visible` / `home-icon-visible` / `trash-icon-visible` (the **effective** switch)
- `org.ukui.control-center.desktop` — same-named keys (read by some versions/control center; some are read-only via `*-icon-locking=true`, where writes are rejected)

The script writes to both, verifies each write, and skips keys locked by the system. Changes are broadcast over the D-Bus session bus and take effect **immediately — no logout or reboot needed**.

### Compatibility (please read)

| System / Desktop | Support |
|---|---|
| Galaxy Kylin Desktop V10 (SP1 2203 / SP2 / 2503, UKUI) | ✅ Supported, same mechanism (peony icons) |
| openKylin (also UKUI + peony) | ✅ Likely supported, feedback welcome |
| Galaxy Kylin Server (no GUI / GNOME) | ❌ Not applicable, script detects and reports |
| Other desktops (DDE / GNOME / KDE) | ❌ Unsupported; issue/PR welcome |

Honest note on portability: Galaxy Kylin **Desktop** V10 editions are all based on the UKUI desktop, and peony always renders desktop icons, so the mechanism is consistent across versions. However key names and locking policies may differ between releases. The script uses dual-schema writes + post-write verification + auto-detection for maximum compatibility. The author cannot verify every version on real hardware — feedback is welcome (see below).

### Usage

**Option 1: desktop icons (recommended)**

```bash
bash install-desktop.sh
```

This adds three double-click icons: `隐藏桌面系统图标` (hide), `恢复桌面系统图标` (restore), `桌面图标状态` (status). Remove with `bash install-desktop.sh remove` (icons only, visibility unchanged).

**Option 2: command line**

```bash
bash hide-desktop-icons.sh hide      # hide the three icons
bash hide-desktop-icons.sh restore   # restore them
bash hide-desktop-icons.sh status    # show current state
bash hide-desktop-icons.sh check     # environment self-check
```

### FAQ

**Q: Shows "not applied" after double-click?**
Run `bash hide-desktop-icons.sh check`. The most common cause is running as **root / via sudo**: gsettings writes require the credentials of the desktop login user; root connecting to the user session bus fails D-Bus EXTERNAL authentication. Double-click the icon, or run in **your own terminal** — do **not** use sudo.

**Q: After hiding, can I still access the files?**
Yes. Hiding only removes the desktop icons; Trash / Home / Computer remain accessible from the file manager pinned to your taskbar.

**Q: KYSEC / execution-control prompt?**
Kylin's security mechanism may block a foreign script on first run. Choose "Allow / Trust" — this is a normal security prompt, not a script problem.

**Q: Does it affect my own shortcuts?**
No. Your own `.desktop` shortcuts on the desktop stay visible; this tool only touches the three built-in system icons.

### Rollback / uninstall

- Restore icons: `bash hide-desktop-icons.sh restore` or double-click the restore icon.
- Remove desktop icons: `bash install-desktop.sh remove`.
- Full cleanup: do both above — the tool never modifies system files.

### Sponsor

If this tool saved you time, feel free to show your support and help me keep updating and maintaining more Kylin desktop tools. The **Sponsor** button on the repository page leads here.

Sponsorship is entirely optional with **no fixed amount** — the price of a lemonade or a pack of cigarettes is plenty. Give what you can; every little bit of goodwill counts.

| Alipay | WeChat Pay |
|:---:|:---:|
| <img src="assets/sponsors/alipay-placeholder.png" width="220" alt="Alipay QR code"> | <img src="assets/sponsors/wechat-placeholder.png" width="220" alt="WeChat Pay QR code"> |

> These are the author's personal Alipay / WeChat Pay QR codes. Scan and enter any amount you like — there is no minimum, just give what feels right.

### Feedback & contribution

Feedback on your model/version and `check` output is welcome:

```
OS version:
Architecture:
Desktop (XDG_CURRENT_DESKTOP):
check output:
```

### Disclaimer

This tool only changes the current user's GSettings visibility keys. It does not remove software, modify system files, or require root. Run `check` before use. The author is not liable for issues from environment differences; issues are welcome.

### License

MIT
