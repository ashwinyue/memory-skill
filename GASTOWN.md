# Gateway 方案 - Gastown 集成

## 为什么选择 Gastown

Gastown 是 Steve Yegge 开发的**多代理 Claude Code 协调系统**，完美解决了我们需要的核心问题：

| 需求 | 传统方案 | Gastown |
|------|---------|---------|
| 持久记忆 | ❌ `claude -p` 无状态 | ✅ Mayor 会话持续运行 |
| 上下文保持 | ❌ 每次调用都是新的 | ✅ Mayor 拥有完整对话历史 |
| 状态持久化 | ❌ 进程重启丢失 | ✅ Git hooks 持久化 |
| 多轮对话 | ❌ 需要手动维护历史 | ✅ 天然支持 |

---

## Gastown 核心架构

```
┌─────────────────────────────────────────────────────────────┐
│                    The Mayor 🎩                            │
│            (持久 Claude Code 会话)                           │
│                                                              │
│  - 在 tmux 中持续运行，保持上下文                             │
│  - 拥有完整记忆和工作状态                                      │
│  - 协调所有其他 agent                                        │
│  - 工作状态保存在 git hooks 中                               │
└─────────────────────────────────────────────────────────────┘
         │
         ├─ sling 任务 → Agent A → 写入 Hook → Mayor 读取
         ├─ sling 任务 → Agent B → 写入 Hook → Mayor 读取
         └─ sling 任务 → Agent C → 写入 Hook → Mayor 读取
```

---

## 核心概念

| 概念 | 说明 |
|------|------|
| **Mayor** | 主协调者，持久 Claude Code 会话 |
| **Town** | 工作区目录 (`~/gt/`) |
| **Rig** | 项目容器，包装 git 仓库 |
| **Crew** | 个人工作空间 |
| **Polecat** | 临时工作代理 |
| **Hooks** | Git worktree 持久化存储 |
| **Convoy** | 工作跟踪单元 |

---

## 安装 Gastown

```bash
# Homebrew 安装（推荐）
brew install gastown

# 初始化工作区
gt install ~/gt --git
cd ~/gt

# 添加项目
gt rig add myproject https://github.com/you/repo.git

# 创建个人工作区
gt crew add yourname --rig myproject

# 启动 Mayor
gt mayor attach
```

---

## 在此基础上添加心跳功能

### 方案设计

```go
// 心跳配置
type HeartbeatConfig struct {
    Interval    time.Duration  // 心跳间隔
    ActiveHours struct {
        Start string        // 活动开始时间
        End   string        // 活动结束时间
    }
    NotifyTarget string      // 通知目标 (telegram/email)
}

// 心跳守护进程
func (d *Daemon) StartHeartbeat(cfg HeartbeatConfig) {
    ticker := time.NewTicker(cfg.Interval)

    for range ticker.C {
        if !d.isActiveHours(cfg.ActiveHours) {
            continue
        }

        // 触发 Mayor 执行心跳任务
        d.TriggerHeartbeat()
    }
}

// 触发心跳
func (d *Daemon) TriggerHeartbeat() {
    // 1. 读取 HEARTBEAT.md
    heartbeat := d.readHeartbeatFile()

    // 2. 在 tmux 会话中发送指令给 Mayor
    tmux.SendKeys("mayor-session",
        fmt.Sprintf("检查心跳任务，当前时间: %s", time.Now()))

    // 3. Mayor 执行后，解析结果
    // 4. 如果有紧急事项，发送通知
    d.sendNotificationIfNeeded()
}
```

### 集成点

| Gastown 组件 | 用途 |
|--------------|------|
| **Mayor Session** | 持久记忆，保持上下文 |
| **Hooks** | 存储 MEMORY.md、每日日志 |
| **Convoy** | 跟踪心跳任务执行状态 |
| **Formulas** | 预定义心跳任务模板 |

---

## 工作流程

### 启动流程

```
1. 启动 Gastown Mayor
   gt mayor attach

2. Mayor 开始运行，拥有完整上下文

3. 心跳守护进程在后台启动
   - 每 30 分钟检查一次
   - 在活动时间内执行

4. 心跳触发时
   - 读取 HEARTBEAT.md
   - 发送任务给 Mayor
   - Mayor 自主执行
   - 结果存入 hooks
```

### 示例：每日新闻收集

```
HEARTBEAT.md:
  ## 每日资讯
  - 使用 WebSearch 搜索今天科技新闻
  - 总结 3 条重要资讯
  - 记录到 memory/YYYY-MM-DD.md
  - 如果有重大突破，发送通知

心跳触发 → Mayor 收到指令 → 执行搜索 → 写入 hooks → 通知你
```

---

## 与传统 Gateway 对比

| | 传统 Gateway | Gastown 方案 |
|---|--------------|-------------|
| 会话管理 | 每次独立调用 | 持久 Mayor 会话 |
| 上下文 | 需要手动维护 | 自动保持 |
| 状态持久化 | 文件系统 | Git hooks |
| 复杂度 | 简单脚本 | Go 项目 |
| 可扩展性 | 有限 | 强大 |

---

## 为什么 Gastown 更好

1. **Steve Yegge 的经验**: 考虑了很多边缘情况
2. **经过实战检验**: 6k+ stars，广泛使用
3. **Go 语言**: 高性能，易并发
4. **模块化设计**: 易于扩展和定制
5. **活跃维护**: 持续更新和改进

---

## 开发路线

### Phase 1: 基础集成
- [ ] Fork Gastown 仓库
- [ ] 添加 Heartbeat 配置结构
- [ ] 实现心跳守护进程
- [ ] 集成 tmux 通信

### Phase 2: 任务执行
- [ ] 解析 HEARTBEAT.md
- [ ] 发送任务给 Mayor
- [ ] 捕获执行结果
- [ ] 存储到 hooks

### Phase 3: 通知集成
- [ ] Telegram Bot 通知
- [ ] 邮件通知
- [ ] macOS 系统通知

### Phase 4: 记忆集成
- [ ] 利用 hooks 存储 MEMORY.md
- [ ] 自动整理每日日志
- [ ] 会话记忆提取

---

## 参考资源

- **GitHub**: https://github.com/steveyegge/gastown
- **文档**: https://github.com/steveyegge/gastown/blob/main/README.md
- **文章**: [Welcome to Gas Town](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04)

---

## 总结

Gastown 为我们提供了：
1. ✅ **持久 Claude 会话** - Mayor 始终保持上下文
2. ✅ **状态持久化** - Git hooks 确保数据不丢失
3. ✅ **可扩展架构** - Go 语言，易添加功能
4. ✅ **成熟系统** - 经过大量用户验证

**推荐方案**：在 Gastown 基础上添加：
- 心跳守护进程
- HEARTBEAT.md 任务解析
- 通知系统集成
- 记忆系统集成

这样我们就拥有了一个**真正自主**的 AI 助手！
