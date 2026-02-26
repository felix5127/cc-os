# CC-OS — Claude Code 工程操作系统

> 一套用于约束 AI 编程行为的工程操作系统。
>
> **认知一致性 · 消除架构失忆 · 代码-文档-Agent 三者同构**

---

## 这是什么？

CC-OS 是一套 Claude Code 全局配置体系，包含：

- **L0 宪法** (`CLAUDE.md`) — 全局行为约束与分形文档协议
- **Rules** (6 个规则文件) — 编码风格、安全、性能、Git 工作流等具体规范
- **Templates** (5 个模板) — 新项目播种文件，含 Agent Team Recipes
- **Settings** — 插件启用、权限配置、Agent Teams 环境变量
- **48+ Skills** — 通过 6 个插件源自动安装

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/felix5127/cc-os.git
cd cc-os

# 2. 运行安装脚本
chmod +x install.sh
./install.sh
```

或者参考 [CC-OS-安装手册.md](./CC-OS-安装手册.md) 进行手动安装。

## 仓库结构

```
cc-os/
├── README.md              # 本文件
├── CC-OS-安装手册.md        # 完整安装手册
├── install.sh             # 一键安装脚本
├── CLAUDE.md              # L0 全局宪法（复制到 ~/.claude/）
├── settings.json          # 全局设置（复制到 ~/.claude/）
├── rules/                 # 规则文件（复制到 ~/.claude/rules/）
│   ├── agents.md          # Agent 编排策略
│   ├── coding-style.md    # 编码风格规范
│   ├── git-workflow.md    # Git 工作流
│   ├── hooks.md           # Hooks 使用规范
│   ├── performance.md     # 性能 & 模型选择
│   └── security.md        # 安全检查清单
└── templates/             # 项目模板（复制到 ~/.claude/templates/）
    ├── claude.md          # 项目 L1 宪法模板
    ├── stack.md           # 技术栈模板
    ├── siklls.md          # Skill 路由模板
    ├── mcp.md             # MCP Profile 模板
    └── start.md           # 启动路径模板
```

## 核心理念

```
┌─────────────────────────────────────────┐
│  L0 · ~/.claude/CLAUDE.md               │  全局宪法
│  ┌──────────────────────────────────┐   │
│  │  L1 · <项目>/CLAUDE.md           │   │  项目级
│  │  ┌───────────────────────────┐   │   │
│  │  │  L2 · 模块/目录级文档      │   │   │  模块级
│  │  │  ┌────────────────────┐   │   │   │
│  │  │  │  L3 · 文件/函数注释  │   │   │   │  代码级
│  │  │  └────────────────────┘   │   │   │
│  │  └───────────────────────────┘   │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**四条不可违反的法则：**

1. **Map = Terrain** — 代码与文档必须同构
2. **分形一致性** — L0→L1→L2→L3 变更必须同步
3. **禁止孤立变更** — 改代码必须改文档
4. **AI 受宪法约束** — 项目 CLAUDE.md > 全局 CLAUDE.md > 模型默认行为

## 插件依赖

| 插件 | 来源 | 能力 |
|------|------|------|
| Superpowers | `obra/superpowers-marketplace` | TDD、调试、计划、代码审查 |
| Everything Claude Code | `affaan-m/everything-claude-code` | 架构、安全、数据库、前端 |
| Planning with Files | `OthmanAdi/planning-with-files` | 文件化计划系统 |
| Claude HUD | `jarrodwatts/claude-hud` | 状态栏显示 |
| Code Simplifier | `anthropics/claude-plugins-official` | 代码简化 |
| Ralph Wiggum | `anthropics/claude-code` | 趣味插件 |

## 许可

MIT

---

> 架构即认知，文档即记忆。系统是否可靠，取决于它是否记得自己是谁。
