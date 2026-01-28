# Skills - 技能脚本

Shell 脚本实现的 AI 助手技能，无需 MCP 服务器。

## 📁 目录结构

```
.skills/
├── autonomous-memory/    # 记忆管理技能
│   ├── skill.md
│   └── bin/
│       ├── mem-load.sh      # 加载所有记忆文件
│       ├── mem-decision.sh  # 记录决策
│       ├── mem-lesson.sh    # 记录教训
│       ├── mem-event.sh     # 记录事件
│       ├── mem-log.sh       # 写入日志
│       └── mem-end.sh       # 结束会话
└── heartbeat/            # 心跳检查技能
    ├── skill.md
    └── bin/
        ├── heartbeat.sh         # 显示任务
        ├── heartbeat-run.sh     # 执行任务
        └── heartbeat-status.sh  # 查看状态
```

## 🚀 使用方式

### 记忆技能

```bash
# 加载记忆（会话开始时）
.skills/autonomous-memory/bin/mem-load.sh /path/to/workspace

# 记录决策
.skills/autonomous-memory/bin/mem-decision.sh /path "标题" "决策" "理由"

# 记录教训
.skills/autonomous-memory/bin/mem-lesson.sh /path "标题" "教训" "上下文"

# 记录事件
.skills/autonomous-memory/bin/mem-event.sh /path "描述" "详情"

# 写入自定义日志
.skills/autonomous-memory/bin/mem-log.sh /path "章节" "内容"

# 结束会话
.skills/autonomous-memory/bin/mem-end.sh /path "总结"
```

### 心跳技能

```bash
# 显示任务清单
.skills/heartbeat/bin/heartbeat.sh /path/to/workspace

# 执行任务检查
.skills/heartbeat/bin/heartbeat-run.sh /path/to/workspace

# 查看心跳状态
.skills/heartbeat/bin/heartbeat-status.sh /path/to/workspace
```

## 🔧 添加新技能

1. 创建技能目录：`.skills/your-skill/`
2. 添加 `skill.md` 说明文档
3. 在 `bin/` 目录添加脚本
4. 确保脚本可执行：`chmod +x bin/*.sh`

## 📖 设计理念

- **简单** - 纯 bash 脚本，无依赖
- **直接** - 文件操作，无需数据库
- **可靠** - 同步执行，结果确定
- **透明** - 脚本可读可编辑

与 MCP 方案对比：

| 特性 | MCP 方案 | Skill 方案 |
|------|---------|-----------|
| 配置 | 需要重启 | 即用即生效 |
| 复杂度 | TypeScript + 依赖 | 纯 bash |
| 维护 | 需要编译 | 直接编辑 |
| 调试 | 需查看日志 | 直接运行 |
