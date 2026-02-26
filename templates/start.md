# Start Guide

> 本文件定义不同任务类型的启动路径。
> 复制到项目后，根据实际情况调整。

---

## New Project (新项目初始化)

**前置条件**: 项目目录已创建，但尚未有 CC-OS 文档结构

**步骤**:
1. 运行 `cc-init` 将模板播种到项目根目录
2. 编辑 `CLAUDE.md`：填写项目名称、技术栈、目录结构
3. 编辑 `STACK.md`：声明具体技术版本和工程约束
4. 开始开发，遵循 GEB 分形文档协议

**MCP Profile**: `minimal`

---

## Resume a Half-Done Project (恢复中断的项目)

**前置条件**: 项目已有部分代码，需要继续开发

**步骤**:
1. 阅读 `CLAUDE.md` 了解项目结构和当前状态
2. 检查 git log / TODO 注释 / Issue tracker 确定中断点
3. 评估当前状态，制定恢复计划
4. 从最小可验证的修复开始

**MCP Profile**: `minimal`

**推荐 Skills**: `subagent-driven-development`, `systematic-debugging`

---

## Debug / Build Broken (调试/构建失败)

**前置条件**: 代码无法编译或运行时崩溃

**步骤**:
1. 复现问题，收集错误信息
2. 定位根因（不是症状）
3. 最小化修复，避免引入新问题
4. 验证修复，确保不破坏其他功能

**MCP Profile**: `minimal`

**推荐 Skills**: `systematic-debugging`, `verification-before-completion`

---

## E2E / Integration Testing (端到端/集成测试)

**前置条件**: 需要验证跨模块或用户流程的正确性

**步骤**:
1. 明确测试范围和预期行为
2. 启用 e2e 相关工具
3. 运行测试，记录失败
4. 定位失败原因并修复

**MCP Profile**: `e2e`

---

## Research (技术调研)

**前置条件**: 需要查阅外部文档、API 或最佳实践

**步骤**:
1. 明确调研目标和问题边界
2. 启用 web-research profile
3. 汇总发现，提炼可行方案
4. 记录结论到项目文档

**MCP Profile**: `web-research`

---

## New Feature (新功能开发)

**前置条件**: 需求已明确，准备开始实现

**步骤**:
1. 澄清需求，提出问题
2. 制定实现计划
3. TDD：先写测试，再写实现
4. 代码审查，验证完成

**MCP Profile**: `minimal`

**推荐 Skills**: `writing-plans`, `test-driven-development`, `requesting-code-review`
