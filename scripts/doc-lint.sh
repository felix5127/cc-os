#!/bin/bash
# ──────────────────────────────────────────────────────────
# doc-lint.sh — CC-Kit 文档同步检查 hook
# ──────────────────────────────────────────────────────────
# PostToolUse hook: 当 Edit/Write 修改代码文件时，
# 检查同目录或项目根目录是否有对应文档需要同步更新。
# 输出提醒信息注入 agent context，不阻塞操作。
# ──────────────────────────────────────────────────────────

# hook 通过 stdin 接收 JSON，包含 tool_name 和 tool_input
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('file_path',''))" 2>/dev/null)

# 只关注 Edit 和 Write 操作
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# 跳过非代码文件（文档、配置、锁文件等）
case "$FILE_PATH" in
  *.md|*.mdx|*.txt|*.json|*.yaml|*.yml|*.toml|*.lock|*.log|*.csv)
    exit 0
    ;;
esac

# 跳过 node_modules、.git、dist 等非业务目录
case "$FILE_PATH" in
  */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/.next/*|*/__pycache__/*)
    exit 0
    ;;
esac

# 跳过非项目文件（不在 git 仓库中的文件）
FILE_DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=$(cd "$FILE_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$PROJECT_ROOT" ]]; then
  exit 0
fi

# ── 检查项目级文档是否存在 ──
DOC_HINTS=""

# 检查 CLAUDE.md (L1)
if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
  # 获取文件相对路径
  REL_PATH="${FILE_PATH#$PROJECT_ROOT/}"
  MODULE_DIR=$(echo "$REL_PATH" | cut -d'/' -f1-2)

  # 检查 CLAUDE.md 是否提及这个模块/目录
  if ! grep -q "$MODULE_DIR" "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
    DOC_HINTS="${DOC_HINTS}⚠ 模块 '$MODULE_DIR' 未在 CLAUDE.md 中记录\n"
  fi
fi

# 检查同目录下是否有 README 且最近未更新
DIR_README="$FILE_DIR/README.md"
if [[ -f "$DIR_README" ]]; then
  # 如果 README 超过 30 天未更新，提醒检查
  README_AGE=$(( ( $(date +%s) - $(stat -f %m "$DIR_README" 2>/dev/null || stat -c %Y "$DIR_README" 2>/dev/null || echo 0) ) / 86400 ))
  if [[ $README_AGE -gt 30 ]]; then
    DOC_HINTS="${DOC_HINTS}⚠ $DIR_README 已 ${README_AGE} 天未更新，可能需要同步\n"
  fi
fi

# 检查是否有 ARCHITECTURE.md 或 STACK.md
if [[ -f "$PROJECT_ROOT/STACK.md" ]]; then
  STACK_AGE=$(( ( $(date +%s) - $(stat -f %m "$PROJECT_ROOT/STACK.md" 2>/dev/null || stat -c %Y "$PROJECT_ROOT/STACK.md" 2>/dev/null || echo 0) ) / 86400 ))
  if [[ $STACK_AGE -gt 14 ]]; then
    DOC_HINTS="${DOC_HINTS}⚠ STACK.md 已 ${STACK_AGE} 天未更新\n"
  fi
fi

# 输出提醒（如果有的话）
if [[ -n "$DOC_HINTS" ]]; then
  echo ""
  echo "📋 CC-Kit Doc-Lint 提醒："
  echo -e "$DOC_HINTS"
  echo "法则：禁止孤立变更 — 改代码不改文档 → 架构破坏"
  echo ""
fi

exit 0
