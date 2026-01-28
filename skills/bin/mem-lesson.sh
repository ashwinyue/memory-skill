#!/bin/bash
# mem-lesson.sh - 记录教训

WORKSPACE="${1:-.}"
TITLE="$2"
LESSON="$3"
CONTEXT="$4"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M)

if [ -z "$TITLE" ] || [ -z "$LESSON" ]; then
  echo "用法: /mem-lesson \"标题\" \"教训\" [\"上下文\"]"
  echo "示例: /mem-lesson \"过度设计\" \"简单方案更好\" \"MCP 方案太复杂\""
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

# 追加到 lessons.md
LESSONS_FILE="$WORKSPACE/memory/lessons.md"
echo "" >> "$LESSONS_FILE"
echo "## $TODAY: $TITLE" >> "$LESSONS_FILE"
echo "" >> "$LESSONS_FILE"
echo "**教训**: $LESSON" >> "$LESSONS_FILE"
if [ -n "$CONTEXT" ]; then
  echo "" >> "$LESSONS_FILE"
  echo "**上下文**: $CONTEXT" >> "$LESSONS_FILE"
fi
echo "" >> "$LESSONS_FILE"

# 追加到今日日志
echo "" >> "$DAILY_FILE"
echo "### $TIMESTAMP - 教训" >> "$DAILY_FILE"
echo "**$TITLE**" >> "$DAILY_FILE"
echo "- 教训: $LESSON" >> "$DAILY_FILE"
if [ -n "$CONTEXT" ]; then
  echo "- 上下文: $CONTEXT" >> "$DAILY_FILE"
fi

echo "✅ 教训已记录: $TITLE"
echo "   → memory/lessons.md"
echo "   → memory/$TODAY.md"
