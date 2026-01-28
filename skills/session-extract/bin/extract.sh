#!/bin/bash
# extract.sh - 从 Claude Code 会话中提取记忆
#
# 用法:
#   ./extract.sh <workspace> [session-id]
#
# 如果不指定 session-id，使用最新的会话

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${1:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
SESSION_ID="${2:-}"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +"%Y-%m-%d %H:%M:%S")

# 编码项目路径（与 Claude Code 一致）
encode_project_path() {
  echo "$1" | sed 's(/^\//-/; s/\/$//; s/\//-/g)'
}

# 解码项目路径
decode_project_path() {
  echo "$1" | sed 's/^-//; s/-/\//g'
}

# 查找项目会话目录
PROJECT_ENCODED=$(encode_project_path "$WORKSPACE")
SESSION_DIR="$HOME/.claude/projects/$PROJECT_ENCODED"

if [ ! -d "$SESSION_DIR" ]; then
  echo "❌ 未找到会话目录: $SESSION_DIR"
  exit 1
fi

# 查找会话文件
find_session_file() {
  if [ -n "$SESSION_ID" ]; then
    # 使用指定的 session-id
    if [ -f "$SESSION_DIR/$SESSION_ID.jsonl" ]; then
      echo "$SESSION_DIR/$SESSION_ID.jsonl"
    else
      echo "❌ 未找到会话: $SESSION_ID"
      exit 1
    fi
  else
    # 使用最新的会话
    find "$SESSION_DIR" -name "*.jsonl" -type f -exec ls -t {} + | head -1
  fi
}

SESSION_FILE=$(find_session_file)

if [ ! -f "$SESSION_FILE" ]; then
  echo "❌ 未找到会话文件"
  exit 1
fi

# 获取 session-id
SESSION_ID=$(basename "$SESSION_FILE" .jsonl)

echo "📖 正在分析会话: $SESSION_ID"
echo "   项目: $WORKSPACE"
echo ""

# 确保 memory 目录存在
mkdir -p "$WORKSPACE/memory"

# 确保每日日志存在
DAILY_FILE="$WORKSPACE/memory/$TODAY.md"
if [ ! -f "$DAILY_FILE" ]; then
  echo "# $TODAY" > "$DAILY_FILE"
  echo "" >> "$DAILY_FILE"
fi

# 提取用户消息（用于分析）
USER_MESSAGES=$(jq -r 'select(.type == "user") | .message.content[]? | select(.type == "text") | .text' "$SESSION_FILE" 2>/dev/null || echo "")

if [ -z "$USER_MESSAGES" ]; then
  echo "⚠️  会话中没有用户消息"
  exit 0
fi

# 构建 Claude 提示
PROMPT="分析以下 Claude Code 会话，提取重要信息到记忆中。

会话内容：
---
$USER_MESSAGES
---

请按以下格式输出，如果某个分类没有内容则跳过：

## 📋 会话摘要
[简短总结本次会话的主要内容]

## 🎯 决策
### [标题] - 决策
**决策**: ...
**理由**: ...
**时间**: $TIME

## 📚 教训
### [标题] - 教训
**教训**: ...
**上下文**: ...
**时间**: $TIME

## 📝 事件
### [描述] - 事件
**详情**: ...
**时间**: $TIME

## 💡 想法
### [标题] - 想法
**内容**: ...
**时间**: $TIME

只输出上述格式的内容，不要包含其他解释。"

# 调用 Claude API 分析
echo "🤖 正在使用 Claude 分析会话..."
echo ""

ANALYSIS=$(echo "$PROMPT" | claude --print --output-format json 2>/dev/null | jq -r '.content[0].text' 2>/dev/null || echo "$PROMPT" | claude --print 2>/dev/null)

if [ -z "$ANALYSIS" ]; then
  echo "⚠️  Claude 分析失败，跳过提取"
  exit 0
fi

# 追加到今日日志
echo "" >> "$DAILY_FILE"
echo "---" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "## 📖 会话记忆提取" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "**时间**: $TIME" >> "$DAILY_FILE"
echo "**会话**: $SESSION_ID" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "$ANALYSIS" >> "$DAILY_FILE"

# 同步到 MEMORY.md（如果是重要决策/教训）
MEMORY_FILE="$WORKSPACE/MEMORY.md"

# 提取决策部分
DECISIONS=$(echo "$ANALYSIS" | sed -n '/## 🎯 决策/,/## /p' | head -n -1)
if [ -n "$DECISIONS" ]; then
  # 确保 MEMORY.md 存在
  if [ ! -f "$MEMORY_FILE" ]; then
    echo "# MEMORY.md - 长期记忆" > "$MEMORY_FILE"
    echo "" >> "$MEMORY_FILE"
    echo "> 精选记忆，区别于每日原始日志" >> "$MEMORY_FILE"
    echo "" >> "$MEMORY_FILE"
  fi

  # 检查是否有 decisions section，没有则创建
  if ! grep -q "^## 🎯 决策" "$MEMORY_FILE"; then
    echo "" >> "$MEMORY_FILE"
    echo "## 🎯 决策" >> "$MEMORY_FILE"
    echo "" >> "$MEMORY_FILE"
  fi

  # 追加新决策
  echo "" >> "$MEMORY_FILE"
  echo "$DECISIONS" >> "$MEMORY_FILE"
fi

# 提取教训部分
LESSONS=$(echo "$ANALYSIS" | sed -n '/## 📚 教训/,/## /p' | head -n -1)
if [ -n "$LESSONS" ]; then
  if ! grep -q "^## 📚 教训" "$MEMORY_FILE"; then
    echo "" >> "$MEMORY_FILE"
    echo "## 📚 教训" >> "$MEMORY_FILE"
    echo "" >> "$MEMORY_FILE"
  fi

  echo "" >> "$MEMORY_FILE"
  echo "$LESSONS" >> "$MEMORY_FILE"
fi

echo "✅ 记忆提取完成"
echo "   - 已追加到: memory/$TODAY.md"
echo "   - 重要信息已同步到: MEMORY.md"
echo ""
