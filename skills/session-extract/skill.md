# Session Extract - 会话记忆提取

从 Claude Code 会话中自动提取重要信息到记忆文件。

## 功能

- 读取 Claude Code 会话 JSONL 文件
- 使用 Claude AI 分析会话内容
- 自动提取：决策、教训、事件、想法
- 写入今日日志和 MEMORY.md

## 使用

### 提取最新会话

```bash
./autonomous-kit/skills/session-extract/bin/extract.sh /path/to/workspace
```

### 提取指定会话

```bash
./autonomous-kit/skills/session-extract/bin/extract.sh /path/to/workspace <session-id>
```

## 输出

1. **今日日志** (`memory/YYYY-MM-DD.md`)
   - 完整的会话分析
   - 所有提取的信息

2. **MEMORY.md** (长期记忆)
   - 只同步重要决策和教训
   - 保持简洁，避免冗余

## 集成到会话结束

在 `claude-with-heartbeat.sh` 的 cleanup 函数中调用：

```bash
"$SESSION_EXTRACT" "$WORKSPACE" 2>/dev/null || true
```
