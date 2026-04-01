#!/bin/bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║  CC-Kit Installer — Claude Code 配置工具包      ║
# ╚══════════════════════════════════════════════╝

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ┌──────────────────────────────────┐"
echo "  │  CC-Kit — Claude Code 配置工具包   │"
echo "  └──────────────────────────────────┘"
echo ""

# ── 0. 前置检查 ──────────────────────────────────

if command -v claude &>/dev/null; then
  echo "[*] Claude Code CLI 已检测到"
else
  echo "[!] 未检测到全局 claude 命令"
  echo "    如果你通过 npx 使用 Claude Code，可以忽略此警告"
  echo "    全局安装: npm install -g @anthropic-ai/claude-code"
  echo ""
  read -rp "    继续安装配置文件？[Y/n]: " cont
  [[ "$cont" =~ ^[Nn] ]] && echo "已取消。" && exit 0
fi

# ── 1. 备份已有配置 ──────────────────────────────

if [ -f "$CLAUDE_DIR/CLAUDE.md" ] || [ -d "$CLAUDE_DIR/rules" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backups/cc-kit-$(date +%Y%m%d_%H%M%S)"
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

cp "$SCRIPT_DIR/DOC_PROTOCOL.md" "$CLAUDE_DIR/DOC_PROTOCOL.md"
echo "[+] DOC_PROTOCOL.md (分形文档协议)"

cp "$SCRIPT_DIR/PHILOSOPHY.md" "$CLAUDE_DIR/PHILOSOPHY.md"
echo "[+] PHILOSOPHY.md (设计哲学)"

for f in "$SCRIPT_DIR"/rules/*.md; do
  cp "$f" "$CLAUDE_DIR/rules/"
  echo "[+] rules/$(basename "$f")"
done

for f in "$SCRIPT_DIR"/templates/*.md; do
  cp "$f" "$CLAUDE_DIR/templates/"
  echo "[+] templates/$(basename "$f")"
done

# ── 3b. 复制脚本文件 ─────────────────────────────

mkdir -p "$CLAUDE_DIR/scripts"
for f in "$SCRIPT_DIR"/scripts/*; do
  [ -f "$f" ] || continue
  cp "$f" "$CLAUDE_DIR/scripts/"
  chmod +x "$CLAUDE_DIR/scripts/$(basename "$f")"
  echo "[+] scripts/$(basename "$f")"
done

# ── 4. 合并 settings.json ────────────────────────

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo ""
  echo "[?] 检测到已有 settings.json"
  echo "    (1) 覆盖（使用 CC-Kit 配置）"
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
echo "  接下来请在终端中逐条运行以下命令安装插件："
echo ""
echo "  # 1. 添加第三方 marketplace"
echo "  claude plugin marketplace add affaan-m/everything-claude-code"
echo "  claude plugin marketplace add OthmanAdi/planning-with-files"
echo "  claude plugin marketplace add jarrodwatts/claude-hud"
echo "  claude plugin marketplace add obra/superpowers-marketplace"
echo ""
echo "  # 2. 安装插件"
echo "  claude plugin install superpowers@superpowers-marketplace"
echo "  claude plugin install everything-claude-code@everything-claude-code"
echo "  claude plugin install planning-with-files@planning-with-files"
echo "  claude plugin install claude-hud@claude-hud"
echo "  claude plugin install code-simplifier@claude-plugins-official"
echo "  claude plugin install ralph-wiggum@claude-code-plugins"
echo ""
echo "  详细说明请参考: CC-Kit-安装手册.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
