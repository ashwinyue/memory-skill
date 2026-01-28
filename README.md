# Autonomous Kit - AI 助手自主工具包

> 让 Claude Code 拥有持久记忆、主动维护、人格定义

无需 MCP 服务器，纯 Shell 脚本实现。

## 📁 目录结构

```
autonomous-kit/
├── personalities/           # 🎭 人格定义
│   ├── SOUL.md            # 你是谁
│   ├── USER.md            # 你在帮助谁
│   ├── AGENTS.md          # 工作区指南
│   └── HEARTBEAT.md       # 定期任务
├── skills/                # 🛠️ 技能脚本
│   ├── autonomous-memory/ # 记忆管理
│   └── heartbeat/         # 心跳检查
└── README.md             # 本文件
```

## 🚀 快速开始

### 方式一：使用一键启动脚本（推荐）

一键启动脚本会：
1. 自动加载记忆（SOUL.md、USER.md、AGENTS.md、MEMORY.md、今日日志）
2. 启动 Claude Code
3. 后台运行心跳守护进程
4. 退出时自动记录会话结束

```bash
cd autonomous-kit
./claude-with-heartbeat.sh          # 启动 Claude Code + 心跳
./claude-with-heartbeat.sh --stop   # 停止所有
./claude-with-heartbeat.sh status   # 查看状态
```

### 方式二：手动初始化

将人格文件复制到项目根目录：

```bash
cp autonomous-kit/personalities/SOUL.md .
cp autonomous-kit/personalities/USER.md .
cp autonomous-kit/personalities/AGENTS.md .
cp autonomous-kit/personalities/HEARTBEAT.md .
```

### 方式三：手动使用技能

```bash
# 加载记忆
autonomous-kit/skills/autonomous-memory/bin/mem-load.sh .

# 记录决策
autonomous-kit/skills/autonomous-memory/bin/mem-decision.sh . "标题" "决策" "理由"

# 记录教训
autonomous-kit/skills/autonomous-memory/bin/mem-lesson.sh . "标题" "教训"

# 记录事件
autonomous-kit/skills/autonomous-memory/bin/mem-event.sh . "描述" "详情"

# 结束会话
autonomous-kit/skills/autonomous-memory/bin/mem-end.sh . "总结"
```

### 3. 使用心跳技能

```bash
# 查看任务
autonomous-kit/skills/heartbeat/bin/heartbeat.sh .

# 执行任务
autonomous-kit/skills/heartbeat/bin/heartbeat-run.sh .
```

## 📖 详细文档

- [personalties/README.md](personalities/README.md) - 人格系统说明
- [skills/README.md](skills/README.md) - 技能脚本说明

## 🎯 设计理念

- **简单** - 纯 bash 脚本，零依赖
- **直接** - 文件操作，无需数据库
- **可靠** - 同步执行，结果确定
- **透明** - 可读可改，易于调试

## 📚 与 Moltbot 的关系

这是从 [moltbot](https://github.com/moltbot/moltbot) 项目提取的自主能力简化版。

| 特性 | Moltbot | Autonomous Kit |
|------|----------|----------------|
| 记忆系统 | ✅ 向量搜索 | ✅ 文件搜索 |
| 心跳任务 | ✅ 定时调度 | ✅ 手动触发 |
| 人格管理 | ✅ 动态切换 | ✅ 静态文件 |
| 部署方式 | MCP 服务器 | Shell 脚本 |

## 📄 License

MIT
