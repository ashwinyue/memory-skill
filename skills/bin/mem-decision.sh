#!/bin/bash
# mem-decision.sh - 记录决策

WORKSPACE="${1:-.}"
TITLE="$2"
DECISION="$3"
REASONING="$4"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M)

if [ -z "$TITLE" ] || [ -z "$DECISION" ] || [ -z "$REASONING" ]; then
  echo "用法: /mem-decision \"标题\" \"决策\" \"理由\""
  echo "示例: /mem-decision \"使用 TypeScript\" \"采用 TypeScript 开发\" \"类型安全，生态完善\""
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

# 追加到 decisions.md
DECISIONS_FILE="$WORKSPACE/memory/decisions.md"
echo "" >> "$DECISIONS_FILE"
echo "## $TODAY: $TITLE" >> "$DECISIONS_FILE"
echo "" >> "$DECISIONS_FILE"
echo "**决策**: $DECISION" >> "$DECISIONS_FILE"
echo "" >> "$DECISIONS_FILE"
echo "**理由**: $REASONING" >> "$DECISIONS_FILE"
echo "" >> "$DECISIONS_FILE"

# 追加到今日日志
echo "" >> "$DAILY_FILE"
echo "### $TIMESTAMP - 决策" >> "$DAILY_FILE"
echo "**$TITLE**" >> "$DAILY_FILE"
echo "- 决策: $DECISION" >> "$DAILY_FILE"
echo "- 理由: $REASONING" >> "$DAILY_FILE"

echo "✅ 决策已记录: $TITLE"
echo "   → memory/decisions.md"
echo "   → memory/$TODAY.md"
