#!/bin/bash
# heartbeat.sh - 显示心跳任务

WORKSPACE="${1:-.}"
HEARTBEAT_FILE="$WORKSPACE/HEARTBEAT.md"

if [ ! -f "$HEARTBEAT_FILE" ]; then
  echo "❌ 未找到 HEARTBEAT.md 文件"
  echo ""
  echo "在 $WORKSPACE 创建 HEARTBEAT.md 以定义定期任务"
  exit 1
fi

echo "💓 心跳任务"
echo ""
cat "$HEARTBEAT_FILE"
