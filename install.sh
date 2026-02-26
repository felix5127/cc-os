#!/bin/bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║  CC-OS Installer — Claude Code 工程操作系统    ║
# ╚══════════════════════════════════════════════╝

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ┌──────────────────────────────────┐"
echo "  │  CC-OS — Claude Code 工程操作系统  │"
echo "  └──────────────────────────────────┘"
echo ""

# ── 0. 前置检查 ──────────────────────────────────

if ! command -v claude &>/dev/null; then
  echo "[!] Claude Code CLI 未安装"
  echo "    请先运行: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

echo "[*] Claude Code CLI 已检测到"

# ── 1. 备份已有配置 ──────────────────────────────

if [ -f "$CLAUDE_DIR/CLAUDE.md" ] || [ -d "$CLAUDE_DIR/rules" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backups/cc-os-$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
  [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/"
  [ -d "$CLAUDE_DIR/templates" ] && cp -r "$CLAUDE_DIR/templates" "$BACKUP_DIR/"
  [ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/"
  echo "[*] 已备份现有配置到 $BACKUP_DIR"
fi

# ── 2. 创建目录结构 ──────────────────────────────

mkdir -p "$CLAUDE_DIR"/{rules,templates,skills}
echo "[*] 目录结构已就绪"

# ── 3. 复制配置文件 ──────────────────────────────

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "[+] CLAUDE.md (L0 宪法)"

for f in "$SCRIPT_DIR"/rules/*.md; do
  cp "$f" "$CLAUDE_DIR/rules/"
  echo "[+] rules/$(basename "$f")"
done

for f in "$SCRIPT_DIR"/templates/*.md; do
  cp "$f" "$CLAUDE_DIR/templates/"
  echo "[+] templates/$(basename "$f")"
done

# ── 4. 合并 settings.json ────────────────────────

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo ""
  echo "[?] 检测到已有 settings.json"
  echo "    (1) 覆盖（使用 CC-OS 配置）"
  echo "    (2) 跳过（保留现有配置）"
  echo "    (3) 备份后覆盖"
  read -rp "    请选择 [1/2/3]: " choice
  case $choice in
    1) cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
       echo "[+] settings.json (已覆盖)" ;;
    3) cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
       cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
       echo "[+] settings.json (已备份并覆盖)" ;;
    *) echo "[-] settings.json (已跳过)" ;;
  esac
else
  cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  echo "[+] settings.json"
fi

# ── 5. 提示安装插件 ──────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  配置文件安装完成！"
echo ""
echo "  接下来请在 Claude Code 中安装插件："
echo ""
echo "  /install-plugin superpowers@superpowers-marketplace"
echo "  /install-plugin everything-claude-code@everything-claude-code"
echo "  /install-plugin planning-with-files@planning-with-files"
echo "  /install-plugin claude-hud@claude-hud"
echo "  /install-plugin code-simplifier@claude-plugins-official"
echo "  /install-plugin ralph-wiggum@claude-code-plugins"
echo ""
echo "  如果找不到插件，先添加 marketplace："
echo "  /add-marketplace everything-claude-code --repo affaan-m/everything-claude-code"
echo "  /add-marketplace planning-with-files --repo OthmanAdi/planning-with-files"
echo "  /add-marketplace claude-hud --repo jarrodwatts/claude-hud"
echo "  /add-marketplace superpowers-marketplace --repo obra/superpowers-marketplace"
echo ""
echo "  详细说明请参考: CC-OS-安装手册.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
