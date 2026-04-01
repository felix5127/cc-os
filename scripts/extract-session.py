#!/usr/bin/env python3
"""
从 Claude Code session JSONL 中提取可读对话记录。
用法: python3 extract-session.py <session_id> [max_chars]

输出: 人类可读的对话文本（user 消息 + assistant 文本 + 工具调用摘要 + 错误）
"""

import json
import os
import sys
import glob


def find_jsonl(session_id: str) -> str | None:
    """在 ~/.claude/projects/ 下查找 session JSONL 文件"""
    pattern = os.path.expanduser(f"~/.claude/projects/*/{session_id}.jsonl")
    matches = glob.glob(pattern)
    return matches[0] if matches else None


def extract_text_from_content(content) -> str:
    """从 message.content 中提取可读文本"""
    if isinstance(content, str):
        return content

    parts = []
    if not isinstance(content, list):
        return ""

    for block in content:
        if not isinstance(block, dict):
            continue

        btype = block.get("type", "")

        if btype == "text":
            parts.append(block.get("text", ""))

        elif btype == "tool_use":
            name = block.get("name", "?")
            inp = block.get("input", {})
            # 只保留关键信息，不dump整个input
            summary = ""
            if name in ("Read", "Glob", "Grep"):
                summary = inp.get("file_path") or inp.get("pattern") or ""
            elif name == "Bash":
                cmd = inp.get("command", "")
                summary = cmd[:120] + ("..." if len(cmd) > 120 else "")
            elif name in ("Edit", "Write"):
                summary = inp.get("file_path", "")
            else:
                summary = str(inp)[:80]
            parts.append(f"[Tool: {name}] {summary}")

        elif btype == "tool_result":
            is_error = block.get("is_error", False)
            if is_error:
                text = block.get("content", "")
                if isinstance(text, str):
                    parts.append(f"[ERROR] {text[:200]}")

    return "\n".join(parts)


def extract_session(session_id: str, max_chars: int = 15000) -> dict:
    """
    提取 session 内容，返回:
    {
        "text": 可读对话文本,
        "cwd": 工作目录,
        "stats": { "user_msgs", "assistant_msgs", "tool_calls", "errors" }
    }
    """
    filepath = find_jsonl(session_id)
    if not filepath:
        return {"text": "", "cwd": "", "stats": {"user_msgs": 0, "assistant_msgs": 0, "tool_calls": 0, "errors": 0}}

    lines = []
    cwd = ""
    stats = {"user_msgs": 0, "assistant_msgs": 0, "tool_calls": 0, "errors": 0}
    seen_msg_ids = set()

    with open(filepath, "r", encoding="utf-8") as f:
        for raw_line in f:
            raw_line = raw_line.strip()
            if not raw_line:
                continue
            try:
                entry = json.loads(raw_line)
            except json.JSONDecodeError:
                continue

            # 跳过非消息条目
            entry_type = entry.get("type", "")
            if entry_type not in ("user", "assistant"):
                continue

            if not cwd:
                cwd = entry.get("cwd", "")

            msg = entry.get("message", {})
            role = msg.get("role", entry_type)
            content = msg.get("content", "")

            # 去重：assistant 消息可能有多个 partial 条目（同一个 msg id）
            msg_id = msg.get("id", "")
            if role == "assistant" and msg_id:
                if msg_id in seen_msg_ids:
                    # 保留最后一个（最完整的）
                    # 先移除之前的
                    lines = [(r, t) for r, t in lines if not (r == "assistant" and t.startswith(f"[{msg_id}]"))]
                seen_msg_ids.add(msg_id)

            text = extract_text_from_content(content)
            if not text.strip():
                continue

            if role == "user":
                stats["user_msgs"] += 1
                lines.append(("user", text))
            elif role == "assistant":
                stats["assistant_msgs"] += 1
                tag = f"[{msg_id}]" if msg_id else ""
                lines.append(("assistant", f"{tag}{text}"))
                # 统计工具调用和错误
                if isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict):
                            if block.get("type") == "tool_use":
                                stats["tool_calls"] += 1
                            if block.get("type") == "tool_result" and block.get("is_error"):
                                stats["errors"] += 1

    # 组装输出文本，从尾部截断到 max_chars
    output_lines = []
    for role, text in lines:
        prefix = "Human" if role == "user" else "Assistant"
        output_lines.append(f"\n--- {prefix} ---\n{text}")

    full_text = "\n".join(output_lines)
    if len(full_text) > max_chars:
        full_text = full_text[-max_chars:]
        # 从第一个完整消息开始
        idx = full_text.find("\n--- ")
        if idx > 0:
            full_text = full_text[idx:]

    return {"text": full_text, "cwd": cwd, "stats": stats}


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: extract-session.py <session_id> [max_chars]", file=sys.stderr)
        sys.exit(1)

    sid = sys.argv[1]
    max_c = int(sys.argv[2]) if len(sys.argv) > 2 else 15000
    result = extract_session(sid, max_c)

    # 输出 JSON 给 shell 脚本解析
    json.dump(result, sys.stdout, ensure_ascii=False)
