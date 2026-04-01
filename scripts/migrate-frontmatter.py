#!/usr/bin/env python3
"""
一次性迁移：给已有记忆文件补充 frontmatter 生命周期字段
  - created:       从文件 mtime 推断
  - last_accessed: 设为今天
  - access_count:  设为 0

用法: python3 migrate-frontmatter.py [memory_dir]
"""

import os
import sys
from datetime import datetime, date


MEMORY_DIR = (
    sys.argv[1]
    if len(sys.argv) > 1
    else os.path.expanduser("~/.claude/projects/-Users-felix/memory")
)


def migrate_file(filepath: str) -> bool:
    """给单个文件补 frontmatter 字段，返回是否有变更"""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    if not content.startswith("---"):
        return False

    # 已经全部有了就跳过
    has_all = (
        "created:" in content
        and "last_accessed:" in content
        and "access_count:" in content
    )
    if has_all:
        return False

    parts = content.split("---", 2)
    if len(parts) < 3:
        return False

    frontmatter_lines = parts[1].strip().split("\n")
    body = parts[2]

    # 从 mtime 推断创建日期
    mtime = os.path.getmtime(filepath)
    created = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")
    today = date.today().strftime("%Y-%m-%d")

    existing_keys = set()
    for line in frontmatter_lines:
        if ":" in line:
            key = line.split(":", 1)[0].strip()
            existing_keys.add(key)

    if "created" not in existing_keys:
        frontmatter_lines.append(f"created: {created}")
    if "last_accessed" not in existing_keys:
        frontmatter_lines.append(f"last_accessed: {today}")
    if "access_count" not in existing_keys:
        frontmatter_lines.append(f"access_count: 0")

    new_content = f"---\n{chr(10).join(frontmatter_lines)}\n---{body}"

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(new_content)

    return True


if __name__ == "__main__":
    migrated = 0
    skipped = 0

    for fname in sorted(os.listdir(MEMORY_DIR)):
        if not fname.endswith(".md"):
            continue
        if fname in ("MEMORY.md", "INDEX.md"):
            continue

        filepath = os.path.join(MEMORY_DIR, fname)
        if os.path.isdir(filepath):
            continue

        if migrate_file(filepath):
            migrated += 1
            print(f"[+] {fname}")
        else:
            skipped += 1
            print(f"[-] {fname} (already migrated or no frontmatter)")

    print(f"\nMigrated: {migrated}, Skipped: {skipped}")
