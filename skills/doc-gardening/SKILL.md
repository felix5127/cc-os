---
name: doc-gardening
description: 扫描项目文档与代码结构的一致性，发现过时文档并生成修复建议。可配合 /loop 定期运行。
---

# Doc Gardening — CC-Kit 文档花园维护

## 触发条件
- 手动调用 `/doc-gardening`
- 配合 `/loop 30m /doc-gardening` 定期运行
- 项目大版本变更后

## 执行流程

### Step 1: 定位项目根目录
读取当前工作目录的 git root，确认项目边界。

### Step 2: 扫描文档清单
检查以下文档是否存在且非空：
- `CLAUDE.md` (L1) — 项目级指令
- `STACK.md` — 技术栈声明
- `ARCHITECTURE.md` — 架构概览
- `docs/` 目录下的文档

### Step 3: 代码结构 vs 文档对比
1. 用 Glob 扫描项目顶层目录结构（`*/`）
2. 用 Glob 扫描 `src/` 或 `packages/` 下的模块目录
3. 对比 CLAUDE.md 中记录的目录/模块列表
4. 找出：
   - **幽灵文档**：文档中提到但代码中不存在的模块
   - **隐形模块**：代码中存在但文档中未提及的模块
   - **陈旧文档**：超过 30 天未更新的文档文件

### Step 4: 依赖一致性检查
1. 读取 `package.json` / `pyproject.toml` / `go.mod` 的实际依赖
2. 对比 `STACK.md` 中声明的技术栈
3. 找出未记录的新依赖或已移除但仍在文档中的旧依赖

### Step 5: 生成报告
输出格式：

```
📋 Doc Gardening 报告 — {project_name}
──────────────────────────────────────

✅ 健康项：
  - CLAUDE.md 存在且最近更新
  - ...

⚠️ 需要关注：
  - [幽灵文档] CLAUDE.md 提到 `packages/auth` 但目录不存在
  - [隐形模块] `src/utils/` 未在任何文档中记录
  - [陈旧] STACK.md 已 45 天未更新
  - [依赖漂移] package.json 中有 `zod` 但 STACK.md 未提及

🔧 建议操作：
  1. 从 CLAUDE.md 移除 `packages/auth` 引用
  2. 在 CLAUDE.md 中添加 `src/utils/` 模块描述
  3. 更新 STACK.md 的依赖列表
```

### Step 6: 可选自动修复
如果用户确认，直接执行建议的修复操作（编辑文档文件）。

## 注意事项
- 只读操作为主，修改需用户确认
- 不扫描 node_modules、dist、build、.git 等目录
- 报告应简洁，只列有问题的项
- 遵循 CC-Kit 法则："禁止孤立变更"
