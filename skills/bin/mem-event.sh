#!/bin/bash
# mem-event.sh - 记录事件

WORKSPACE="${1:-.}"
DESCRIPTION="$2"
DETAILS="$3"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M)

if [ -z "$DESCRIPTION" ]; then
  echo "用法: /mem-event \"描述\" [\"详情\"]"
  echo "示例: /mem-event \"完成记忆系统\" \"使用 shell 脚本实现\""
  exit 1
fi

# 确保 memory 目录存在
mkdir -p "$WORKSPACE/memory"

# 确保每日日志存在
DAILY_FILE="$WORKSPACE/memory/$TODAY.md"
if [ ! -f "$DAILY_FILE" ]; then
  echo "# $TODAY" > "$DAILY_FILE"
  echo "" >> "$DAILY_FILE"
fi

# 追加到今日日志
echo "" >> "$DAILY_FILE"
echo "### $TIMESTAMP - 事件" >> "$DAILY_FILE"
echo "**$DESCRIPTION**" >> "$DAILY_FILE"
if [ -n "$DETAILS" ]; then
  echo "" >> "$DAILY_FILE"
  echo "$DETAILS" >> "$DAILY_FILE"
fi

echo "✅ 事件已记录: $DESCRIPTION"
echo "   → memory/$TODAY.md"
