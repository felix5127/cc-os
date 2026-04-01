# CC-Kit 安装手册

> **CC-Kit — Claude Code 工程操作系统**
> 版本：2026-02-26 · 作者：Felix
>
> 一套用于约束 AI 编程行为的工程操作系统。
> 目标：认知一致性 · 消除架构失忆 · 代码-文档-Agent 三者同构。

---

## 目录

- [前置条件](#前置条件)
- [快速安装（一键脚本）](#快速安装一键脚本)
- [手动安装（分步骤）](#手动安装分步骤)
  - [Step 1: 全局宪法 CLAUDE.md](#step-1-全局宪法-claudemd)
  - [Step 2: 规则文件 Rules](#step-2-规则文件-rules)
  - [Step 3: 项目模板 Templates](#step-3-项目模板-templates)
  - [Step 4: 全局设置 Settings](#step-4-全局设置-settings)
  - [Step 5: 安装插件 Plugins](#step-5-安装插件-plugins)
- [验证安装](#验证安装)
- [配置详解](#配置详解)
- [常见问题](#常见问题)

---

## 前置条件

| 依赖 | 最低版本 | 安装方式 |
|------|---------|---------|
| Claude Code CLI | 最新版 | `npm install -g @anthropic-ai/claude-code` |
| Bun (可选, 用于 HUD) | 1.0+ | `curl -fsSL https://bun.sh/install \| bash` |
| Git | 2.30+ | `brew install git` (macOS) |

确保 `~/.claude/` 目录存在：

```bash
mkdir -p ~/.claude/{rules,templates,skills}
```

---

## 快速安装（一键脚本）

将以下脚本保存为 `install-cc-kit.sh` 并执行：

```bash
#!/bin/bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║  CC-Kit Installer — Claude Code 工程操作系统    ║
# ╚══════════════════════════════════════════════╝

CLAUDE_DIR="$HOME/.claude"
REPO_URL="https://github.com/felix5127/cc-kit"

echo "━━━ CC-Kit 安装开始 ━━━"

# 0. 备份已有配置
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -r "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/" 2>/dev/null || true
  cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/" 2>/dev/null || true
  cp -r "$CLAUDE_DIR/templates" "$BACKUP_DIR/" 2>/dev/null || true
  cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/" 2>/dev/null || true
  echo "✓ 已备份到 $BACKUP_DIR"
fi

# 1. 创建目录结构
mkdir -p "$CLAUDE_DIR"/{rules,templates,skills}
echo "✓ 目录结构已创建"

# 2. 克隆配置仓库（如果使用 Git 仓库分发）
# git clone "$REPO_URL" /tmp/cc-kit-install
# cp -r /tmp/cc-kit-install/claude/* "$CLAUDE_DIR/"
# rm -rf /tmp/cc-kit-install

# 3. 安装插件（核心能力来源）
echo "━━━ 安装插件 ━━━"

claude /install-plugin superpowers@superpowers-marketplace
echo "✓ Superpowers 已安装"

claude /install-plugin everything-claude-code@everything-claude-code \
  --marketplace-repo affaan-m/everything-claude-code
echo "✓ Everything Claude Code 已安装"

claude /install-plugin planning-with-files@planning-with-files \
  --marketplace-repo OthmanAdi/planning-with-files
echo "✓ Planning with Files 已安装"

claude /install-plugin claude-hud@claude-hud \
  --marketplace-repo jarrodwatts/claude-hud
echo "✓ Claude HUD 已安装"

claude /install-plugin code-simplifier@claude-plugins-official
echo "✓ Code Simplifier 已安装"

claude /install-plugin ralph-wiggum@claude-code-plugins
echo "✓ Ralph Wiggum 已安装"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CC-Kit 安装完成！"
echo "  请继续手动复制以下文件："
echo "    - CLAUDE.md"
echo "    - rules/*.md (6 个文件)"
echo "    - templates/*.md (5 个文件)"
echo "    - settings.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

> **注意**: 插件安装命令的具体语法可能随 Claude Code 版本变化，请以官方文档为准。

---

## 手动安装（分步骤）

### Step 1: 全局宪法 CLAUDE.md

这是 CC-Kit 的**最高层级文件**（L0），定义全局行为约束。

```bash
# 复制到 ~/.claude/CLAUDE.md
```

<details>
<summary>📄 点击展开 CLAUDE.md 完整内容</summary>

```markdown
# CC-Kit — Claude Code 工程操作系统
Claude Code + 分形文档协议 + 认知驱动工程

<position>
L0 · 全局宪法（Global Constitution）
本文件是 CC-Kit 的最高层级，定义整体结构、核心法则与分形约束。
L0 跨所有项目生效，项目级 L1 (CLAUDE.md) 可覆盖但不可违反 L0 法则。
</position>

<mission>
CC-Kit 是一套用于"约束 AI 编程行为"的工程操作系统。
它的目标不是生成代码，而是：
- 保证认知一致性
- 消除架构失忆
- 让代码、文档、AI Agent 三者保持同构
</mission>

---

## <directory>
~/.claude/ — Claude Code 全局运行时根目录

- templates/ — 项目级模板母版（L1→L2 播种源）
- skills/ — 已安装的 Claude Skills
- telemetry/ — 运行遥测（非逻辑源）
- todos/ — Claude Code 内部状态
- shell-snapshots/ — Shell 执行快照
</directory>

---

## <config>
L0 核心文档清单（全局有效）
</config>

- CLAUDE.md → 本文件。系统宪法、全局地图、架构最高真源
- templates/CLAUDE.md → 项目级 L1 模板
- templates/STACK.md → 项目技术栈与工程约束
- templates/SKILLS.md → 任务类型 → Skill 路由规则
- templates/MCP.md → MCP 启用策略与最小化原则
- templates/START.md → 新任务 / 恢复任务的启动路径

---

## <law>
全局法则（不可违反）
</law>

1. **Map = Terrain**
   - 代码是机器相 / 文档是语义相 / 两者必须同构

2. **分形一致性**
   - L0 → L1 → L2 → L3，任一层变更必须向上/向下同步

3. **禁止孤立变更**
   - 改代码不改文档 → 架构破坏
   - 改文档不对应代码 → 语义欺骗

4. **AI 受宪法约束**
   - 项目根目录 CLAUDE.md > 本文件 > 模型默认行为

---

## <workflow>
全局工作流（抽象级）
</workflow>

进入任意项目时：
1. 读取项目根目录 CLAUDE.md（项目 L1）
2. 若不存在 → 使用 templates/CLAUDE.md 播种
3. 读取 STACK.md 作为事实约束
4. 按 SKILLS.md 选择行为模式
5. 按 MCP.md 启用最小必要工具

---

思考语言：技术流英文
交互语言：中文
注释规范：中文 + ASCII 风格分块注释
核心信念：代码是写给人看的,只是顺便让机器运行
```

</details>

**自定义要点**：
- `交互语言` — 改为你的偏好语言
- `<workflow>` 第 7 条 — 截图路径改为你自己的路径
- 可根据需要添加项目特定的工作偏好

---

### Step 2: 规则文件 Rules

6 个规则文件放置在 `~/.claude/rules/` 下：

```
~/.claude/rules/
├── agents.md          # Agent 编排策略
├── coding-style.md    # 编码风格（不可变性、文件组织、错误处理）
├── git-workflow.md    # Git 提交和 PR 工作流
├── hooks.md           # Hooks 系统使用规范
├── performance.md     # 模型选择 & 性能优化策略
└── security.md        # 安全检查清单
```

<details>
<summary>📄 agents.md — Agent 编排</summary>

```markdown
# Agent Orchestration

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |

## Immediate Agent Usage (no user prompt needed)
1. Complex feature → planner agent
2. Code written/modified → code-reviewer agent
3. Bug fix / new feature → tdd-guide agent
4. Architectural decision → architect agent

## Parallel Task Execution
ALWAYS use parallel Task execution for independent operations.

## Multi-Perspective Analysis
For complex problems, use split role sub-agents:
- Factual reviewer / Senior engineer / Security expert
```

</details>

<details>
<summary>📄 coding-style.md — 编码风格</summary>

```markdown
# Coding Style

## Immutability (CRITICAL)
ALWAYS create new objects, NEVER mutate existing ones.

## File Organization
MANY SMALL FILES > FEW LARGE FILES:
- 200-400 lines typical, 800 max
- Organize by feature/domain, not by type

## Error Handling
- Handle errors explicitly at every level
- User-friendly messages in UI, detailed logs on server
- Never silently swallow errors

## Input Validation
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages

## Code Quality Checklist
- [ ] Readable, well-named
- [ ] Functions <50 lines, Files <800 lines
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns)
```

</details>

<details>
<summary>📄 git-workflow.md — Git 工作流</summary>

```markdown
# Git Workflow

## Commit Message Format
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci

## Pull Request Workflow
1. Analyze full commit history (not just latest)
2. Use git diff [base-branch]...HEAD
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with -u flag if new branch
```

</details>

<details>
<summary>📄 hooks.md — Hooks 规范</summary>

```markdown
# Hooks System

## Hook Types
- PreToolUse: Before tool execution
- PostToolUse: After tool execution
- Stop: When session ends

## TodoWrite Best Practices
Use TodoWrite to track progress, verify understanding,
enable real-time steering, show granular steps.
```

</details>

<details>
<summary>📄 performance.md — 性能优化</summary>

```markdown
# Performance Optimization

## Model Selection Strategy
- Haiku 4.5: Lightweight agents, pair programming, worker agents
- Sonnet 4.6: Main dev work, orchestration, complex coding
- Opus 4.5: Complex architecture, deep reasoning, research

## Context Window Management
Avoid last 20% for large refactoring / multi-file features.

## Extended Thinking + Plan Mode
Enabled by default (31,999 tokens).
Toggle: Option+T (macOS) / Alt+T (Windows/Linux)
```

</details>

<details>
<summary>📄 security.md — 安全检查</summary>

```markdown
# Security Guidelines

## Before ANY commit:
- [ ] No hardcoded secrets
- [ ] All user inputs validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Auth/authz verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

## If security issue found:
1. STOP immediately
2. Use security-reviewer agent
3. Fix CRITICAL before continuing
4. Rotate exposed secrets
5. Review entire codebase for similar issues
```

</details>

---

### Step 3: 项目模板 Templates

5 个模板文件放置在 `~/.claude/templates/` 下。新项目时用于"播种"：

```
~/.claude/templates/
├── claude.md     # 项目 L1 宪法模板（含 Agent Team Recipes）
├── stack.md      # 技术栈约束模板
├── siklls.md     # Skill 路由规则模板
├── mcp.md        # MCP Profile 模板
└── start.md      # 任务启动路径模板
```

> **使用方式**: 新建项目时，将这些模板复制到项目根目录，填写 `{占位符}` 即可。

<details>
<summary>📄 claude.md — 项目宪法模板（含 Agent Team Recipes）</summary>

```markdown
# {Project Name} - {One Line Description}
{Tech Stack Tags}

> ⚠️ **GEB FRACTAL SYSTEM ENFORCED**

<directory>
src/           - Source Code
docs/          - Documentation & Knowledge Base
tests/         - Test Suites
.claude/       - Project-specific Agent Memory
</directory>

<mission>
## Overview（项目概述）
> {2-3 句话：这个项目是什么、解决什么问题、面向谁}

## Goals（目标）
> - {Goal 1}
> - {Goal 2}

## Non-Goals（非目标）
> - {Anti-Goal 1}
</mission>

# Claude Working Rules
- Clarification First — 先澄清再动手
- Ask-User-Questions — 主动提问，每轮最多 3 个
- Plan Before Execute — 先计划再执行
- Strict GEB Loop: Code → L3 → L2 → L1

# Agent Team Recipes

## Recipe: Full Pipeline（完整流水线）
| 角色 | 模型 | 职责 |
|------|------|------|
| Lead | 默认 | 拆任务、审批方案、控制修复轮 |
| Researcher | Opus | 调研代码/文档/依赖 |
| Architect | Opus | 设计方案，需 Lead 审批 |
| Developer | Sonnet | 按设计实现，写测试 |
| Reviewer | Opus | 审查实现，分级报告 |
```

</details>

<details>
<summary>📄 stack.md — 技术栈模板</summary>

```markdown
# Stack & Engineering Constraints

## Core Stack
- Language / Runtime:
- Framework:
- Build Tool:
- Test Framework:
- Lint / Format:

## Engineering Rules
- Prefer minimal, incremental changes
- Do not introduce new features unless explicitly requested
- Do not hardcode secrets or environment-specific values

## Definition of Done
- Build passes / Tests pass / Core flows validated
```

</details>

<details>
<summary>📄 siklls.md — Skill 路由模板</summary>

```markdown
# Skills Routing

## Default
Use: planning-with-files, executing-plans, verification-before-completion

## Resume / Half-Done Project
Use: subagent-driven-development, systematic-debugging

## New Feature
Use: writing-plans, test-driven-development, requesting-code-review

## Debug / Build Broken
Use: systematic-debugging, verification-before-completion

## Frontend / Next.js
Use: vercel-react-best-practices, web-design-guidelines
```

</details>

<details>
<summary>📄 mcp.md — MCP Profile 模板</summary>

```markdown
# MCP Usage & Profiles

## Principles
- Enable only MCPs required for the current task
- Prefer minimal usage to preserve context window

## Profiles
- minimal (default): filesystem + build/test
- web-research: browser + web search
- e2e: playwright + e2e tools
- security: security scanning tools
```

</details>

<details>
<summary>📄 start.md — 启动路径模板</summary>

```markdown
# Start Guide

## New Project — cc-init 播种 → 编辑 CLAUDE.md → 编辑 STACK.md → 开发
## Resume — 读 CLAUDE.md → 检查 git log → 评估状态 → 最小修复
## Debug — 复现 → 定位根因 → 最小修复 → 验证
## New Feature — 澄清 → 计划 → TDD → 代码审查
## Research — 明确目标 → web-research profile → 汇总 → 记录
```

</details>

---

### Step 4: 全局设置 Settings

编辑 `~/.claude/settings.json`：

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [],
    "defaultMode": "bypassPermissions"
  },
  "enabledPlugins": {
    "code-simplifier@claude-plugins-official": true,
    "planning-with-files@planning-with-files": true,
    "ralph-wiggum@claude-code-plugins": true,
    "superpowers@superpowers-marketplace": true,
    "claude-hud@claude-hud": true,
    "everything-claude-code@everything-claude-code": true
  },
  "extraKnownMarketplaces": {
    "everything-claude-code": {
      "source": {
        "source": "github",
        "repo": "affaan-m/everything-claude-code"
      }
    }
  },
  "autoUpdatesChannel": "latest",
  "skipDangerousModePermissionPrompt": true
}
```

> ⚠️ **安全提醒**：
> - `defaultMode: "bypassPermissions"` 会跳过所有权限确认，**仅建议高级用户使用**
> - 新手建议改为 `"default"` 并逐步添加 `allow` 白名单
> - `skipDangerousModePermissionPrompt` 同理，按需开启

（可选）编辑 `~/.claude/settings.local.json` 设置输出风格：

```json
{
  "permissions": {
    "allow": [
      "Bash(git clone:*)",
      "Bash(claude /plugin)"
    ]
  },
  "outputStyle": "Explanatory"
}
```

---

### Step 5: 安装插件 Plugins

CC-Kit 的 Skills 能力来自以下 **6 个插件源**：

| 插件 | 来源仓库 | 提供的能力 |
|------|---------|-----------|
| **Superpowers** | `obra/superpowers-marketplace` | 核心工作流：TDD、调试、计划、代码审查、Git 工作流 |
| **Everything Claude Code** | `affaan-m/everything-claude-code` | 全栈能力：架构、安全、数据库、前端、持续学习 |
| **Planning with Files** | `OthmanAdi/planning-with-files` | Manus 风格文件化计划系统 |
| **Claude HUD** | `jarrodwatts/claude-hud` | 状态栏 HUD 显示 |
| **Code Simplifier** | `anthropics/claude-plugins-official` | 代码简化（Anthropic 官方） |
| **Ralph Wiggum** | `anthropics/claude-code` | 趣味插件 |

安装命令（在 Claude Code 中执行）：

```bash
# 方式 1: 在 Claude Code 对话中使用 slash 命令
/install-plugin superpowers@superpowers-marketplace
/install-plugin everything-claude-code@everything-claude-code
/install-plugin planning-with-files@planning-with-files
/install-plugin claude-hud@claude-hud
/install-plugin code-simplifier@claude-plugins-official
/install-plugin ralph-wiggum@claude-code-plugins

# 方式 2: 添加第三方 marketplace（如果命令报找不到插件）
# 先添加 marketplace 源：
/add-marketplace everything-claude-code --repo affaan-m/everything-claude-code
/add-marketplace planning-with-files --repo OthmanAdi/planning-with-files
/add-marketplace claude-hud --repo jarrodwatts/claude-hud
/add-marketplace superpowers-marketplace --repo obra/superpowers-marketplace

# 然后再安装插件
```

---

## 验证安装

安装完成后，在 Claude Code 中依次验证：

### 1. 检查文件结构

```bash
# 在终端中运行
echo "=== CLAUDE.md ===" && [ -f ~/.claude/CLAUDE.md ] && echo "✓" || echo "✗ 缺失"
echo "=== Rules ===" && ls ~/.claude/rules/*.md 2>/dev/null | wc -l | xargs -I{} echo "{} 个规则文件"
echo "=== Templates ===" && ls ~/.claude/templates/*.md 2>/dev/null | wc -l | xargs -I{} echo "{} 个模板文件"
echo "=== Settings ===" && [ -f ~/.claude/settings.json ] && echo "✓" || echo "✗ 缺失"
echo "=== Skills ===" && ls ~/.claude/skills/ 2>/dev/null | wc -l | xargs -I{} echo "{} 个 Skills"
```

期望输出：
```
=== CLAUDE.md ===
✓
=== Rules ===
6 个规则文件
=== Templates ===
5 个模板文件
=== Settings ===
✓
=== Skills ===
48 个 Skills（数量因插件版本而异）
```

### 2. 在 Claude Code 中测试

启动 Claude Code 后，试着说：

```
请帮我检查当前 CC-Kit 配置状态
```

Claude 应该能识别并读取 CLAUDE.md 中的 CC-Kit 配置。

### 3. 测试 Agent Team

```
按照 Full Pipeline Recipe 创建 agent team 来分析当前目录结构
```

---

## 配置详解

### 架构层级

```
┌─────────────────────────────────────────┐
│  L0 · ~/.claude/CLAUDE.md               │  ← 全局宪法（你正在安装的）
│  ┌──────────────────────────────────┐   │
│  │  L1 · <项目>/CLAUDE.md           │   │  ← 项目级（从 templates/ 播种）
│  │  ┌───────────────────────────┐   │   │
│  │  │  L2 · 模块/目录级文档      │   │   │  ← 模块级
│  │  │  ┌────────────────────┐   │   │   │
│  │  │  │  L3 · 文件/函数注释  │   │   │   │  ← 代码级
│  │  │  └────────────────────┘   │   │   │
│  │  └───────────────────────────┘   │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 核心 Skills 能力矩阵

| 类别 | Skills | 来源插件 |
|------|--------|---------|
| **工作流** | brainstorming, writing-plans, executing-plans, verification-before-completion | Superpowers |
| **开发** | test-driven-development, systematic-debugging, finishing-a-development-branch | Superpowers |
| **审查** | requesting-code-review, receiving-code-review | Superpowers |
| **架构** | architect, planner, security-review | Everything CC |
| **前端** | frontend-design, shadcn-ui, vercel-react-best-practices, ui-ux-pro-max | Mixed |
| **文档** | doc-coauthoring, document-summarizer, pdf, docx, pptx, xlsx | Mixed |
| **多媒体** | canvas-design, algorithmic-art, slack-gif-creator, web-artifacts-builder | Mixed |
| **团队** | agent-teams-playbook, dispatching-parallel-agents, subagent-driven-development | Mixed |

### 模型路由策略

```
用户请求
   │
   ├─ 简单任务（单文件改动、文档、轻量调试）
   │     └→ Haiku 4.5 （最低成本）
   │
   ├─ 日常开发（编码、测试、多文件变更）
   │     └→ Sonnet 4.6 （最佳编码模型）
   │
   └─ 复杂推理（架构设计、深度分析）
         └→ Opus 4.5 （最深推理）
```

---

## 常见问题

### Q: 插件安装报错 "marketplace not found"
**A**: 先手动添加 marketplace 源：
```
/add-marketplace <marketplace-name> --repo <github-user/repo>
```

### Q: settings.json 中的 bypassPermissions 是否安全？
**A**: 这会跳过所有工具执行的权限确认。如果你不确定，请使用 `"default"` 模式，并通过 `allow` 数组逐个放行：
```json
{
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git *)"
    ]
  }
}
```

### Q: Agent Teams 功能不可用？
**A**: 确保 settings.json 中有：
```json
"env": {
  "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
}
```

### Q: 如何在新项目中启用 CC-Kit？
**A**: 三步：
1. 将 `~/.claude/templates/claude.md` 复制为项目根目录的 `CLAUDE.md`
2. 填写 `{占位符}` 部分
3. 同样复制并填写 `STACK.md`、`SKILLS.md` 等

### Q: 如何更新已安装的 Skills？
**A**: 在 Claude Code 中使用：
```
/skills-updater
```

### Q: outputStyle 有哪些选项？
**A**: 常用选项：
- `"Explanatory"` — 教育型，附带 Insight 解释
- `"Concise"` — 简洁型
- `"Verbose"` — 详细型
- 不设置则使用默认风格

---

## 文件清单速查

```
~/.claude/
├── CLAUDE.md                    # L0 全局宪法
├── settings.json                # 全局设置（插件、权限、环境变量）
├── settings.local.json          # 本地覆盖设置（输出风格等）
├── rules/
│   ├── agents.md                # Agent 编排策略
│   ├── coding-style.md          # 编码风格规范
│   ├── git-workflow.md          # Git 工作流
│   ├── hooks.md                 # Hooks 使用规范
│   ├── performance.md           # 性能 & 模型选择
│   └── security.md              # 安全检查清单
├── templates/
│   ├── claude.md                # 项目宪法模板
│   ├── stack.md                 # 技术栈模板
│   ├── siklls.md                # Skill 路由模板
│   ├── mcp.md                   # MCP Profile 模板
│   └── start.md                 # 启动路径模板
├── skills/                      # 由插件自动安装的 48+ Skills
└── plugins/                     # 插件缓存与注册表
    ├── installed_plugins.json
    └── known_marketplaces.json
```

---

> **CC-Kit 哲学**: 架构即认知，文档即记忆。系统是否可靠，取决于它是否记得自己是谁。
