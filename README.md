# CC-GEB — Claude Code 配置工具包

> 让 Claude Code 在任何项目里都更好用。
>
> 闲聊不碍事，小项目轻量，大项目完整。

---

## 安装

```bash
git clone https://github.com/felix5127/cc-geb.git
cd cc-geb && chmod +x install.sh && ./install.sh
```

## 使用

```bash
cd your-project && claude
```

然后：

```
/cc-geb              自动检测项目状态，推荐下一步
/cc-geb init         初始化项目配置（轻量/标准/完整）
/cc-geb check        文档与代码一致性巡检
/cc-geb upgrade      升级配置级别
```

或者直接说"帮我初始化项目"、"检查一下文档"。

## 三档配置

| 级别 | 生成内容 | 适用场景 |
|------|---------|---------|
| **轻量** | CLAUDE.md（项目描述） | 开源项目、小脚本、快速修 bug |
| **标准** | + STACK.md + GEB 文档同步 | 中型项目、持续迭代 |
| **完整** | + workflow/ 六层 + 回写闭环 | 大型产品、长期维护 |

**已有 CLAUDE.md？** 不动它。只问你要不要补充 STACK.md 或 workflow/。

## 设计原则

- **全局极简**：只有语言偏好 + 编码风格，闲聊无感知
- **项目按需**：`/cc-geb init` 交互式生成，不强制
- **只做加法**：从不修改已有的 CLAUDE.md
- **渐进采用**：轻量起步，随时 `/cc-geb upgrade`

## 仓库结构

```
cc-geb/
├── install.sh               # 全局安装 → ~/.claude/
├── CLAUDE.md                 # 全局配置（~15 行）
├── rules/                    # 全局规则
│   ├── coding-style.md       #   不可变性 + 文件组织
│   ├── git-workflow.md       #   Commit 格式
│   └── performance.md        #   模型选择
├── templates/                # 项目模板（/cc-geb init 选用）
│   ├── light.md              #   轻量级
│   ├── standard.md           #   标准级（含 GEB 文档同步）
│   ├── full.md               #   完整级（含 workflow + 设计哲学）
│   ├── stack.md              #   技术栈
│   └── workflow-bootstrap.md #   六层 workflow 定义
├── skills/
│   └── cc-geb/SKILL.md       # /cc-geb — 唯一 Skill，三个子命令
└── scripts/
    ├── doc-lint.sh           # Hook: 代码变更后提醒文档同步
    └── session-lesson.sh     # Hook: 会话结束提取教训
```

## 许可

MIT

---

> 架构即认知，文档即记忆。
