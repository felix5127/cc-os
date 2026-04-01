#!/usr/bin/env bash
# ──────────────────────────────────────────────
# PostToolUse hook for Edit|Write — 记录变更文件路径
# 追加到 .summary-state/{project_hash}.pending
# ──────────────────────────────────────────────

# ── 读取 hook stdin ──
HOOK_INPUT=""
if [ ! -t 0 ]; then
  HOOK_INPUT=$(cat)
fi

# 立即返回，不阻塞工具执行
echo '{}'

# ── 提取 file_path ──
FILE_PATH=$(echo "$HOOK_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || true)

if [ -z "$FILE_PATH" ] || [ ! -e "$FILE_PATH" ]; then
  exit 0
fi

# ── 寻找项目根目录（向上查找 CLAUDE.md 或 .git） ──
find_project_root() {
  local dir="$1"
  while [ "$dir" != "/" ] && [ "$dir" != "" ]; do
    if [ -f "$dir/CLAUDE.md" ] || [ -d "$dir/.git" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
}

PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")")
if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

# 项目必须有 CLAUDE.md 才能更新摘要
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  exit 0
fi

# ── 记录到 pending 文件 ──
PROJECT_HASH=$(echo -n "$PROJECT_ROOT" | md5 2>/dev/null || echo -n "$PROJECT_ROOT" | md5sum | cut -d' ' -f1)
STATE_DIR="$HOME/.claude/scripts/.summary-state"
mkdir -p "$STATE_DIR"

PENDING_FILE="$STATE_DIR/${PROJECT_HASH}.pending"

# 首行写入项目根路径（仅一次）
if [ ! -f "$PENDING_FILE" ]; then
  echo "PROJECT_ROOT=$PROJECT_ROOT" > "$PENDING_FILE"
fi

# 追加变更文件路径
echo "$FILE_PATH" >> "$PENDING_FILE"
