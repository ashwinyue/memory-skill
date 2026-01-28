# 架构设计 - Autonomous Kit

## 核心理念

让 Claude Code 拥有**持久记忆**和**主动执行**能力，无需 MCP 服务器，纯 Shell 脚本实现。

---

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code 会话                         │
│                    (你交互工作)                              │
└─────────────────────────────────────────────────────────────┘
         ↑ 启动时加载                    ↓ 退出时保存
         │                             │
┌─────────────────────────────────────────────────────────────┐
│                  claude-with-heartbeat.sh                   │
│                  (一键启动脚本)                              │
│                                                              │
│  启动流程：                                                  │
│  1. 加载记忆 (SOUL, USER, AGENTS, MEMORY, 今日日志)        │
│  2. 启动心跳守护进程 (后台)                                  │
│  3. 启动 Claude Code (前台)                                  │
│                                                              │
│  退出流程：                                                  │
│  1. 停止心跳守护进程                                        │
│  2. 记录会话结束                                            │
│  3. 提取会话记忆到 MEMORY.md                                 │
└─────────────────────────────────────────────────────────────┘
         ↓ 启动                    ↑ 停止
         │                        │
┌─────────────────────────────────────────────────────────────┐
│              heartbeat-daemon.sh (心跳守护进程)              │
│                                                              │
│  - 后台 Shell 脚本，独立运行                                  │
│  - 每 30 分钟触发一次心跳                                    │
│  - 只在活动时间运行 (9:00-23:00)                             │
│  - 调用 Claude CLI 执行 HEARTBEAT.md 中的任务                │
└─────────────────────────────────────────────────────────────┘
         ↓ 定期触发
         │
┌─────────────────────────────────────────────────────────────┐
│                    HEARTBEAT.md                              │
│                  (任务清单)                                  │
│                                                              │
│  - 每日资讯：搜索新闻、总结记录                              │
│  - 每日检查：代码质量、依赖、项目状态                        │
│  - 每周检查：文档更新、架构审查                              │
│  - 每月检查：战略规划、依赖清理                              │
│  - 触发式任务：根据事件自动执行                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 与 Moltbot 的对比

| 特性 | Moltbot | Autonomous Kit |
|------|---------|----------------|
| **实现方式** | Node.js + TypeScript | 纯 Bash 脚本 |
| **部署复杂度** | 需要编译、依赖管理 | 即拷即用 |
| **记忆系统** | 向量数据库 | Markdown 文件 |
| **心跳触发** | 守护进程 + AI API | 守护进程 + Claude CLI |
| **会话管理** | 多会话协调 | 项目级会话 |
| **主动通知** | 发送到聊天频道 | macOS 系统通知 |
| **配置方式** | config.json | Markdown 文件 |

---

## 核心组件

### 1. 一键启动脚本

**位置**: `claude-with-heartbeat.sh`

**功能**:
- 启动时自动加载所有记忆文件
- 启动心跳守护进程（后台）
- 启动 Claude Code（前台）
- 退出时自动保存记忆和提取会话内容

**使用**:
```bash
./claude-with-heartbeat.sh      # 启动
./claude-with-heartbeat.sh stop  # 停止
./claude-with-heartbeat.sh status # 查看状态
```

### 2. 心跳守护进程

**位置**: `skills/heartbeat/bin/heartbeat-daemon.sh`

**功能**:
- 后台持续运行
- 定时（默认 30 分钟）触发 Claude 执行任务
- 只在活动时间窗口内运行
- 解析并执行通知指令

**环境变量**:
```bash
WORKSPACE               # 工作区目录
HEARTBEAT_INTERVAL      # 心跳间隔秒数 (默认 1800)
HEARTBEAT_ACTIVE_START  # 活动开始时间 (默认 09:00)
HEARTBEAT_ACTIVE_END    # 活动结束时间 (默认 23:00)
```

**使用**:
```bash
# 启动守护进程
./skills/heartbeat/bin/heartbeat-daemon.sh start

# 查看状态
./skills/heartbeat/bin/heartbeat-daemon.sh status

# 停止
./skills/heartbeat/bin/heartbeat-daemon.sh stop

# 手动触发一次
./skills/heartbeat/bin/heartbeat-daemon.sh run
```

### 3. 记忆系统

**位置**: `skills/autonomous-memory/bin/`

**命令**:
```bash
# 加载记忆
./skills/autonomous-memory/bin/mem-load.sh /path/to/workspace

# 记录决策
./skills/autonomous-memory/bin/mem-decision.sh /path "标题" "决策" "理由"

# 记录教训
./skills/autonomous-memory/bin/mem-lesson.sh /path "标题" "教训" "上下文"

# 记录事件
./skills/autonomous-memory/bin/mem-event.sh /path "描述" "详情"

# 写入日志
./skills/autonomous-memory/bin/mem-log.sh /path "章节" "内容"

# 结束会话
./skills/autonomous-memory/bin/mem-end.sh /path "总结"
```

### 4. 会话记忆提取

**位置**: `skills/session-extract/bin/extract.sh`

**功能**:
- 读取 Claude Code 会话 JSONL 文件
- 使用 Claude AI 分析并提取重要信息
- 写入今日日志和 MEMORY.md

**使用**:
```bash
./skills/session-extract/bin/extract.sh /path/to/workspace [session-id]
```

---

## 工作流程

### 启动流程

```
1. 执行 ./claude-with-heartbeat.sh
   ↓
2. 显示 SOUL.md、USER.md、AGENTS.md（AI 的人格和工作方式）
   ↓
3. 显示 MEMORY.md（长期记忆）
   ↓
4. 显示今日日志（最近上下文）
   ↓
5. 启动心跳守护进程（后台）
   ↓
6. 启动 Claude Code（你可以开始工作）
```

### 心跳执行流程

```
1. 守护进程检查时间（是否在活动窗口）
   ↓
2. 读取 HEARTBEAT.md
   ↓
3. 调用 Claude CLI（一次性，非持久会话）
   ↓
4. Claude 分析当前时间应该执行哪些任务
   ↓
5. Claude 自主执行任务：
   - 使用 WebSearch 搜索信息
   - 使用 Bash 运行命令
   - 读取/写入文件记录结果
   ↓
6. 结果记录到 memory/YYYY-MM-DD.md
   ↓
7. 如果有紧急事项，发送 macOS 通知
```

### 退出流程

```
1. 你关闭 Claude Code（Ctrl+C 或 exit）
   ↓
2. 停止心跳守护进程
   ↓
3. 记录会话结束到今日日志
   ↓
4. 提取会话中的重要信息到 MEMORY.md
   ↓
5. 显示今日统计（决策数、教训数、事件数）
```

---

## 信号处理

| 操作 | 是否触发清理 | 说明 |
|------|-------------|------|
| 正常退出 (exit) | ✅ 是 | 完整清理流程 |
| Ctrl+C | ✅ 是 | 捕获 INT 信号 |
| 关闭终端 | ✅ 是 | 捕获 TERM 信号 |
| kill 进程 | ✅ 是 | 捕获 TERM 信号 |

---

## 文件结构

```
autonomous-kit/
├── claude-with-heartbeat.sh    # 一键启动脚本
├── personalities/              # 人格定义
│   ├── SOUL.md                # 你是谁
│   ├── USER.md                # 你在帮助谁
│   ├── AGENTS.md              # 工作区规则
│   ├── HEARTBEAT.md           # 任务清单
│   └── MEMORY.md              # 长期记忆
├── skills/                    # 技能脚本
│   ├── autonomous-memory/      # 记忆管理
│   │   └── bin/
│   │       ├── mem-load.sh
│   │       ├── mem-decision.sh
│   │       ├── mem-lesson.sh
│   │       ├── mem-event.sh
│   │       ├── mem-log.sh
│   │       └── mem-end.sh
│   ├── heartbeat/             # 心跳系统
│   │   └── bin/
│   │       ├── heartbeat-daemon.sh
│   │       ├── heartbeat.sh
│   │       ├── heartbeat-run.sh
│   │       └── heartbeat-status.sh
│   └── session-extract/       # 会话提取
│       └── bin/
│           └── extract.sh
├── memory/                    # 记忆存储
│   ├── YYYY-MM-DD.md          # 每日日志
│   ├── decisions.md           # 决策记录
│   ├── lessons.md             # 教训记录
│   └── patterns.md            # 代码模式
└── templates/                 # 模板文件
    ├── SOUL.template.md
    ├── USER.template.md
    ├── AGENTS.template.md
    ├── HEARTBEAT.template.md
    ├── MEMORY.template.md
    └── daily-log.template.md
```

---

## 使用示例

### 示例 1：每日新闻收集

在 HEARTBEAT.md 中添加：

```markdown
## 每日资讯

- [ ] **科技新闻**：搜索今天的科技新闻，总结 3 条重要资讯
  - 记录到 memory/YYYY-MM-DD.md
  - 如果有重要突破，发送通知
```

心跳会自动：
1. 搜索新闻
2. 总结 3 条
3. 写入日志
4. 重大突破时弹窗通知你

### 示例 2：代码质量检查

在 HEARTBEAT.md 中添加：

```markdown
## 每日检查

- [ ] **代码质量**
  - 运行 pnpm lint
  - 运行 pnpm test
  - 记录结果到日志
```

### 示例 3：条件通知

在 HEARTBEAT.md 中添加：

```markdown
## 条件任务

- [ ] **天气提醒**：检查天气
  - 如果下雨：:::notify::记得带伞出行::
  - 如果高温：:::notify::注意防暑降温::
```

---

## 设计原则

1. **简单** - 纯 bash 脚本，零依赖
2. **直接** - 文件操作，无需数据库
3. **可靠** - 同步执行，结果确定
4. **透明** - 可读可改，易于调试
5. **自主** - AI 能主动执行任务，不被动等待

---

## 常见问题

### Q: 心跳会干扰我工作吗？

A: 不会。心跳在后台独立运行，只在有重要事情时才发送通知。

### Q: 需要保持 Claude Code 打开吗？

A: 不需要。heartbeat-daemon 是独立的 Shell 脚本，可以单独运行。

### Q: 多个项目能共用心跳吗？

A: 每个 HEARTBEAT.md 是项目级的，每个项目有独立的任务清单。

### Q: 如何查看心跳执行记录？

A: 查看 `.heartbeat.log` 文件。

### Q: 心跳消耗 API 额度吗？

A: 是的，每次心跳调用一次 Claude CLI。建议合理设置间隔时间。
