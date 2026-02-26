# MCP Usage & Profiles

## How to Use Profiles

在任务开始时声明所需 profile，Claude 会据此启用/禁用 MCP 工具：

```
当前任务需要: PROFILE: web-research
```

或在项目 CLAUDE.md 中设置默认 profile：

```markdown
<mcp-profile>minimal</mcp-profile>
```

## Principles
- Enable only MCPs required for the current task
- Prefer minimal MCP usage to preserve context window
- Debug > Research > Optimization

## MCP Profiles

### PROFILE: minimal (default)
Enable:
- filesystem / project read
- build / test tooling

Disable:
- browser or external research

### PROFILE: web-research
Enable:
- browser / web search MCP

Rules:
- Summarize findings
- Avoid raw dumps

### PROFILE: e2e
Enable:
- playwright / e2e related MCP

Rules:
- Run smoke tests
- Report failures concisely

### PROFILE: security
Enable:
- security scanning tools (if available)

Rules:
- Focus on secrets, injection risks, dependencies
