# Heartbeat Skill

心跳技能 - 定期检查 HEARTBEAT.md 并执行任务。

## 使用场景

- 定期检查项目状态
- 执行维护任务
- 检查依赖更新
- 运行测试

## 命令

### `/heartbeat` - 检查心跳

读取 HEARTBEAT.md 并显示需要执行的任务。

```
/heartbeat
```

### `/heartbeat-run` - 执行心跳任务

执行 HEARTBEAT.md 中的任务。

```
/heartbeat-run
```

### `/heartbeat-status` - 心跳状态

显示上次心跳时间和状态。

```
/heartbeat-status
```

## HEARTBEAT.md 格式

```markdown
# 每日检查

- [ ] 运行 pnpm lint
- [ ] 运行 pnpm test
- [ ] 检查 pnpm outdated

# 每周检查

- [ ] 更新文档
- [ ] 审查技术债

# 定期任务

- [ ] 备份数据库
```

## 脚本位置

`~/.claude/skills/heartbeat/bin/`
