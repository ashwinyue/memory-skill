#!/bin/bash
# mem-end.sh - 结束会话

WORKSPACE="${1:-.}"
SUMMARY="$2"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +"%Y-%m-%d %H:%M:%S")

# 确保 memory 目录存在
mkdir -p "$WORKSPACE/memory"

# 确保每日日志存在
DAILY_FILE="$WORKSPACE/memory/$TODAY.md"
if [ ! -f "$DAILY_FILE" ]; then
  echo "# $TODAY" > "$DAILY_FILE"
  echo "" >> "$DAILY_FILE"
fi

# 记录会话结束
echo "" >> "$DAILY_FILE"
echo "---" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "## 会话结束" >> "$DAILY_FILE"
echo "" >> "$DAILY_FILE"
echo "**时间**: $TIME" >> "$DAILY_FILE"
if [ -n "$SUMMARY" ]; then
  echo "" >> "$DAILY_FILE"
  echo "**总结**: $SUMMARY" >> "$DAILY_FILE"
fi

# 统计今日记忆
DECISIONS=$(grep -c "^###.*- 决策" "$DAILY_FILE" 2>/dev/null || echo 0)
LESSONS=$(grep -c "^###.*- 教训" "$DAILY_FILE" 2>/dev/null || echo 0)
EVENTS=$(grep -c "^###.*- 事件" "$DAILY_FILE" 2>/dev/null || echo 0)

echo ""
echo "✅ 会话已结束"
echo "   记忆已同步到 memory/$TODAY.md"
echo ""
echo "📊 今日记忆统计:"
echo "   - 决策: $DECISIONS"
echo "   - 教训: $LESSONS"
echo "   - 事件: $EVENTS"
