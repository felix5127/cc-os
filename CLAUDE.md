# CC-OS — Claude Code 工程操作系统
Claude Code + 分形文档协议 + 认知驱动工程

<position>
L0 · 全局宪法（Global Constitution）
本文件是 CC-OS 的最高层级，定义整体结构、核心法则与分形约束。
L0 跨所有项目生效，项目级 L1 (CLAUDE.md) 可覆盖但不可违反 L0 法则。
</position>

<mission>
CC-OS 是一套用于"约束 AI 编程行为"的工程操作系统。
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
- skills-repo/ — Skills 仓库缓存
- telemetry/ — 运行遥测（非逻辑源）
- todos/ — Claude Code 内部状态
- shell-snapshots/ — Shell 执行快照
</directory>

---

## <config>
L0 核心文档清单（全局有效）
</config>

- CLAUDE.md
  → 本文件。系统宪法、全局地图、架构最高真源

- DOC_PROTOCOL.md
  → 分形文档协议，定义 L1/L2/L3 的同构约束与强制回环

- PHILOSOPHY.md
  → 设计哲学与品味判断，用于架构级决策的价值函数

- templates/CLAUDE.md
  → **项目级 L1 模板**，cc-init 复制到项目根目录后成为该项目的 L1

- templates/STACK.md
  → 项目技术栈与工程约束（项目级事实源）

- templates/SKILLS.md
  → 任务类型 → Skill 路由规则

- templates/MCP.md
  → MCP 启用策略与最小化原则

- templates/START.md
  → 新任务 / 恢复任务的启动路径

---

## <law>
全局法则（不可违反）
</law>

1. **Map = Terrain**
   - 代码是机器相
   - 文档是语义相
   - 两者必须同构

2. **分形一致性**
   - L0 是全局约束（本文件）
   - L1 是 L2 的折叠（项目 CLAUDE.md）
   - L2 是 L3 的折叠（模块/文件级）
   - 任一层变更，必须向上/向下同步

3. **禁止孤立变更**
   - 改代码不改文档 → 架构破坏
   - 改文档不对应代码 → 语义欺骗

4. **AI 受宪法约束**
   - Claude Code 在任何项目中：
     - 项目根目录 CLAUDE.md > 本文件
     - 本文件 > 模型默认行为

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
6. 严格执行 DOC_PROTOCOL.md 的回环约束

## <boundary>
边界声明
</boundary>

- 本仓库 **不是业务代码仓库**
- `/init` 不应在此目录运行
- cc-init 仅用于向真实项目播种模板
- 本文件不描述"如何修 Bug"，只描述"系统如何存在"

<axiom>
架构即认知，文档即记忆。
系统是否可靠，取决于它是否记得自己是谁。
</axiom>

思考语言：技术流英文
交互语言：中文
注释规范：中文 + ASCII 风格分块注释,使代码看起来像高度优化的顶级开源库作品
核心信念：代码是写给人看的,只是顺便让机器运行