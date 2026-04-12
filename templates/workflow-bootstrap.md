# Workflow Bootstrap

> /cc-init 完整模式专用。定义 workflow/ 六层目录的生成规则和运行协议。

## 六层定义

| 层 | 目录 | 职责 | 关键词 |
|----|------|------|--------|
| 0 | 00-overview | 项目索引与全局导航 | registry |
| 1 | 01-rule | 定义 workflow 如何运行 | 元规则 |
| 2 | 02-session | 记录人和 AI 的协作历史 | 记忆沉淀 |
| 3 | 03-design | 定义产品目标、版本规划、系统结构 | 版本设计 |
| 4 | 04-testing | 定义验证方式和反馈闭环 | 验证闭环 |
| 5 | 05-execution | 定义本轮正式落地计划 | 约束执行 |
| 6 | 06-knowledge | 沉淀稳定的技术结论和项目背景 | 知识库 |

## 阶段路由

| 条件 | 下一步 |
|------|--------|
| 目标不清楚 | → 03-design |
| design 已有，缺验证 | → 04-testing |
| design + testing 已清楚 | → 05-execution |
| 需要补充背景知识 | → 06-knowledge |

## 回写闭环

execution 完成后，结果必须回写：

```
执行产出（结果、日志、失败证据）
  ├── → 02-session    记录本轮过程
  ├── → 04-testing    回写测试结果
  ├── → 06-knowledge  回写稳定结论
  ├── → 01-rule       出现新治理原则时回写
  └── → 判断是否影响 design / execution → 回到对应层修正
```
