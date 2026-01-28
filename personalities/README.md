# Personalities - AI 助手人格系统

> 让 Claude Code 记住你是谁，记住项目上下文，主动维护项目健康

## 📁 目录结构

```
moltbot/
├── .personalities/       # 人格定义（此目录）
│   ├── SOUL.md           # 你是谁
│   ├── USER.md           # 你在帮助谁
│   ├── AGENTS.md         # 工作区指南
│   └── HEARTBEAT.md      # 定期任务
├── .skills/              # 技能脚本
│   ├── autonomous-memory/# 记忆管理
│   └── heartbeat/        # 心跳检查
├── MEMORY.md             # 长期记忆
└── memory/               # 每日归档
    ├── YYYY-MM-DD.md     # 每日日志
    ├── decisions.md      # 决策记录
    └── lessons.md        # 教训记录
```

## 🚀 快速开始

### 1. 初始化工作区

复制人格文件到项目根目录：

```bash
cp .personalities/SOUL.md .
cp .personalities/USER.md .
cp .personalities/AGENTS.md .
cp .personalities/HEARTBEAT.md .
```

### 2. 使用记忆技能

```bash
# 加载记忆
.skills/autonomous-memory/bin/mem-load.sh .

# 记录决策
.skills/autonomous-memory/bin/mem-decision.sh . "标题" "决策" "理由"

# 记录教训
.skills/autonomous-memory/bin/mem-lesson.sh . "标题" "教训" "上下文"

# 记录事件
.skills/autonomous-memory/bin/mem-event.sh . "描述" "详情"

# 写入日志
.skills/autonomous-memory/bin/mem-log.sh . "章节" "内容"

# 结束会话
.skills/autonomous-memory/bin/mem-end.sh . "总结"
```

### 3. 使用心跳技能

```bash
# 查看任务
.skills/heartbeat/bin/heartbeat.sh .

# 执行任务
.skills/heartbeat/bin/heartbeat-run.sh .

# 查看状态
.skills/heartbeat/bin/heartbeat-status.sh .
```

## 📖 文件说明

### SOUL.md - 你是谁

定义 AI 助手的人格、价值观和工作方式。

**核心原则：**
- 要真正有帮助，而不是表演性地有帮助
- 要有观点，不要做搜索引擎
- 先尝试自己解决，再询问

### USER.md - 你在帮助谁

记录用户的信息、偏好和上下文。

### AGENTS.md - 工作区指南

定义工作区规则、代码风格和项目结构。

**每次会话开始时：**
1. 读取 SOUL.md
2. 读取 USER.md
3. 读取 AGENTS.md
4. 读取 MEMORY.md
5. 读取今日日志

### HEARTBEAT.md - 定期任务

定义需要定期执行的维护任务。

**任务类型：**
- 每日检查：代码质量、依赖、测试
- 每周检查：文档更新、架构审查
- 每月检查：战略规划、依赖清理

### MEMORY.md - 长期记忆

精选的长期记忆，区别于每日原始日志。

### memory/ - 归档目录

- `YYYY-MM-DD.md` - 每日日志
- `decisions.md` - 架构决策记录
- `lessons.md` - 经验教训
- `patterns.md` - 代码模式

## 🔧 自定义

### 修改人格

编辑 `.personalities/SOUL.md` 来调整 AI 助手的性格。

### 添加任务

编辑 `.personalities/HEARTBEAT.md` 来添加定期任务。

### 扩展技能

在 `.skills/` 目录下添加新的技能脚本。

## 📚 参考

- [Moltbot 项目指南](https://github.com/moltbot/moltbot)
- [AGENTS.md 模板](docs/reference/templates/AGENTS.md)
- [SOUL.md 模板](docs/reference/templates/SOUL.md)
- [USER.md 模板](docs/reference/templates/USER.md)

---

**设计理念：简单、直接、有效**
