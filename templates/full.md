# {project_name}
{one_line_description}

<directory>
{auto_detected_directory_structure}
</directory>

## 技术栈
{auto_detected_stack}

## 项目概述
{ai_generated_overview}

## 目标
- {goal_1}
- {goal_2}

## 非目标
- {non_goal_1}

## 成功标准
- {criterion_1}
- {criterion_2}

---

## 文档同步协议

本项目启用分形文档同步。Claude 修改代码时必须执行 GEB Loop：

**只对 Claude 本次修改的文件生效，不追溯改造已有代码。**

### 三层结构

| 层级 | 位置 | 触发更新 |
|------|------|----------|
| L1 | 本文件 (CLAUDE.md) | 模块增删 / 架构变更 |
| L2 | `{module}/CLAUDE.md` | 文件增删 / 接口变更 |
| L3 | 文件头部注释 `[INPUT]/[OUTPUT]/[POS]` | 依赖变更 / 导出变更 |

### GEB Loop（代码变更后）

```
修改完成 → L3 头部与实际一致？ → L2 成员清单更新？ → L1 目录更新？
```

### 规则
- 新建文件：必须添加 L3 头部
- 新建目录：必须创建 L2 CLAUDE.md
- 删除文件：必须更新 L2 成员清单
- **已有文件（Claude 未修改的）：不动**

---

## 设计哲学

- 能消失的分支永远比能写对的分支更优雅
- 三个以上分支立即停止重构，通过设计让特殊情况消失
- 先写最简单能运行的实现，再考虑扩展
- 认知跃迁：How to fix → Why it breaks → How to design it right

---

## Workflow 六层结构

本项目启用 workflow 回写闭环。详见 `workflow/` 目录。

### 阶段路由

| 条件 | 路由 |
|------|------|
| 目标不清楚 | → workflow/03-design |
| design 已有，缺验证 | → workflow/04-testing |
| design + testing 已清楚 | → workflow/05-execution |
| 需要补充背景知识 | → workflow/06-knowledge |

### 回写闭环

execution 不是终点。执行结果回写到：
- `02-session` — 记录本轮过程
- `04-testing` — 回写测试结果与证据
- `06-knowledge` — 回写稳定结论
- `01-rule` — 出现新治理原则时回写
