#!/bin/bash
# claude-with-heartbeat.sh
#
# 启动 Claude Code 并自动管理心跳守护进程
#
# 用法：
#   ./claude-with-heartbeat.sh          # 启动 Claude Code + 心跳
#   ./claude-with-heartbeat.sh --stop   # 停止所有

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${WORKSPACE:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
HEARTBEAT_DAEMON="$SCRIPT_DIR/skills/heartbeat/bin/heartbeat-daemon.sh"
MEM_LOAD="$SCRIPT_DIR/skills/autonomous-memory/bin/mem-load.sh"
MEM_END="$SCRIPT_DIR/skills/autonomous-memory/bin/mem-end.sh"

# PID 文件
CLAUDE_PID_FILE="$WORKSPACE/.claude.pid"
HEARTBEAT_PID_FILE="$WORKSPACE/.heartbeat.pid"

# LaunchAgent 配置
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/com.moltbot.heartbeat.plist"
LAUNCH_AGENT_LABEL="com.moltbot.heartbeat"

# 创建 launchd 配置
create_launchd_agent() {
  cat > "$LAUNCH_AGENT_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LAUNCH_AGENT_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${HEARTBEAT_DAEMON}</string>
    <string>run</string>
  </array>
  <key>WorkingDirectory</key>
  <string>${WORKSPACE}</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>RunAtLoad</key>
  <false/>
  <key>KeepAlive</key>
  <false/>
  <key>StandardOutPath</key>
  <string>${WORKSPACE}/.heartbeat.log</string>
  <key>StandardErrorPath</key>
  <string>${WORKSPACE}/.heartbeat.log</string>
  <key>AbandonProcessGroup</key>
  <true/>
</dict>
</plist>
EOF

  echo "✅ Created launchd agent: $LAUNCH_AGENT_PLIST"
  echo ""
  echo "加载 agent:"
  launchctl load "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
}

# 移除 launchd 配置
remove_launchd_agent() {
  if [ -f "$LAUNCH_AGENT_PLIST" ]; then
    launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT_PLIST"
    echo "🗑️  Removed launchd agent"
  fi
}

# 启动心跳
start_heartbeat() {
  echo "📋 Starting heartbeat daemon..."

  # 使用 launchd 启动
  create_launchd_agent

  # 触发一次启动
  launchctl start "$LAUNCH_AGENT_LABEL" 2>/dev/null || true

  # 等待启动
  sleep 2

  # 检查状态
  if launchctl list | grep -q "${LAUNCH_AGENT_LABEL}.*running"; then
    echo "✅ Heartbeat daemon started (launchd)"
  else
    echo "⚠️  Launchd agent may not be running, checking directly..."
  fi
}

# 停止心跳
stop_heartbeat() {
  echo "🛑 Stopping heartbeat daemon..."

  # 使用 launchd 停止
  launchctl stop "$LAUNCH_AGENT_LABEL" 2>/dev/null || true

  # 移除配置
  remove_launchd_agent

  # 清理 PID 文件
  rm -f "$HEARTBEAT_PID_FILE"

  echo "✅ Heartbeat daemon stopped"
}

# 启动 Claude Code
start_claude() {
  echo "🚀 Starting Claude Code..."
  echo ""

  # 加载会话记忆
  if [ -x "$MEM_LOAD" ]; then
    "$MEM_LOAD" "$WORKSPACE"
  fi

  echo ""
  echo "🎯 === 准备就绪，启动 Claude Code ==="
  echo ""

  # 设置退出时清理的陷阱
  trap cleanup EXIT INT TERM

  # 启动心跳（后台）
  start_heartbeat

  # 前台启动 Claude Code（会阻塞直到用户退出）
  cd "$WORKSPACE"
  exec claude
}

# 清理函数
cleanup() {
  local exit_code=$?
  echo ""
  echo "👋 Claude Code 已退出，清理资源..."

  # 停止心跳
  stop_heartbeat

  # 清理 PID 文件
  rm -f "$CLAUDE_PID_FILE"

  # 如果是正常退出，记录会话结束
  if [ $exit_code -eq 0 ] && [ -x "$MEM_END" ]; then
    "$MEM_END" "$WORKSPACE" "正常退出" 2>/dev/null || true
  fi

  exit $exit_code
}

# 主命令
case "${1:-start}" in
  start)
    # 检查是否已在运行
    if [ -f "$CLAUDE_PID_FILE" ]; then
      existing_pid=$(cat "$CLAUDE_PID_FILE")
      if ps -p "$existing_pid" > /dev/null 2>&1; then
        echo "✅ Claude Code already running (PID: $existing_pid)"
        exit 0
      else
        rm -f "$CLAUDE_PID_FILE"
      fi
    fi

    # 如果 HEARTBEAT.md 不存在，先复制
    if [ ! -f "$WORKSPACE/HEARTBEAT.md" ] && [ -f "$WORKSPACE/autonomous-kit/personalities/HEARTBEAT.md" ]; then
      cp "$WORKSPACE/autonomous-kit/personalities/HEARTBEAT.md" "$WORKSPACE/"
      echo "✅ HEARTBEAT.md initialized"
    fi

    # 启动
    start_claude
    ;;

  stop)
    echo "🛑 Stopping all..."
    stop_heartbeat

    if [ -f "$CLAUDE_PID_FILE" ]; then
      pid=$(cat "$CLAUDE_PID_FILE")
      if ps -p "$pid" > /dev/null 2>&1; then
        echo "🛑 Stopping Claude Code (PID: $pid)..."
        kill $pid 2>/dev/null || true
        sleep 2
        kill -9 $pid 2>/dev/null || true
      fi
      rm -f "$CLAUDE_PID_FILE"
    fi

    echo "✅ All stopped"
    ;;

  status)
    echo "=== Status ==="
    echo ""

    if [ -f "$CLAUDE_PID_FILE" ]; then
      pid=$(cat "$CLAUDE_PID_FILE")
      if ps -p "$pid" > /dev/null 2>&1; then
        echo "✅ Claude Code Running"
        echo "   PID: $pid"
      else
        echo "❌ Claude Code Not Running (stale PID file)"
        rm -f "$CLAUDE_PID_FILE"
      fi
    else
      echo "⚪️  Claude Code Not Running"
    fi

    echo ""

    if launchctl list | grep -q "${LAUNCH_AGENT_LABEL}.*running"; then
      echo "✅ Heartbeat Daemon Running (launchd)"
    elif [ -f "$HEARTBEAT_PID_FILE" ]; then
      pid=$(cat "$HEARTBEAT_PID_FILE")
      if ps -p "$pid" > /dev/null 2>&1; then
        echo "✅ Heartbeat Daemon Running (PID: $pid)"
      else
        echo "❌ Heartbeat Daemon Not Running (stale PID file)"
        rm -f "$HEARTBEAT_PID_FILE"
      fi
    else
      echo "⚪️  Heartbeat Daemon Not Running"
    fi
    ;;

  heartbeat)
    ./skills/heartbeat/bin/heartbeat-daemon.sh "$@"
    ;;

  *)
    echo "Usage: $0 {start|stop|status|heartbeat}"
    echo ""
    echo "Commands:"
    echo "  start   - Start Claude Code with heartbeat"
    echo "  stop    - Stop both Claude Code and heartbeat"
    echo "  status  - Show running status"
    echo "  heartbeat - Pass through to heartbeat daemon"
    exit 1
    ;;
esac
