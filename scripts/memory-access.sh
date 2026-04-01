#!/usr/bin/env bash
# ──────────────────────────────────────────────
# PreToolUse hook for Read — 追踪记忆文件访问
# 更新 frontmatter: last_accessed + access_count++
# 同步返回 {} 不阻塞，后台更新
# ──────────────────────────────────────────────

# ── 读取 hook stdin ──
HOOK_INPUT=""
if [ ! -t 0 ]; then
  HOOK_INPUT=$(cat)
fi

# 立即返回，不阻塞 Read 工具执行
echo '{}'

# ── 提取 file_path ──
FILE_PATH=$(echo "$HOOK_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || true)

# ── 检查是否为 memory 文件 ──
MEMORY_DIR="$HOME/.claude/projects/-Users-felix/memory"

case "$FILE_PATH" in
  "$MEMORY_DIR"/*.md)
    BASENAME=$(basename "$FILE_PATH")
    # 跳过索引文件
    if [ "$BASENAME" = "MEMORY.md" ] || [ "$BASENAME" = "INDEX.md" ]; then
      exit 0
    fi
    # 跳过子目录中的文件
    if [ "$(dirname "$FILE_PATH")" != "$MEMORY_DIR" ]; then
      exit 0
    fi

    # 后台更新 frontmatter（不阻塞主流程）
    python3 - "$FILE_PATH" << 'PYEOF' &
import sys
import os
import re
from datetime import date

fp = sys.argv[1]
if not os.path.isfile(fp):
    sys.exit(0)

with open(fp, "r", encoding="utf-8") as f:
    content = f.read()

if not content.startswith("---"):
    sys.exit(0)

today = date.today().strftime("%Y-%m-%d")
changed = False

# ── 更新 last_accessed ──
if "last_accessed:" in content:
    new_content = re.sub(r"last_accessed: .+", f"last_accessed: {today}", content)
    if new_content != content:
        content = new_content
        changed = True
else:
    # 在 frontmatter 末尾 --- 前插入
    content = content.replace("\n---\n", f"\nlast_accessed: {today}\n---\n", 1)
    changed = True

# ── 更新 access_count ──
match = re.search(r"access_count: (\d+)", content)
if match:
    count = int(match.group(1)) + 1
    content = re.sub(r"access_count: \d+", f"access_count: {count}", content)
    changed = True
else:
    content = content.replace("\n---\n", f"\naccess_count: 1\n---\n", 1)
    changed = True

if changed:
    with open(fp, "w", encoding="utf-8") as f:
        f.write(content)
PYEOF
    ;;
esac
