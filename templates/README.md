# Templates - 模板文件

这些是 autonomous-kit 的配置模板，供新项目初始化使用。

## 使用方法

### 方式一：复制到项目根目录

```bash
cd autonomous-kit
cp templates/*.template.md ../
# 重命名文件
mv SOUL.template.md SOUL.md
mv USER.template.md USER.md
mv AGENTS.template.md AGENTS.md
mv HEARTBEAT.template.md HEARTBEAT.md
mv MEMORY.template.md MEMORY.md
```

### 方式二：使用初始化脚本

```bash
./autonomous-kit/scripts/init.sh /path/to/project
```

## 文件说明

| 模板 | 说明 | 用途 |
|------|------|------|
| `SOUL.template.md` | AI 助手人格定义 | 定义你是谁，你的价值观和工作方式 |
| `USER.template.md` | 用户信息 | 记录你在帮助谁，用户的偏好和上下文 |
| `AGENTS.template.md` | 工作区规则 | 定义项目规则、代码风格、会话流程 |
| `HEARTBEAT.template.md` | 定期任务清单 | 定义需要定期执行的维护任务 |
| `MEMORY.template.md` | 长期记忆模板 | 精选记忆，区别于每日原始日志 |
| `daily-log.template.md` | 每日日志模板 | 每日记录的格式模板 |

## 自定义

复制模板后，根据你的需求修改内容：
- **SOUL.md**: 调整 AI 助手的性格和行为
- **USER.md**: 填写你的个人信息和偏好
- **AGENTS.md**: 设置项目特定的规则和约定
- **HEARTBEAT.md**: 添加你想定期检查的任务
- **MEMORY.md**: 清空或保留示例内容作为参考
