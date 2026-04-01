#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Summary Worker (后台执行)
# 读取 .pending 文件 → 收集变更文件内容 → Haiku 生成摘要
# → 就地更新项目 CLAUDE.md 的 <abstract> / <overview> 段
# ──────────────────────────────────────────────
set -uo pipefail

STATE_DIR="$HOME/.claude/scripts/.summary-state"

if [ ! -d "$STATE_DIR" ]; then
  exit 0
fi

# ── 逐个处理 pending 文件 ──
for PENDING_FILE in "$STATE_DIR"/*.pending; do
  [ -f "$PENDING_FILE" ] || continue

  # ── 读取项目根路径 ──
  PROJECT_ROOT=$(grep "^PROJECT_ROOT=" "$PENDING_FILE" | head -1 | cut -d= -f2-)
  if [ -z "$PROJECT_ROOT" ] || [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    rm -f "$PENDING_FILE"
    continue
  fi

  # ── 收集去重后的变更文件列表 ──
  CHANGED_FILES=$(grep -v "^PROJECT_ROOT=" "$PENDING_FILE" | sort -u)
  FILE_COUNT=$(echo "$CHANGED_FILES" | grep -c . || true)

  # 变更 < 3 个文件跳过（避免噪声）
  if [ "$FILE_COUNT" -lt 3 ]; then
    rm -f "$PENDING_FILE"
    continue
  fi

  # 项目 CLAUDE.md 必须有 <abstract> 或 <overview> 标签
  if ! grep -q '<abstract>' "$PROJECT_ROOT/CLAUDE.md" && ! grep -q '<overview>' "$PROJECT_ROOT/CLAUDE.md"; then
    rm -f "$PENDING_FILE"
    continue
  fi

  # ── 收集文件片段（每文件前 100 行，最多 10 个文件） ──
  SNIPPETS=""
  COUNT=0
  while IFS= read -r fpath; do
    [ -f "$fpath" ] || continue
    COUNT=$((COUNT + 1))
    [ $COUNT -gt 10 ] && break
    REL_PATH="${fpath#"$PROJECT_ROOT"/}"
    SNIPPET=$(head -100 "$fpath" 2>/dev/null || true)
    SNIPPETS="${SNIPPETS}
--- File: ${REL_PATH} ---
${SNIPPET}
--- End ---
"
  done <<< "$CHANGED_FILES"

  PROJECT_NAME=$(basename "$PROJECT_ROOT")

  # ── 构造 prompt ──
  WORK_DIR=$(mktemp -d)
  PROMPT_FILE="$WORK_DIR/summary_prompt.txt"
  cat > "$PROMPT_FILE" << PROMPT_EOF
你是一个项目文档生成器。基于以下变更的文件内容，为项目生成简洁的摘要。

项目: $PROJECT_NAME
变更文件数: $FILE_COUNT

请输出两个段落:

1. ABSTRACT（1-2 句话，项目做什么，核心价值）
2. OVERVIEW（3-5 个要点，当前主要模块和功能，用 markdown 列表）

格式:
---ABSTRACT---
[内容]
---OVERVIEW---
[内容]
---END---

如果文件内容不足以判断项目用途（如只有配置文件变更），输出: SKIP

变更文件内容:
$SNIPPETS
PROMPT_EOF

  # ── 调用 Haiku ──
  RESULT=$(claude -p "$(cat "$PROMPT_FILE")" --model haiku 2>/dev/null || echo "")

  if [ -z "$RESULT" ] || echo "$RESULT" | head -3 | grep -qi "SKIP"; then
    rm -f "$PENDING_FILE"
    rm -rf "$WORK_DIR"
    continue
  fi

  # ── 解析结果并更新 CLAUDE.md ──
  python3 - "$PROJECT_ROOT/CLAUDE.md" "$RESULT" << 'PYEOF'
import sys
import re

claude_md_path = sys.argv[1]
result_text = sys.argv[2]

with open(claude_md_path, "r", encoding="utf-8") as f:
    content = f.read()

changed = False

# 提取 abstract
abstract_match = re.search(
    r"---ABSTRACT---\s*(.+?)\s*---OVERVIEW---", result_text, re.DOTALL
)
if abstract_match:
    new_abstract = abstract_match.group(1).strip()
    new_content = re.sub(
        r"<abstract>.*?</abstract>",
        f"<abstract>\n{new_abstract}\n</abstract>",
        content,
        flags=re.DOTALL,
    )
    if new_content != content:
        content = new_content
        changed = True

# 提取 overview
overview_match = re.search(
    r"---OVERVIEW---\s*(.+?)\s*---END---", result_text, re.DOTALL
)
if overview_match:
    new_overview = overview_match.group(1).strip()
    new_content = re.sub(
        r"<overview>.*?</overview>",
        f"<overview>\n{new_overview}\n</overview>",
        content,
        flags=re.DOTALL,
    )
    if new_content != content:
        content = new_content
        changed = True

if changed:
    with open(claude_md_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[OK] Updated {claude_md_path}")
else:
    print("[SKIP] No changes to CLAUDE.md")
PYEOF

  rm -f "$PENDING_FILE"
  rm -rf "$WORK_DIR"
done
