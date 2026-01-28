# 代码模式

> 项目中常用的设计模式和惯用法

## 依赖注入

### createDefaultDeps 模式
```typescript
// 用于创建可测试的依赖
export function createDefaultDeps(opts?: Partial<Deps>) {
  return {
    logger: console,
    fs: fsPromises,
    clock: Date.now,
    ...opts,
  };
}
```

**用途**: CLI 命令的依赖注入，便于测试和模拟

## CLI 选项模式

```typescript
// 使用统一的选项解析
export const myCommandOptions = {
  force: {
    type: "boolean",
    description: "强制执行，跳过确认",
  },
  output: {
    type: "string",
    description: "输出格式 (json|text)",
    default: "text",
  },
} as const;
```

## 进度显示

```typescript
// 使用 src/cli/progress.ts 的 osc-progress
import { createSpinner, createProgressBar } from "./progress.js";

const spinner = createSpinner("处理中...");
const progress = createProgressBar({ total: items.length });
```

**注意**: 不要手写 spinner/bar

## 错误处理

```typescript
// 统一的错误格式
export class MoltbotError extends Error {
  constructor(
    message: string,
    public code: string,
    public details?: unknown,
  ) {
    super(message);
    this.name = "MoltbotError";
  }
}
```

## 配置文件模式

### 按首字母排序
```json
{
  "dependencies": {
    "@clack/prompts": "^0.7.0",
    "chalk": "^5.3.0",
    "oxide": "latest"
  }
}
```

### 依赖版本规则
- 核心依赖: 精确版本 (pnpm.patchedDependencies)
- 普通依赖: `^` 前缀允许 minor 更新
- 开发依赖: `^` 前缀

---

## 模板

```markdown
## [模式名称]

### 描述
[简要说明]

### 代码示例
\`\`\`typescript
[示例代码]
\`\`\`

### 用途
[何时使用]
```
