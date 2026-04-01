# CC-Kit 三大自动化特性 — 端到端测试计划

> 开发完成于 2026-03-27，以下测试项待后续验证。

## 已通过的验证

- [x] 所有脚本语法检查（Python + Bash）
- [x] install.sh 部署 11 个脚本 + settings.json
- [x] migrate-frontmatter.py 迁移 5 个记忆文件
- [x] memory-access.sh — 实测 access_count 0→1
- [x] memory-decay.sh --force — 正确扫描，feedback/user 不衰减
- [x] memory-dedup.py 解析器 — mock 数据解析正确

## 待验证：Feature 2 — 自动提取记忆

### Test 2.1: feedback 类型提取
1. 新会话中给出明确反馈（如"以后记住不要做 X"）
2. 结束会话，等 30 秒
3. 检查：
```bash
ls ~/.claude/projects/-Users-felix/memory/feedback_*.md
cat ~/.claude/projects/-Users-felix/memory/MEMORY.md
cat ~/.claude/projects/-Users-felix/memory/.state/worker.log
```
4. 预期：新增 feedback_*.md 文件，MEMORY.md 索引更新

### Test 2.2: project 类型提取
1. 新会话中做技术决策讨论（如"我们决定用 Redis 做缓存"）
2. 结束会话
3. 检查 project_*.md 是否新增

### Test 2.3: 去重验证
1. 重复 Test 2.1 的相同反馈内容
2. 结束会话
3. 预期：不产生重复记忆文件

### Test 2.4: 错误检查
```bash
cat ~/.claude/projects/-Users-felix/memory/.state/worker.log
# 应无 Python traceback 或 claude CLI 报错
```

## 待验证：Feature 3 — 记忆热度衰减

### Test 3.1: 访问追踪
1. 在会话中读取一个记忆文件（如让 Claude 读 feedback_no_sycophancy.md）
2. 检查该文件 frontmatter:
```bash
grep -A2 'last_accessed' ~/.claude/projects/-Users-felix/memory/feedback_no_sycophancy.md
```
3. 预期：last_accessed 为今天，access_count 递增

### Test 3.2: stale 标记
1. 创建测试文件：
```bash
cat > ~/.claude/projects/-Users-felix/memory/project_test_decay.md << 'EOF'
---
name: test-decay
description: Test file for decay verification
type: project
created: 2026-01-01
last_accessed: 2026-01-01
access_count: 0
---

Test content for decay.
EOF
```
2. 运行：`bash ~/.claude/scripts/memory-decay.sh --force`
3. 预期：该文件被标记 `status: stale`（idle 85 天 > project 阈值 30 天）

### Test 3.3: archive 归档
1. 创建更老的测试文件（last_accessed: 2025-11-01，idle ~147 天）
2. 运行 `memory-decay.sh --force`
3. 预期：文件被移到 `memory/.archive/`

### Test 3.4: 永不衰减验证
1. 确认 feedback/user 类型文件无论多久不访问都不被标记或归档

## 待验证：Feature 1 — 自动生成模块摘要

### Test 1.1: pending 文件生成
1. 在有 CLAUDE.md 的项目中编辑 1 个文件
2. 检查：
```bash
ls ~/.claude/scripts/.summary-state/
```
3. 预期：出现 {hash}.pending 文件，内含 PROJECT_ROOT 和变更路径

### Test 1.2: 摘要生成（需 3+ 文件）
1. 在同一项目中编辑 3+ 个文件
2. 结束会话
3. 检查项目 CLAUDE.md:
```bash
grep -A3 '<abstract>' <project>/CLAUDE.md
grep -A5 '<overview>' <project>/CLAUDE.md
```
4. 预期：`<abstract>` 和 `<overview>` 段被 Haiku 生成的内容替换

### Test 1.3: 低于阈值跳过
1. 只编辑 1-2 个文件后结束会话
2. 预期：pending 文件被清理，CLAUDE.md 不变

### Test 1.4: 无标签项目跳过
1. 在没有 `<abstract>`/`<overview>` 标签的项目中编辑文件
2. 预期：pending 文件被清理，不报错

## 快速验证脚本

```bash
# 0. 确认部署完整
ls ~/.claude/scripts/{session-lesson,memory-worker,memory-access,memory-decay,summary-tracker,summary-worker}.sh
ls ~/.claude/scripts/{memory-dedup,migrate-frontmatter,extract-session}.py

# 1. 确认 hooks 配置
python3 -c "
import json
s = json.load(open('$HOME/.claude/settings.json'))
h = s.get('hooks', {})
for k, v in h.items():
    for r in v:
        for hook in r.get('hooks', []):
            print(f'{k} [{r.get(\"matcher\",\"*\")}] → {hook[\"command\"].split(\"/\")[-1]}')
"

# 2. 手动测试 decay
bash ~/.claude/scripts/memory-decay.sh --force

# 3. 检查 worker 日志
cat ~/.claude/projects/-Users-felix/memory/.state/worker.log 2>/dev/null || echo "No logs yet"
cat ~/.claude/scripts/.summary-state/worker.log 2>/dev/null || echo "No logs yet"
cat ~/.claude/projects/-Users-felix/memory/.state/decay.log 2>/dev/null || echo "No logs yet"
```
