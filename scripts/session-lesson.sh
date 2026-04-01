#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Session Lesson Generator (Stop hook 入口)
# 提取对话 → 判断价值 → 后台调 Haiku 总结
#
# Workers:
#   lesson-worker.sh  — 踩坑教训提取
#   memory-worker.sh  — 多类别记忆提取
#   memory-decay.sh   — 记忆衰减（按 idle_days，每周一次）
# ──────────────────────────────────────────────
set -uo pipefail

LESSONS_DIR="$HOME/.claude/projects/-Users-felix/memory/lessons"
SCRIPTS_DIR="$HOME/.claude/scripts"
STATE_DIR="$LESSONS_DIR/.state"
mkdir -p "$LESSONS_DIR" "$STATE_DIR"

# ── 清理超过 7 天的 .done_ 去重文件 ──
find "$STATE_DIR" -name ".done_*" -type f -mtime +7 -delete 2>/dev/null || true

# ── 读取 hook stdin ──
HOOK_INPUT=""
if [ ! -t 0 ]; then
  HOOK_INPUT=$(cat)
fi

SESSION_ID=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null || true)

if [ -z "$SESSION_ID" ]; then
  echo '{}'
  exit 0
fi

# ── 去重 ──
if [ -f "$STATE_DIR/.done_${SESSION_ID}" ]; then
  echo '{}'
  exit 0
fi
touch "$STATE_DIR/.done_${SESSION_ID}"

# ── 提取对话到临时文件 ──
WORK_DIR=$(mktemp -d)
python3 "$SCRIPTS_DIR/extract-session.py" "$SESSION_ID" 15000 > "$WORK_DIR/extract.json" 2>/dev/null

if [ ! -s "$WORK_DIR/extract.json" ]; then
  rm -rf "$WORK_DIR"
  echo '{}'
  exit 0
fi

# ── 解析 stats ──
USER_MSGS=$(python3 -c "import sys,json; print(json.load(open('$WORK_DIR/extract.json'))['stats']['user_msgs'])" 2>/dev/null || echo 0)
TOOL_CALLS=$(python3 -c "import sys,json; print(json.load(open('$WORK_DIR/extract.json'))['stats']['tool_calls'])" 2>/dev/null || echo 0)

# ── 值不值得记录？ ──
if [ "$USER_MSGS" -lt 4 ] || [ "$TOOL_CALLS" -lt 2 ]; then
  rm -rf "$WORK_DIR"
  echo '{}'
  exit 0
fi

# ── 后台启动 lesson worker (原有) ──
nohup bash "$SCRIPTS_DIR/lesson-worker.sh" "$WORK_DIR/extract.json" >> "$STATE_DIR/worker.log" 2>&1 &

# ── 后台启动 memory worker (Feature 2) ──
MEMORY_STATE="$HOME/.claude/projects/-Users-felix/memory/.state"
mkdir -p "$MEMORY_STATE"
if [ ! -f "$MEMORY_STATE/.done_mem_${SESSION_ID}" ]; then
  # 独立临时目录，避免与 lesson-worker 竞态清理
  MEM_WORK_DIR=$(mktemp -d)
  cp "$WORK_DIR/extract.json" "$MEM_WORK_DIR/extract_mem.json"
  touch "$MEMORY_STATE/.done_mem_${SESSION_ID}"
  nohup bash "$SCRIPTS_DIR/memory-worker.sh" "$MEM_WORK_DIR/extract_mem.json" "$SESSION_ID" >> "$MEMORY_STATE/worker.log" 2>&1 &
fi

# ── 后台启动 decay scanner (内部频率控制每周一次) ──
nohup bash "$SCRIPTS_DIR/memory-decay.sh" >> "$MEMORY_STATE/decay.log" 2>&1 &

echo '{}'
