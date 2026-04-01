# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## 已注册的 Hooks

### Doc-Lint Hook（PostToolUse）

- **脚本**：`~/.claude/scripts/doc-lint.sh`
- **触发**：每次 `Edit` 或 `Write` 工具执行后
- **作用**：检查代码变更是否有对应文档需要同步
- **检查项**：
  - 被修改模块是否在 `CLAUDE.md` 中有记录
  - 同目录 `README.md` 是否超过 30 天未更新
  - `STACK.md` 是否超过 14 天未更新
- **行为**：只提醒注入 agent context，不阻塞操作
- **理念**：机械化强制 "禁止孤立变更" 法则

```json
"PostToolUse": [
  {
    "matcher": "Edit|Write",
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/scripts/doc-lint.sh"
      }
    ]
  }
]
```

### 配套 Skill：Doc Gardening

- **路径**：`~/.claude/skills/doc-gardening/SKILL.md`
- **调用**：`/doc-gardening` 单次 或 `/loop 30m /doc-gardening` 定期巡检
- **作用**：深度扫描项目文档与代码结构一致性
- **检查项**：幽灵文档、隐形模块、陈旧文档、依赖漂移

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
