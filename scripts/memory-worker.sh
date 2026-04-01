#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Memory Worker (后台执行)
# 读取 extract.json → 构造多类别提取 prompt → 调 Haiku
# → memory-dedup.py 解析输出 → 写入 memory/*.md → 更新索引
# ──────────────────────────────────────────────
set -uo pipefail

EXTRACT_FILE="$1"
SESSION_ID="${2:-unknown}"
MEMORY_DIR="$HOME/.claude/projects/-Users-felix/memory"
SCRIPTS_DIR="$HOME/.claude/scripts"

if [ ! -f "$EXTRACT_FILE" ]; then
  exit 1
fi

# ── 解析提取结果 ──
CWD=$(python3 -c "import json; print(json.load(open('$EXTRACT_FILE'))['cwd'])" 2>/dev/null || echo "")
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# ── 读取 transcript ──
WORK_DIR=$(dirname "$EXTRACT_FILE")
TRANSCRIPT_FILE="$WORK_DIR/mem_transcript.txt"
python3 -c "import json; print(json.load(open('$EXTRACT_FILE'))['text'])" > "$TRANSCRIPT_FILE" 2>/dev/null

TRANSCRIPT_LEN=$(wc -c < "$TRANSCRIPT_FILE" 2>/dev/null || echo 0)
if [ "$TRANSCRIPT_LEN" -lt 200 ]; then
  rm -f "$EXTRACT_FILE" "$TRANSCRIPT_FILE"
  exit 0
fi

# ── 读取已有记忆索引（传给 Haiku 做去重参考） ──
MEMORY_INDEX=""
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  MEMORY_INDEX=$(cat "$MEMORY_DIR/MEMORY.md")
fi

# ── 构造多类别提取 prompt ──
PROMPT_FILE="$WORK_DIR/mem_prompt.txt"
cat > "$PROMPT_FILE" << PROMPT_EOF
你是一个记忆提取器。分析以下 Claude Code 对话记录，提取值得长期记忆的信息。

已有记忆索引（避免重复）:
$MEMORY_INDEX

项目: $PROJECT_NAME
工作目录: $CWD

提取规则（4 类）:
1. feedback — 用户对 AI 行为的纠正或偏好指导（"以后不要..."、"记住..."、"别..."）
2. project — 技术决策、项目状态、架构选择（非代码级细节）
3. user — 用户角色、技能、工作偏好（非个人隐私）
4. reference — 外部资源、工具、URL、文档位置

严格禁止:
- 不记录个人隐私（姓名、联系方式、简历信息）
- 不重复已有记忆索引中已覆盖的内容
- 不记录临时的调试过程或代码实现细节
- 不记录纯粹的闲聊或问候

如果没有值得提取的记忆，只输出一个词: SKIP

输出格式（可多条，每条一个 MEMORY 块）:
---MEMORY---
type: feedback|project|user|reference
name: kebab-case-identifier
description: 一句话描述（用于未来检索判断是否相关）
---CONTENT---
记忆内容（中文）
feedback/project 类型需包含:
**Why:** 为什么要记住这个
**How to apply:** 在什么场景下使用
---END---

对话记录:
$(cat "$TRANSCRIPT_FILE")
PROMPT_EOF

# ── 调用 Haiku ──
RESULT=$(claude -p "$(cat "$PROMPT_FILE")" --model haiku 2>/dev/null || echo "SKIP")

# ── 检查是否跳过或调用失败 ──
if [ -z "$RESULT" ] || echo "$RESULT" | head -3 | grep -qi "SKIP"; then
  rm -rf "$WORK_DIR"
  exit 0
fi

# ── 写入临时结果文件 ──
RESULT_FILE="$WORK_DIR/mem_result.txt"
echo "$RESULT" > "$RESULT_FILE"

# ── 调用 dedup 解析 + 写入 ──
python3 "$SCRIPTS_DIR/memory-dedup.py" "$RESULT_FILE"

# ── 清理整个临时目录 ──
rm -rf "$WORK_DIR"
