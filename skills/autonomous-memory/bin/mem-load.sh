#!/bin/bash
# mem-load.sh - 加载所有记忆文件

WORKSPACE="${1:-.}"
TODAY=$(date +%Y-%m-%d)

echo "📚 正在加载记忆文件..."
echo ""

# 加载 SOUL.md
if [ -f "$WORKSPACE/SOUL.md" ]; then
  echo "## SOUL.md - 人格"
  echo '---'
  cat "$WORKSPACE/SOUL.md"
  echo ""
  echo ""
fi

# 加载 USER.md
if [ -f "$WORKSPACE/USER.md" ]; then
  echo "## USER.md - 用户"
  echo '---'
  cat "$WORKSPACE/USER.md"
  echo ""
  echo ""
fi

# 加载 AGENTS.md
if [ -f "$WORKSPACE/AGENTS.md" ]; then
  echo "## AGENTS.md - 工作区"
  echo '---'
  head -100 "$WORKSPACE/AGENTS.md"  # 只显示前100行
  echo ""
  echo ""
fi

# 加载今日日志
if [ -f "$WORKSPACE/memory/$TODAY.md" ]; then
  echo "## 今日日志 ($TODAY)"
  echo '---'
  cat "$WORKSPACE/memory/$TODAY.md"
  echo ""
  echo ""
fi

# 加载 MEMORY.md（可选，太大时跳过）
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  SIZE=$(wc -c < "$WORKSPACE/MEMORY.md" 2>/dev/null || echo 0)
  if [ "$SIZE" -lt 10000 ]; then
    echo "## MEMORY.md - 长期记忆"
    echo '---'
    cat "$WORKSPACE/MEMORY.md"
  else
    echo "## MEMORY.md - 长期记忆 (文件较大，使用 /mem-read MEMORY.md 查看)"
  fi
fi

echo ""
echo "✅ 记忆加载完成"
