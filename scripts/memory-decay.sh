#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Memory Hotness Decay Scanner
# 计算记忆热度 → 标记 stale → 归档过期记忆
#
# 热度公式 (from OpenViking memory_lifecycle.py):
#   hotness = sigmoid(log1p(access_count)) × exp(-ln2/7 × idle_days)
#
# 策略:
#   feedback/user → 永不衰减
#   project       → 30d stale, 60d archive
#   reference     → 90d stale, 180d archive
#   lesson        → 45d stale, 60d archive
# ──────────────────────────────────────────────
set -uo pipefail

MEMORY_DIR="$HOME/.claude/projects/-Users-felix/memory"
STATE_DIR="$MEMORY_DIR/.state"
ARCHIVE_DIR="$MEMORY_DIR/.archive"
LAST_RUN_FILE="$STATE_DIR/last_decay"

mkdir -p "$STATE_DIR" "$ARCHIVE_DIR"

# ── 频率控制：每周最多一次（除非 --force） ──
if [ "${1:-}" != "--force" ]; then
  if [ -f "$LAST_RUN_FILE" ]; then
    LAST_TS=$(cat "$LAST_RUN_FILE")
    NOW_TS=$(date +%s)
    WEEK=$((7 * 24 * 3600))
    if [ $((NOW_TS - LAST_TS)) -lt $WEEK ]; then
      exit 0
    fi
  fi
fi

date +%s > "$LAST_RUN_FILE"

# ── 调用 Python 执行实际扫描 ──
python3 - "$MEMORY_DIR" "$ARCHIVE_DIR" << 'PYTHON_EOF'
import os
import sys
import re
from datetime import datetime, date


def parse_frontmatter(filepath):
    """
    解析 .md 文件的 YAML-like frontmatter
    返回 (meta_dict, full_content) 或 (None, content)
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    if not content.startswith("---"):
        return None, content

    parts = content.split("---", 2)
    if len(parts) < 3:
        return None, content

    meta = {}
    for line in parts[1].strip().split("\n"):
        if ":" in line:
            key, val = line.split(":", 1)
            meta[key.strip()] = val.strip()

    return meta, content


def calculate_idle_days(last_accessed_str, filepath):
    """
    计算闲置天数。优先用 frontmatter 的 last_accessed，
    fallback 到文件的实际修改时间。
    """
    try:
        last = datetime.strptime(last_accessed_str, "%Y-%m-%d").date()
    except (ValueError, TypeError):
        # fallback: 文件修改时间
        mtime = os.path.getmtime(filepath)
        last = datetime.fromtimestamp(mtime).date()

    return (date.today() - last).days


def mark_stale(filepath, content, mem_type):
    """在 frontmatter 中添加 status: stale"""
    if "status: stale" in content:
        return False

    if "status:" in content:
        new_content = re.sub(r"status: \w+", "status: stale", content)
    else:
        new_content = content.replace(
            f"type: {mem_type}",
            f"type: {mem_type}\nstatus: stale",
        )

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(new_content)

    return True


# ── 衰减阈值 (stale_days, archive_days) ──
# None = 永不衰减
THRESHOLDS = {
    "feedback":  (None, None),
    "user":      (None, None),
    "project":   (30, 60),
    "reference": (90, 180),
    "lesson":    (45, 60),
}


# ── 主扫描 ──
memory_dir = sys.argv[1]
archive_dir = sys.argv[2]

stale_count = 0
archive_count = 0
scan_count = 0

for fname in sorted(os.listdir(memory_dir)):
    if not fname.endswith(".md"):
        continue
    if fname in ("MEMORY.md", "INDEX.md"):
        continue

    filepath = os.path.join(memory_dir, fname)
    if os.path.isdir(filepath):
        continue

    meta, content = parse_frontmatter(filepath)
    if not meta:
        continue

    scan_count += 1
    mem_type = meta.get("type", "")
    thresholds = THRESHOLDS.get(mem_type)
    if not thresholds:
        continue

    stale_threshold, archive_threshold = thresholds

    idle_days = calculate_idle_days(
        meta.get("last_accessed", ""),
        filepath,
    )

    # 归档检查（优先于 stale）
    if archive_threshold and idle_days >= archive_threshold:
        dest = os.path.join(archive_dir, fname)
        os.rename(filepath, dest)
        archive_count += 1
        print(f"[ARCHIVE] {fname} (idle {idle_days}d)")
        continue

    # Stale 标记
    if stale_threshold and idle_days >= stale_threshold:
        if mark_stale(filepath, content, mem_type):
            stale_count += 1
            print(f"[STALE]   {fname} (idle {idle_days}d)")

print(f"\nDecay scan: {scan_count} files, {stale_count} stale, {archive_count} archived")
PYTHON_EOF
