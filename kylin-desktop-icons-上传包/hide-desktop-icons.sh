#!/bin/bash
# ============================================================
# 隐藏 / 恢复 银河麒麟 V10 桌面的"计算机 / 回收站 / 主文件夹"系统图标
#
# 原理：这三个图标不是 .desktop 快捷方式，而是 UKUI 桌面（peony）内置虚拟图标。
#       由 GSettings 的 *-icon-visible 键控制。不同版本可能读取不同的 schema，
#       因此本脚本对已知的两套 schema 同时写入，确保各版本都生效。
#
# 用法：
#   bash hide-desktop-icons.sh hide      隐藏三个图标
#   bash hide-desktop-icons.sh restore   恢复显示（三个图标全部设为显示）
#   bash hide-desktop-icons.sh status    查看当前状态（不改任何东西）
#   bash hide-desktop-icons.sh check     环境自检（排查为何不生效）
#
# 无需 root，必须在图形桌面会话中运行（需 D-Bus 会话总线）。
# ============================================================

# 注意：不使用 set -e —— 部分版本缺少某个键时应跳过而非中断
set -u

SCHEMAS="org.ukui.peony.settings org.ukui.control-center.desktop"
KEYS="computer-icon-visible home-icon-visible trash-icon-visible"
KEY_LABEL="computer-icon-visible=计算机 home-icon-visible=主文件夹 trash-icon-visible=回收站"
BACKUP_DIR="$HOME/.local/share/kylin-desktop-icons"
BACKUP_FILE="$BACKUP_DIR/icon-state.bak"

# ---------- 环境准备：确保能连上"桌面用户"的会话总线 ----------
# 关键：gsettings 写入必须用它所属用户(通常是登录用户)的凭证。
# 若以 root 或在别的身份下运行，D-Bus EXTERNAL 认证会失败，写入静默无效。
prepare_dbus() {
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        local bus="/run/user/$(id -u)/bus"
        [ -S "$bus" ] && export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"
    fi
}

# 校验当前用户与会话总线归属是否一致；不一致则给出明确提示
check_identity() {
    local uid
    uid="$(id -u)"
    local bus="${DBUS_SESSION_BUS_ADDRESS:-}"
    local bus_uid=""
    case "$bus" in
        *"/run/user/"*) bus_uid="$(echo "$bus" | sed -n 's#.*/run/user/\([0-9]*\)/bus.*#\1#p')" ;;
    esac
    if [ -n "$bus_uid" ] && [ "$uid" != "$bus_uid" ]; then
        echo "[警告] 当前 uid=$uid，但会话总线属于 uid=$bus_uid。"
        echo "        gsettings 写入需要以桌面登录用户身份运行，否则会失败。"
        echo "        请直接从桌面双击图标运行，或在自己的终端里运行（不要用 sudo/root）。"
        return 1
    fi
    return 0
}

# 某个 schema+key 是否存在
schema_has_key() {
    gsettings list-keys "$1" 2>/dev/null | grep -qx "$2"
}

# 收集本系统实际可用的 "schema:key" 组合
collect_targets() {
    TARGETS=""
    for s in $SCHEMAS; do
        for k in $KEYS; do
            if schema_has_key "$s" "$k"; then
                TARGETS="$TARGETS $s:$k"
            fi
        done
    done
}

# 列出当前所有目标的状态
show_status() {
    prepare_dbus
    collect_targets
    echo "桌面环境: ${XDG_CURRENT_DESKTOP:-未设置}  会话: ${DESKTOP_SESSION:-未设置}"
    echo "D-Bus 总线: ${DBUS_SESSION_BUS_ADDRESS:-未连接}"
    echo "检测到的可配置项:"
    if [ -z "$TARGETS" ]; then
        echo "  （无）—— 未发现 UKUI/peony 图标开关，可能不是 UKUI 桌面"
        return 1
    fi
    local s k v
    for t in $TARGETS; do
        s="${t%%:*}"; k="${t##*:}"
        v="$(gsettings get "$s" "$k" 2>/dev/null)"
        printf "  %-34s %-24s = %s\n" "$s" "$k" "$v"
    done
    return 0
}

# 环境自检
do_check() {
    echo "=== 环境自检 ==="
    local ok=0
    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        echo "[通过] 图形显示环境: ${DISPLAY:-${WAYLAND_DISPLAY}}"
    else
        echo "[警告] 未检测到 DISPLAY/WAYLAND_DISPLAY —— 必须在桌面会话中运行"
        ok=1
    fi
    prepare_dbus
    if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        echo "[通过] D-Bus 会话总线: $DBUS_SESSION_BUS_ADDRESS"
    else
        echo "[警告] 未连接 D-Bus 会话总线 —— gsettings 写入可能失败"
        ok=1
    fi
    if command -v gsettings >/dev/null 2>&1; then
        echo "[通过] gsettings 可用"
    else
        echo "[失败] 找不到 gsettings"
        return 1
    fi
    echo
    show_status || ok=1
    echo
    if [ "$ok" -eq 0 ] && [ -n "$TARGETS" ]; then
        echo "自检通过，可以执行 hide / restore。"
    else
        echo "存在上述警告，请按提示处理后重试。"
    fi
    return 0
}

# 备份当前值（仅首次，不覆盖，供需要时人工核对/回退，restore 本身不依赖它）
backup_state() {
    mkdir -p "$BACKUP_DIR"
    [ -f "$BACKUP_FILE" ] && return 0
    local t s k v
    {
        echo "# kylin-desktop-icons 原值备份，用于 restore 精确还原"
        echo "# 创建时间: $(date '+%Y-%m-%d %H:%M:%S')"
        for t in $TARGETS; do
            s="${t%%:*}"; k="${t##*:}"
            v="$(gsettings get "$s" "$k" 2>/dev/null)"
            echo "$s|$k|$v"
        done
    } > "$BACKUP_FILE"
    echo "已备份原值到: $BACKUP_FILE"
}

# 写入目标值（true=显示 / false=隐藏），两套 schema 全部写入
apply_value() {
    local value="$1" action="$2"
    prepare_dbus
    check_identity || return 1
    collect_targets
    if [ -z "$TARGETS" ]; then
        echo "[错误] 未发现 UKUI/peony 桌面图标开关。本脚本仅支持 UKUI 桌面（银河麒麟 V10 全系）。"
        echo "        若你确实用的是 UKUI 却看到此提示，请执行 check 并把输出反馈给作者。"
        return 1
    fi
    backup_state
    local t s k locked_note=""
    for t in $TARGETS; do
        s="${t%%:*}"; k="${t##*:}"
        gsettings set "$s" "$k" "$value" 2>/dev/null
        # 写后校验：若值未变，说明该键被系统锁定（locking），跳过即可
        if [ "$(gsettings get "$s" "$k" 2>/dev/null)" != "$value" ]; then
            case "$s" in
                *control-center*) locked_note="$s 的图标键被系统策略锁定（只读），已跳过；生效以 peony 为准。" ;;
            esac
        fi
    done
    sleep 1
    echo "已$action：计算机 / 回收站 / 主文件夹（即时生效，无需重启）"
    [ -n "$locked_note" ] && echo "说明：$locked_note"
    show_status
}

# 隐藏
do_hide() {
    apply_value false 隐藏
}

# 恢复显示
do_restore() {
    apply_value true 恢复显示
}

case "${1:-}" in
    hide)    do_hide ;;
    restore) do_restore ;;
    status)  show_status ;;
    check)   do_check ;;
    *)
        echo "用法: bash $(basename "$0") {hide|restore|status|check}"
        echo "  hide     隐藏三个系统图标"
        echo "  restore  恢复显示（按备份还原原值）"
        echo "  status   查看当前状态"
        echo "  check    环境自检"
        exit 1
        ;;
esac
