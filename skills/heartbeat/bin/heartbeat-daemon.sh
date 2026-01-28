#!/bin/bash
# heartbeat-daemon.sh - 心跳守护进程
#
# 用法：
#   ./heartbeat-daemon.sh start    # 启动心跳
#   ./heartbeat-daemon.sh stop     # 停止心跳
#   ./heartbeat-daemon.sh status   # 查看状态
#   ./heartbeat-daemon.sh run      # 手动触发一次心跳

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 从 autonomous-kit/skills/heartbeat/ 向上三级到项目根
WORKSPACE="${WORKSPACE:-$(cd "$SCRIPT_DIR/../../../" && pwd)}"
HEARTBEAT_FILE="$WORKSPACE/HEARTBEAT.md"
STATE_FILE="$WORKSPACE/.heartbeat-state.json"
PID_FILE="$WORKSPACE/.heartbeat.pid"
LOG_FILE="$WORKSPACE/.heartbeat.log"

# 默认间隔：30分钟
INTERVAL="${HEARTBEAT_INTERVAL:-1800}"

# 活动时间窗口（默认 9:00 - 23:00）
ACTIVE_START="${HEARTBEAT_ACTIVE_START:-09:00}"
ACTIVE_END="${HEARTBEAT_ACTIVE_END:-23:00}"

# Claude CLI 配
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CLAUDE_MODEL="${CLAUDE_MODEL:-opus}"

# 心跳 prompt
HEARTBEAT_PROMPT="Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."

# 当前时间（分钟数，用于判断是否在活动窗口）
current_minutes() {
    date +%H%M | awk '{print $1}'
}

# 检查是否在活动时间窗口
is_active_hours() {
    local current=$(current_minutes)
    local start=$(echo "$ACTIVE_START" | tr -d ':' | awk '{print $1}')
    local end=$(echo "$ACTIVE_END" | tr -d ':' | awk '{print $1}')

    [ "$current" -ge "$start" ] && [ "$current" -lt "$end" ]
}

# 执行一次心跳
run_heartbeat() {
    local timestamp=$(date -Iseconds)
    local workspace_for_claude="$WORKSPACE"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 💓 Heartbeat triggered" | tee -a "$LOG_FILE"

    # 检查是否在工作时间
    if ! is_active_hours; then
        echo "  → Outside active hours ($ACTIVE_START - $ACTIVE_END), skipping" | tee -a "$LOG_FILE"
        return 0
    fi

    # 检查 HEARTBEAT.md 是否存在且有内容
    if [ ! -f "$HEARTBEAT_FILE" ]; then
        echo "  → No HEARTBEAT.md found, skipping" | tee -a "$LOG_FILE"
        return 0
    fi

    # 检查文件是否为空
    if [ ! -s "$HEARTBEAT_FILE" ]; then
        echo "  → HEARTBEAT.md is empty, skipping" | tee -a "$LOG_FILE"
        return 0
    fi

    # 调用 Claude CLI
    echo "  → Sending heartbeat prompt to Claude..." | tee -a "$LOG_FILE"

    local response
    response=$($CLAUDE_BIN -p --model "$CLAUDE_MODEL" \
        --add-dir "$workspace_for_claude" \
        --output-format json \
        "$HEARTBEAT_PROMPT" 2>&1)

    # 保存响应
    echo "$response" | jq -r '.content[0].text // empty' >> "$LOG_FILE"

    # 更新状态
    local last_run=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$response" | jq -r \
        --arg last "$last_run" \
        '. + {lastRun: $last}' > "$STATE_FILE"

    # 检查是否是 HEARTBEAT_OK
    if echo "$response" | jq -re '.content[0].text' | grep -q "HEARTBEAT_OK"; then
        echo "  → No tasks pending" | tee -a "$LOG_FILE"
    else
        echo "  → Tasks executed, check log for details" | tee -a "$LOG_FILE"
    fi
}

# 启动守护进程
start_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "❌ Heartbeat daemon already running (PID: $pid)"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi

    echo "🚀 Starting heartbeat daemon..."
    echo "   Workspace: $WORKSPACE"
    echo "   Interval: $INTERVAL seconds"
    echo "   Active hours: $ACTIVE_START - $ACTIVE_END"
    echo "   Log file: $LOG_FILE"

    # 启动循环
    (
        while true; do
            run_heartbeat
            sleep $INTERVAL
        done
    ) &
    local pid=$!
    echo $pid > "$PID_FILE"
    echo "✅ Started (PID: $pid)"
    echo "   Stop with: $0 stop"
}

# 停止守护进程
stop_daemon() {
    if [ ! -f "$PID_FILE" ]; then
        echo "❌ Heartbeat daemon is not running"
        exit 1
    fi

    local pid=$(cat "$PID_FILE")
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "❌ Stale PID file (process not running)"
        rm -f "$PID_FILE"
        exit 1
    fi

    echo "🛑 Stopping heartbeat daemon (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "✅ Stopped"
}

# 查看状态
show_status() {
    echo "=== Heartbeat Daemon Status ==="
    echo ""

    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ Running"
            echo "   PID: $pid"
            echo "   Uptime: $(ps -p "$pid" -o etime= | awk '{print $3}')"
            echo "   Interval: $INTERVAL seconds"
        else
            echo "❌ Stale PID file"
            rm -f "$PID_FILE"
        fi
    else
        echo "⚪️  Not running"
    fi

    echo ""
    echo "=== Configuration ==="
    echo "   Workspace: $WORKSPACE"
    echo "   Active hours: $ACTIVE_START - $ACTIVE_END"
    echo "   HEARTBEAT.md: $([ -f "$HEARTBEAT_FILE" ] && echo "✅ Found" || echo "❌ Not found")"
    echo ""
    echo "=== Last Heartbeat ==="
    if [ -f "$STATE_FILE" ]; then
        local last_run=$(jq -r '.lastRun // "never"' "$STATE_FILE" 2>/dev/null || echo "never")
        echo "   Last run: $last_run"
    else
        echo "   Last run: never"
    fi
}

# 主命令
case "${1:-}" in
    start)
        start_daemon
        ;;
    stop)
        stop_daemon
        ;;
    restart)
        stop_daemon
        sleep 1
        start_daemon
        ;;
    status)
        show_status
        ;;
    run)
        run_heartbeat
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|run}"
        echo ""
        echo "Environment variables:"
        echo "  WORKSPACE              工作区目录 (default: parent directory)"
        echo "  HEARTBEAT_INTERVAL    心跳间隔秒数 (default: 1800 = 30分钟)"
        echo "  HEARTBEAT_ACTIVE_START 活动开始时间 (default: 09:00)"
        echo "  HEARTBEAT_ACTIVE_END   活动结束时间 (default: 23:00)"
        echo "  CLAUDE_BIN             Claude CLI 路径"
        echo "  CLAUDE_MODEL           Claude 模型 (default: opus)"
        echo ""
        echo "Examples:"
        echo "  $0 start              # 启动心跳守护进程"
        echo "  $0 stop               # 停止心跳守护进程"
        echo "  $0 status             # 查看状态"
        echo "  $0 run                # 手动触发一次心跳"
        exit 1
        ;;
esac
