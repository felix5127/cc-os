# Skills Routing

> **Note**: 下列技能名称为示例，实际可用技能以 `~/.claude/skills/` 中安装的为准。
> 使用前请确认技能已安装，或替换为功能等价的已安装技能。

## Default
Use:
- planning-with-files
- executing-plans
- verification-before-completion

Avoid:
- deep refactor unless required

## Resume / Half-Done Project
Use:
- subagent-driven-development
- systematic-debugging
- receiving-code-review

Output order:
- status assessment
- repair plan
- controlled fix
- verification

## New Feature
Use:
- writing-plans
- test-driven-development (core logic)
- requesting-code-review

Output order:
- questions
- plan
- implementation
- verification

## Debug / Build Broken
Use:
- systematic-debugging
- verification-before-completion

Output order:
- reproduce
- root cause
- minimal fix
- validate

## Frontend / Next.js
Use:
- vercel-react-best-practices
- web-design-guidelines
