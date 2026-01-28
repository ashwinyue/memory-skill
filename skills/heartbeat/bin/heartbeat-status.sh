#!/bin/bash
# heartbeat-status.sh - 显示心跳状态

WORKSPACE="${1:-.}"
STATE_FILE="$WORKSPACE/.heartbeat-state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "📊 心跳状态: 未运行过"
  exit 0
fi

LAST_RUN=$(cat "$STATE_FILE" 2>/dev/null | jq -r '.lastRun // "never"')
STATUS=$(cat "$STATE_FILE" 2>/dev/null | jq -r '.status // "unknown"')

echo "📊 心跳状态"
echo ""
echo "上次运行: $LAST_RUN"
echo "状态: $STATUS"
