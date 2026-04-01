#!/usr/bin/env python3
"""
解析 Haiku 多类别记忆输出 → 去重检查 → 写入文件 → 更新索引
用法: python3 memory-dedup.py <haiku_output_file>

输入格式:
---MEMORY---
type: feedback|project|user|reference
name: kebab-case-identifier
description: 一句话描述
---CONTENT---
记忆正文
---END---
"""

import os
import sys
from datetime import date


# ── 常量 ──────────────────────────────────────
MEMORY_DIR = os.path.expanduser("~/.claude/projects/-Users-felix/memory")

# type → MEMORY.md section header
TYPE_TO_SECTION = {
    "feedback": "## Feedback",
    "project":  "## Project",
    "user":     "## User",
    "reference": "## Reference",
}


# ── 解析 ──────────────────────────────────────

def parse_memories(text: str) -> list[dict]:
    """解析 ---MEMORY--- / ---CONTENT--- / ---END--- 块"""
    memories = []
    blocks = text.split("---MEMORY---")

    for block in blocks[1:]:
        if "---END---" not in block:
            continue

        if "---CONTENT---" not in block:
            continue

        header_part, rest = block.split("---CONTENT---", 1)
        content = rest.split("---END---")[0].strip()

        mem = {"content": content}
        for line in header_part.strip().split("\n"):
            if ":" in line:
                key, val = line.split(":", 1)
                mem[key.strip()] = val.strip()

        # 必须有 4 个字段才算有效
        required = ("type", "name", "description", "content")
        if all(k in mem and mem[k] for k in required):
            # 校验 type 合法
            if mem["type"] in TYPE_TO_SECTION:
                memories.append(mem)

    return memories


# ── 去重 ──────────────────────────────────────

def check_duplicate(memory_dir: str, memory: dict) -> bool:
    """检查 MEMORY.md 索引或同名文件是否已存在"""
    index_file = os.path.join(memory_dir, "MEMORY.md")
    if os.path.exists(index_file):
        with open(index_file, "r", encoding="utf-8") as f:
            index_content = f.read()
        # 按 name 去重
        if memory["name"] in index_content:
            return True

    # 按文件名模式去重
    type_prefix = memory["type"]
    name_slug = memory["name"].replace("-", "_")
    filename = f"{type_prefix}_{name_slug}.md"
    if os.path.exists(os.path.join(memory_dir, filename)):
        return True

    return False


# ── 写入 ──────────────────────────────────────

def write_memory(memory_dir: str, memory: dict) -> str:
    """写入带完整 frontmatter 的 .md 文件，返回文件名"""
    type_prefix = memory["type"]
    name_slug = memory["name"].replace("-", "_")
    filename = f"{type_prefix}_{name_slug}.md"
    filepath = os.path.join(memory_dir, filename)

    # 文件已存在则加时间戳后缀
    if os.path.exists(filepath):
        ts = date.today().strftime("%m%d")
        filename = f"{type_prefix}_{name_slug}_{ts}.md"
        filepath = os.path.join(memory_dir, filename)

    today = date.today().strftime("%Y-%m-%d")

    with open(filepath, "w", encoding="utf-8") as f:
        f.write("---\n")
        f.write(f"name: {memory['name']}\n")
        f.write(f"description: {memory['description']}\n")
        f.write(f"type: {memory['type']}\n")
        f.write(f"created: {today}\n")
        f.write(f"last_accessed: {today}\n")
        f.write(f"access_count: 0\n")
        f.write("---\n\n")
        f.write(memory["content"])
        f.write("\n")

    return filename


# ── 更新索引 ──────────────────────────────────

def update_index(memory_dir: str, memory: dict, filename: str) -> None:
    """在 MEMORY.md 对应 section 追加条目"""
    index_file = os.path.join(memory_dir, "MEMORY.md")
    if not os.path.exists(index_file):
        return

    with open(index_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    section_header = TYPE_TO_SECTION.get(memory["type"])
    if not section_header:
        return

    entry = f"- [{memory['name']}]({filename}) — {memory['description']}\n"

    # 找到目标 section，在其最后一个 `- ` 条目之后插入
    section_idx = -1
    insert_idx = -1

    for i, line in enumerate(lines):
        if line.strip() == section_header:
            section_idx = i
            insert_idx = i + 1  # 默认在 header 后一行
        elif section_idx >= 0:
            if line.startswith("- "):
                insert_idx = i + 1  # 跟在最后一个条目后
            elif line.startswith("## ") and i > section_idx:
                break  # 到了下一个 section，停止

    if section_idx < 0:
        # section 不存在，追加到末尾
        lines.append(f"\n{section_header}\n")
        insert_idx = len(lines)

    lines.insert(insert_idx, entry)

    with open(index_file, "w", encoding="utf-8") as f:
        f.writelines(lines)


# ── 主流程 ────────────────────────────────────

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: memory-dedup.py <haiku_output_file>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1], "r", encoding="utf-8") as f:
        text = f.read()

    memories = parse_memories(text)

    written = 0
    skipped = 0

    for mem in memories:
        if check_duplicate(MEMORY_DIR, mem):
            skipped += 1
            print(f"[SKIP] {mem['type']}/{mem['name']} (duplicate)")
            continue

        filename = write_memory(MEMORY_DIR, mem)
        update_index(MEMORY_DIR, mem, filename)
        written += 1
        print(f"[WRITE] {mem['type']}/{mem['name']} → {filename}")

    print(f"\nSummary: written={written}, skipped={skipped}")
