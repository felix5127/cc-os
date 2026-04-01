#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Lesson Worker (后台执行)
# 读取 extract.json → 调 Haiku 总结 → 写入 lesson 文件 + 更新索引
# ──────────────────────────────────────────────
set -uo pipefail

EXTRACT_FILE="$1"
LESSONS_DIR="$HOME/.claude/projects/-Users-felix/memory/lessons"

if [ ! -f "$EXTRACT_FILE" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M')] ERROR: extract file not found: $EXTRACT_FILE"
  exit 1
fi

# ── 解析提取结果 ──
CWD=$(python3 -c "import json; print(json.load(open('$EXTRACT_FILE'))['cwd'])" 2>/dev/null || echo "")
ERRORS=$(python3 -c "import json; print(json.load(open('$EXTRACT_FILE'))['stats']['errors'])" 2>/dev/null || echo 0)
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# 把 transcript 写到单独文件，用 stdin 传给 claude
TRANSCRIPT_FILE="$(dirname "$EXTRACT_FILE")/transcript.txt"
python3 -c "import json; print(json.load(open('$EXTRACT_FILE'))['text'])" > "$TRANSCRIPT_FILE" 2>/dev/null

TRANSCRIPT_LEN=$(wc -c < "$TRANSCRIPT_FILE" 2>/dev/null || echo 0)
if [ "$TRANSCRIPT_LEN" -lt 200 ]; then
  rm -rf "$(dirname "$EXTRACT_FILE")"
  exit 0
fi

# ── 构造 prompt 文件 ──
PROMPT_FILE="$(dirname "$EXTRACT_FILE")/prompt.txt"
cat > "$PROMPT_FILE" << PROMPT_EOF
你是一个工程日志分析器。请分析以下 Claude Code 对话记录，提取有价值的教训。

项目: $PROJECT_NAME
工作目录: $CWD
错误数: $ERRORS

要求:
1. 如果这个对话没有值得记录的教训（纯粹是简单的代码编写、文档查看、闲聊），只输出一个词: SKIP
2. 如果有值得记录的内容，用以下格式输出:

---
name: [kebab-case 标识]
description: [一句话描述这个教训]
type: lesson
---

# [一句话标题]

**项目**: $PROJECT_NAME
**标签**: [逗号分隔, 如 debug, python, ssl]

## 问题
[1-3 句话]

## 解法
[1-3 句话]

## 教训
[下次遇到类似情况的行动指南, 1-3 句话]

注意:
- 只记录: 踩坑、调试技巧、关键决策、非显而易见的解法
- 不记录: 简单代码编写、文件读取、常规操作、项目评估/调研
- 保持简洁
- 用中文输出

对话记录:
$(cat "$TRANSCRIPT_FILE")
PROMPT_EOF

# ── 调用 Haiku ──
RESULT=$(claude -p "$(cat "$PROMPT_FILE")" --model haiku 2>/dev/null || echo "SKIP")

# ── 检查是否跳过 ──
if echo "$RESULT" | head -3 | grep -qi "SKIP"; then
  rm -rf "$(dirname "$EXTRACT_FILE")"
  exit 0
fi

# ── 写入 lesson 文件 ──
NOW=$(TZ=Asia/Shanghai date +"%Y-%m-%d_%H%M")
LESSON_FILE="$LESSONS_DIR/${NOW}_${PROJECT_NAME}.md"
if [ -f "$LESSON_FILE" ]; then
  LESSON_FILE="$LESSONS_DIR/${NOW}_${PROJECT_NAME}_$$.md"
fi

echo "$RESULT" > "$LESSON_FILE"
echo "[$(date '+%Y-%m-%d %H:%M')] OK: wrote $LESSON_FILE"

# ── 更新 INDEX.md ──
INDEX_FILE="$LESSONS_DIR/INDEX.md"
if [ ! -f "$INDEX_FILE" ]; then
  cat > "$INDEX_FILE" << 'INDEX_EOF'
# Lessons Index

自动生成的踩坑教训索引。Claude 在需要时检索此文件。

| 日期 | 项目 | 标签 | 摘要 | 文件 |
|------|------|------|------|------|
INDEX_EOF
fi

TITLE=$(echo "$RESULT" | grep "^# " | head -1 | sed 's/^# //')
TAGS=$(echo "$RESULT" | grep "^\*\*标签\*\*" | head -1 | sed 's/\*\*标签\*\*: //' || echo "")
FILENAME=$(basename "$LESSON_FILE")
DATE_DISPLAY=$(echo "$NOW" | sed 's/_/ /')

echo "| $DATE_DISPLAY | $PROJECT_NAME | $TAGS | $TITLE | [$FILENAME]($FILENAME) |" >> "$INDEX_FILE"

# ── 清理临时文件 ──
rm -rf "$(dirname "$EXTRACT_FILE")"
