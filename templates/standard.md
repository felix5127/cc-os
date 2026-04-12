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
