# Autonomous Memory Skill

自主记忆技能 - 自动记录和管理会话记忆，无需 MCP 服务器。

## 使用场景

- 会话开始时：自动加载人格和记忆文件
- 工作中：记录决策、教训、事件
- 会话结束时：同步记忆到文件

## 命令

### `/mem-load` - 加载记忆

加载所有记忆文件：
- SOUL.md - 人格定义
- USER.md - 用户信息
- AGENTS.md - 工作区指南
- MEMORY.md - 长期记忆
- memory/YYYY-MM-DD.md - 今日日志

```
/mem-load
```

### `/mem-decision` - 记录决策

记录一个决策到 `memory/decisions.md` 和今日日志。

```
/mem-decision "创建主动记忆系统" "使用 shell 脚本代替 MCP" "更简单直接，易于维护"
```

### `/mem-lesson` - 记录教训

记录一个教训到 `memory/lessons.md` 和今日日志。

```
/mem-lesson "过度复杂化" "简单方案往往更好" "MCP 方案太复杂，改用 shell 脚本"
```

### `/mem-event` - 记录事件

记录一个事件到今日日志。

```
/mem-event "完成主动记忆技能" "使用 shell 脚本实现"
```

### `/mem-log` - 写入日志

写入自定义内容到今日日志的指定 section。

```
/mem-log "上午" "完成了记忆系统的重构"
```

### `/mem-sync` - 同步记忆

同步所有待处理记忆（预留）。

```
/mem-sync
```

### `/mem-end` - 结束会话

结束会话，记录总结并同步记忆。

```
/mem-end "完成了记忆技能开发，采用 shell 脚本方案"
```

## 脚本位置

所有脚本位于：`~/.claude/skills/autonomous-memory/bin/`
