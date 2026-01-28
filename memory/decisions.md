# 架构决策记录

> 记录项目中的重要技术决策和其理由

## 2025-01-29: Autonomous Core 模块化

**决策**: 将 moltbot 的自主 Agent 核心能力提取为独立模块 `autonomous-core/`

**背景**:
- moltbot 中积累了大量通用 Agent 能力
- 这些能力与 IM 通道强耦合，难以复用
- Claude Code 等其他项目可以受益

**选择的方案**:
- 创建 `autonomous-core/` 作为独立包
- 使用 MCP (Model Context Protocol) 暴露工具
- 支持 MEMORY.md、SOUL.md、HEARTBEAT.md 配置文件

**权衡**:
- ✅ 优点: 可复用、解耦、易于测试
- ⚠️ 缺点: 需要维护额外的抽象层

**结果**: 正在实施中

---

## 决策模板

```markdown
## YYYY-MM-DD: [决策标题]

**决策**: [简短描述]

**背景**:
- [问题背景]

**选择的方案**:
- [方案描述]

**权衡**:
- ✅ 优点: ...
- ⚠️ 缺点: ...

**结果**: [状态/结果]
```

## 2026-01-28: 实现主动记忆功能

**决策**: 创建 ActiveMemoryManager 类实现类似 moltbot 的自动记忆

**理由**: 需要持久化会话记忆，自动记录决策和事件

## 2026-01-29: 使用 Skill 代替 MCP

**决策**: 简化架构，直接使用 shell 脚本

**理由**: MCP 需要重启和复杂配置，shell 脚本更简单直接

