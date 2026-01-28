#!/bin/bash
# heartbeat-run.sh - 执行心跳任务

WORKSPACE="${1:-.}"
HEARTBEAT_FILE="$WORKSPACE/HEARTBEAT.md"
STATE_FILE="$WORKSPACE/.heartbeat-state.json"

if [ ! -f "$HEARTBEAT_FILE" ]; then
  echo "❌ 未找到 HEARTBEAT.md 文件"
  exit 1
fi

# 读取上次心跳时间
LAST_RUN=$(cat "$STATE_FILE" 2>/dev/null | jq -r '.lastRun // "never"')
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "💓 执行心跳任务..."
echo "上次运行: $LAST_RUN"
echo ""

# 解析 HEARTBEAT.md 中的任务
echo "📋 待办任务:"
echo ""

# 查找所有未完成的任务 (- [ ])
grep -n "^- \[ \]" "$HEARTBEAT_FILE" | while read -r line; do
  LINE_NUM=$(echo "$line" | cut -d: -f1)
  TASK=$(echo "$line" | cut -d: -f2- | sed 's/^- \[ \] //')
  echo "  ☐ $TASK"
done

echo ""
echo "✅ 心跳检查完成"
echo ""
echo "提示: 使用 /heartbeat-status 查看状态"
