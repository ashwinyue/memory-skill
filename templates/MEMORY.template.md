# Moltbot 项目记忆

> 最后更新: 2025-01-29

## 项目概述

**Moltbot** 是一个多功能 AI 助手项目，支持多个消息渠道（Telegram、Discord、Slack、Signal、iMessage、WhatsApp Web）。

### 核心技术栈
- **语言**: TypeScript (ESM) / Node.js 22+
- **数据库**: SQLite + sqlite-vec 向量搜索
- **协议**: MCP (Model Context Protocol) for tool integration
- **包管理**: pnpm (支持 Bun)
- **测试**: Vitest with V8 coverage

### 项目结构
```
moltbot/
├── src/              # 源代码
│   ├── cli/         # CLI wiring
│   ├── commands/    # 命令实现
│   ├── provider-web.ts  # Web provider
│   ├── infra/       # 基础设施
│   └── media/       # 媒体管道
├── extensions/      # 插件/扩展
├── docs/           # 文档
└── autonomous-core/  # 自主 Agent 核心模块 (新)
```

## Autonomous Core 模块

从 moltbot 提取的独立功能模块，提供：

### 1. 记忆索引 (Memory Indexing)
- 基于向量嵌入的语义记忆和检索
- 支持 OpenAI、Gemini、本地嵌入
- 混合搜索（向量 + 全文搜索）
- 批量嵌入 API 支持

### 2. 进程注册表 (Process Registry)
- 持久化后台进程管理
- 输出查询和生命周期管理

### 3. 心跳检测 (Heartbeat)
- 定期检查 HEARTBEAT.md 并执行任务
- 支持自定义调度间隔

### 4. 人格管理 (Personality)
- 持久化人格定义 (SOUL.md)
- 多人格切换和特质配置
- System prompt 构建

### 5. 记忆归档 (Memory Archive)
- 按天归档记忆内容
- 时序检索和存储管理

## 重要决策记录

### 2025-01-29: Autonomous Core 提取
- **决策**: 将 moltbot 的自主 Agent 核心能力提取为独立模块
- **原因**: 使功能可复用，去除对 IM 通道的依赖
- **位置**: `autonomous-core/`
- **状态**: 开发中

## 编码规范

### 命名约定
- 产品/应用/文档标题: **Moltbot**
- CLI 命令/包/路径/配置键: `moltbot`

### 代码风格
- 使用 Oxlint 和 Oxfmt 进行格式化/lint
- 保持文件简洁 (<700 LOC)
- 添加复杂逻辑注释
- 遵循 SOLID、KISS、DRY、YAGNI 原则

### 提交规范
- 使用 `scripts/committer` 创建提交
- Conventional Commit 格式
- 简洁、行动导向的消息

## 开发命令速查

```bash
# 安装依赖
pnpm install

# 类型检查
pnpm typecheck

# Lint/Format
pnpm lint
pnpm format

# 测试
pnpm test
pnpm test:coverage

# 运行 CLI
pnpm moltbot ...
```

## 渠道支持

### 核心渠道 (src/)
- `src/telegram` - Telegram
- `src/discord` - Discord
- `src/slack` - Slack
- `src/signal` - Signal
- `src/imessage` - iMessage
- `src/web` - WhatsApp Web

### 扩展渠道 (extensions/)
- `extensions/msteams` - Microsoft Teams
- `extensions/matrix` - Matrix
- `extensions/zalo` - Zalo
- `extensions/voice-call` - 语音通话

**重要**: 修改共享逻辑时，必须考虑所有内置 + 扩展渠道。

## 待办事项

### Autonomous Core
- [ ] 完成 MCP 服务器集成测试
- [ ] 添加本地嵌入模型支持
- [ ] 实现记忆归档清理策略
- [ ] 编写完整使用文档

### 项目优化
- [ ] 根据记忆搜索结果持续优化代码
- [ ] 定期运行 HEARTBEAT.md 中的任务
- [ ] 保持 MEMORY.md 更新

---

*此文件由 Ralph Wiggum 循环维护，每次会话时读取并更新*
