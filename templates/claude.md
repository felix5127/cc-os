# {Project Name} - {One Line Description}
{Tech Stack Tags}

> ⚠️ **GEB FRACTAL SYSTEM ENFORCED**
> This project follows the Fractal Documentation System defined in `~/.claude/DOC_PROTOCOL.md`.
> **Rule:** Code and Docs are isomorphic. Update L3 headers, L2 maps, and L1 constitution strictly.

<directory>
src/           - Source Code
docs/          - Documentation & Knowledge Base
tests/         - Test Suites
.claude/       - Project-specific Agent Memory
</directory>

<config>
CLAUDE.md         - Project Constitution (L1)
~/.claude/DOC_PROTOCOL.md - The Fractal System Law (global)
STACK.md          - Tech Stack & Engineering Constraints
SKILLS.md         - Project Specific Skills
MCP.md            - Project Specific MCP Tools
</config>

<mission>
## Overview（项目概述）

> {2-3 句话：这个项目是什么、解决什么问题、面向谁}

## Goals（目标）

> - {Goal 1}
> - {Goal 2}
> - {Goal 3}

## Non-Goals（非目标）

> - {Anti-Goal 1}
> - {Anti-Goal 2}

## Success Criteria（成功标准）

> - {Criterion 1}
> - {Criterion 2}
</mission>

# Claude Working Rules

## Clarification First
Before implementing anything, always start by clarifying the task.
Assume requirements are incomplete unless explicitly confirmed.

## Ask-User-Questions
Proactively ask questions before writing code.
- Ask in rounds, max 3 questions per round.
- Prefer questions that affect goals, constraints, edge cases, or architecture.
- Explicitly state any assumptions.

## Plan Before Execute
Once the task is clear, produce a concise execution plan.
- Break work into steps.
- Identify risks and dependencies.
- Suggest parallelization when appropriate.

## Execution & Verification
- **Strict GEB Loop:** Code Change → L3 Update → L2 Update → L1 Update.
- Prefer small, incremental changes.
- Use TDD for core logic when suitable.
- Verify against goals and acceptance criteria.

## Auto-Context Loading
(System will automatically check these files based on <config>)
- **STACK.md**: Read for constraints before planning.
- **SKILLS.md**: Check for reusable patterns.
- **MCP.md**: Enable required tools.
- **~/.claude/DOC_PROTOCOL.md**: Consult before any architectural change.

## Role
Act as a senior engineer and thinking partner.
If requirements are unclear, prefer asking questions over guessing.
**Silent guessing is a failure.**

---

# Agent Team Recipes

> 以下 Recipe 供 Agent Team Lead 读取，用于理解如何组建和协调团队。
> 使用方式：告诉 Claude "按照 {Recipe 名} 创建 agent team 来 {任务描述}"

## Recipe: Full Pipeline（完整流水线）

### 触发场景
新 feature 开发、重大重构、技术方案落地

### 团队结构

| 角色 | 模型 | 权限 | 职责 |
|------|------|------|------|
| Lead | 默认 | delegate mode（纯协调，不写代码） | 拆任务、审批方案、控制修复轮、汇总结果 |
| Researcher | Opus | 只读 | 调研代码/文档/依赖，产出 findings.md |
| Architect | Opus | 只读 + 写设计文档 | 设计方案，产出 design.md，需 Lead 审批（plan approval） |
| Developer | Sonnet | 读写代码 | 按设计实现，写测试，遇歧义 message Architect |
| Reviewer | Opus | 只读 + 写报告 | 审查实现，按 CRITICAL/HIGH/MEDIUM 分级 |

### 工作流

```
1. Lead 拆解任务，创建 task list（含依赖关系）
2. Lead spawn Researcher (Opus) + Architect (Opus)
   → Researcher 调研，产出 docs/research/findings.md
   → Architect 可提前熟悉代码，但不产出设计直到 Research 完成
3. Research 完成 → Architect 读取 findings.md 设计方案
   → 如有遗漏，message Researcher 补充
   → 产出 docs/architecture/design.md，提交 Lead 审批
4. Lead 审批通过 → spawn Developer (Sonnet)
   → Developer 按设计实现，遇歧义 message Architect
   → 代码 + 测试完成
5. Lead spawn Reviewer (Opus)
   → Reviewer 对照 design.md 审查实现
   → 产出 docs/review/report.md（CRITICAL/HIGH/MEDIUM）
6. Lead 审阅报告
   → 有 CRITICAL → Lead 指派 Developer 修复 → Reviewer 再审
   → 无 CRITICAL → 流程结束，Lead 汇总
```

### 产出规范
- Researcher → `docs/research/findings.md`（明确区分"已确认事实"和"未确认假设"）
- Architect → `docs/architecture/design.md`（模块边界、接口定义、数据流）
- Reviewer → `docs/review/report.md`（问题分级 + 修复建议）

### 通信规则
- Architect 发现调研不足 → message Researcher
- Developer 遇设计歧义 → message Architect
- Reviewer 发现架构级问题 → message Architect（不是 Developer）
- 所有人完成任务 → 自动通知 Lead

### 修复环路（Lead 控制）
1. Reviewer 产出报告
2. Lead 判断是否有 CRITICAL 级别问题
3. 有 → Lead 指派 Developer 修复 → Reviewer 再审
4. 无 → 流程结束

### 约束
- 每人只修改自己职责范围内的文件，禁止交叉编辑
- Developer 不得自行决定设计变更
- Reviewer 不得直接修改代码
- Researcher 产出必须区分事实与假设