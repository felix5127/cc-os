#!/bin/bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║  CC-GEB Installer — Claude Code 配置工具包      ║
# ╚══════════════════════════════════════════════╝

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ┌──────────────────────────────────┐"
echo "  │  CC-GEB — Claude Code 配置工具包   │"
echo "  └──────────────────────────────────┘"
echo ""

# ── 0. 前置检查 ──────────────────────────────────

if command -v claude &>/dev/null; then
  echo "[*] Claude Code CLI 已检测到"
else
  echo "[!] 未检测到全局 claude 命令"
  echo "    全局安装: npm install -g @anthropic-ai/claude-code"
  echo ""
  read -rp "    继续安装？[Y/n]: " cont
  [[ "$cont" =~ ^[Nn] ]] && echo "已取消。" && exit 0
fi

# ── 1. 备份已有配置 ──────────────────────────────

if [ -f "$CLAUDE_DIR/CLAUDE.md" ] || [ -d "$CLAUDE_DIR/rules" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backups/cc-geb-$(date +%Y%m%d_%H%M%S)"
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

# ── 3. 复制全局配置（极简层）────────────────────

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "[+] CLAUDE.md (全局配置，15 行)"

for f in "$SCRIPT_DIR"/rules/*.md; do
  cp "$f" "$CLAUDE_DIR/rules/"
  echo "[+] rules/$(basename "$f")"
done

# ── 4. 复制模板（供 /cc-geb 使用）────────────────

for f in "$SCRIPT_DIR"/templates/*.md; do
  cp "$f" "$CLAUDE_DIR/templates/"
  echo "[+] templates/$(basename "$f")"
done

# ── 5. 复制 Skills ─────────────────────────────

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$CLAUDE_DIR/skills/$skill_name"
  cp "$skill_dir"* "$CLAUDE_DIR/skills/$skill_name/" 2>/dev/null || true
  echo "[+] skills/$skill_name"
done

# ── 6. 复制脚本 ─────────────────────────────────

mkdir -p "$CLAUDE_DIR/scripts"
for f in "$SCRIPT_DIR"/scripts/*.sh; do
  [ -f "$f" ] || continue
  cp "$f" "$CLAUDE_DIR/scripts/"
  chmod +x "$CLAUDE_DIR/scripts/$(basename "$f")"
  echo "[+] scripts/$(basename "$f")"
done

# ── 7. settings.json ────────────────────────────

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo ""
  echo "[?] 检测到已有 settings.json"
  echo "    (1) 覆盖  (2) 跳过  (3) 备份后覆盖"
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

# ── 8. 完成 ─────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  安装完成！"
echo ""
echo "  使用方式："
echo "    1. cd 到任意项目"
echo "    2. 启动 claude"
echo "    3. 说 /cc-geb 或「帮我初始化项目」"
echo ""
echo "  CC-GEB 全局层已生效（语言偏好 + 编码风格）"
echo "  项目级配置通过 /cc-geb 按需生成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
