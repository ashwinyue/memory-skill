#!/bin/bash
# lib.sh - 共享函数

# 确保每日日志文件存在并有正确的头部
ensure_daily_log() {
  local FILE="$1"
  local DATE="$2"

  if [ ! -f "$FILE" ]; then
    echo "# $DATE" > "$FILE"
    echo "" >> "$FILE"
  fi
}

# 获取当前工作区（优先使用当前目录）
get_workspace() {
  echo "${WORKSPACE:-.}"
}
