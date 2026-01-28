#!/bin/bash
# mem-log.sh - 写入自定义日志

WORKSPACE="${1:-.}"
SECTION="$2"
CONTENT="$3"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M)

if [ -z "$SECTION" ] || [ -z "$CONTENT" ]; then
  echo "用法: /mem-log \"章节\" \"内容\""
  echo "示例: /mem-log \"上午\" \"完成了记忆系统开发\""
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

# 追加内容
echo "" >> "$DAILY_FILE"
echo "## $SECTION" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "### $TIMESTAMP" >> "$DAILY_FILE"
echo "$CONTENT" >> "$DAILY_FILE"

echo "✅ 日志已写入 [$SECTION]"
echo "   → memory/$TODAY.md"
