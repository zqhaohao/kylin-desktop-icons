#!/bin/bash
# ============================================================
# 桌面图标安装器（普通用户运行，无需 root）
# 为 hide-desktop-icons.sh 创建桌面双击图标：
#   "隐藏桌面系统图标" / "恢复桌面系统图标" / "桌面图标状态"
#
#   bash install-desktop.sh          安装
#   bash install-desktop.sh remove   卸载（移除图标，不改动已设置的显隐状态）
# ============================================================
set -u

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/opt/kylin-desktop-icons"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# 桌面目录探测，并做安全防线：必须在当前用户家目录内
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
[ -z "$DESKTOP_DIR" ] && DESKTOP_DIR="$HOME/桌面"
case "$DESKTOP_DIR" in
    "$HOME"|"$HOME"/*) ;;
    *) DESKTOP_DIR="$HOME/桌面" ;;
esac
mkdir -p "$DESKTOP_DIR"

[ -f "$REPO_DIR/hide-desktop-icons.sh" ] || { echo "[错误] 请在仓库目录内运行本脚本"; exit 1; }

do_remove() {
    rm -f "$APP_DIR/kdi-hide.desktop" "$APP_DIR/kdi-restore.desktop" "$APP_DIR/kdi-status.desktop"
    rm -f "$DESKTOP_DIR/隐藏桌面系统图标.desktop" "$DESKTOP_DIR/恢复桌面系统图标.desktop" "$DESKTOP_DIR/桌面图标状态.desktop"
    rm -f "$BIN_DIR/.kdi-hide.sh" "$BIN_DIR/.kdi-restore.sh" "$BIN_DIR/.kdi-status.sh"
    update-desktop-database "$APP_DIR" 2>/dev/null || true
    echo "已移除桌面图标（图标显隐状态未改动，如需恢复请用隐藏/恢复脚本）。"
    exit 0
}
[ "${1:-}" = "remove" ] && do_remove

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$APP_DIR" "$ICON_DIR"
cp -a "$REPO_DIR/hide-desktop-icons.sh" "$INSTALL_DIR/"
[ -f "$REPO_DIR/assets/hide.png" ] && cp -a "$REPO_DIR/assets/hide.png" "$ICON_DIR/kdi-hide.png"
[ -f "$REPO_DIR/assets/restore.png" ] && cp -a "$REPO_DIR/assets/restore.png" "$ICON_DIR/kdi-restore.png"

# 三个动作脚本：调用核心脚本，并把结果用桌面通知呈现
make_runner() {
    local name="$1" arg="$2" title="$3" msg="$4"
    cat > "$BIN_DIR/$name" <<EOF
#!/bin/bash
export DISPLAY="\${DISPLAY:-:0}"
[ -z "\${DBUS_SESSION_BUS_ADDRESS:-}" ] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/\$(id -u)/bus"
OUT=\$(bash "$INSTALL_DIR/hide-desktop-icons.sh" "$arg" 2>&1)
if echo "\$OUT" | grep -q "警告\|错误\|失败"; then
    notify-send "$title - 未生效" "\$OUT" 2>/dev/null
elif [ "$arg" = "status" ]; then
    DETAIL=\$(echo "\$OUT" | grep icon-visible | sed 's/^ *//' | tr '\n' ';')
    notify-send "$title" "\$DETAIL" 2>/dev/null
else
    notify-send "$title" "$msg" 2>/dev/null
fi
EOF
    chmod +x "$BIN_DIR/$name"
}
make_runner ".kdi-hide.sh"    hide    "隐藏桌面图标" "计算机/回收站/主文件夹已隐藏"
make_runner ".kdi-restore.sh" restore "恢复桌面图标" "三个系统图标已恢复显示"
make_runner ".kdi-status.sh"  status  "桌面图标状态" ""

make_desktop() {
    local file="$1" name="$2" exec="$3" icon="$4" comment="$5"
    cat > "$APP_DIR/$file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=$comment
Exec=$exec
Icon=$icon
Terminal=false
Categories=Utility;
StartupNotify=false
EOF
    chmod +x "$APP_DIR/$file"
}

make_desktop "kdi-hide.desktop"    "隐藏桌面系统图标" "$BIN_DIR/.kdi-hide.sh"    "kdi-hide"    "隐藏计算机/回收站/主文件夹（可恢复）"
make_desktop "kdi-restore.desktop" "恢复桌面系统图标" "$BIN_DIR/.kdi-restore.sh" "kdi-restore" "恢复三个系统图标的显示"
make_desktop "kdi-status.desktop"  "桌面图标状态"     "$BIN_DIR/.kdi-status.sh"  "kdi-restore" "查看三个系统图标当前的显示状态"

# 只在桌面放中文命名一份，避免重复图标
cp -f "$APP_DIR/kdi-hide.desktop"    "$DESKTOP_DIR/隐藏桌面系统图标.desktop"
cp -f "$APP_DIR/kdi-restore.desktop" "$DESKTOP_DIR/恢复桌面系统图标.desktop"
cp -f "$APP_DIR/kdi-status.desktop"  "$DESKTOP_DIR/桌面图标状态.desktop"
chmod +x "$DESKTOP_DIR/隐藏桌面系统图标.desktop" "$DESKTOP_DIR/恢复桌面系统图标.desktop" "$DESKTOP_DIR/桌面图标状态.desktop"

update-desktop-database "$APP_DIR" 2>/dev/null || true
gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "安装完成。桌面上出现三个图标："
echo "  隐藏桌面系统图标 / 恢复桌面系统图标 / 桌面图标状态"
echo "卸载：bash $REPO_DIR/install-desktop.sh remove"
