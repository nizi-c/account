# 错误处理和用户反馈指南

本指南介绍应用中的错误处理和用户反馈系统的使用方法。

## 概述

错误处理系统包含以下核心组件：

1. **ErrorHandler** - 全局错误处理器
2. **Toast** - 消息提示组件
3. **LoadingIndicator** - 加载指示器组件
4. **ErrorDisplay** - 错误显示组件
5. **EmptyState** - 空状态组件
6. **ErrorPage** - 错误页面组件

## 1. ErrorHandler（全局错误处理器）

### 错误类型

```typescript
enum ErrorType {
  VALIDATION = 'validation',           // 输入验证错误
  DATABASE = 'database',               // 数据库操作错误
  NETWORK = 'network',                 // 网络错误
  DATA_INCONSISTENCY = 'data_inconsistency', // 数据不一致错误
  UNKNOWN = 'unknown'                  // 未知错误
}
```

### 基本使用

```typescript
import { ErrorHandler, AppError } from '../utils/ErrorHandler';

// 处理通用错误
try {
  // 某些操作
} catch (error) {
  ErrorHandler.handle(error as Error);
}

// 处理验证错误
ErrorHandler.handleValidationError('金额必须大于0', 'amount');

// 处理数据库错误
try {
  await repository.save(data);
} catch (error) {
  ErrorHandler.handleDatabaseError(error as Error, 'save data');
}

// 处理数据不一致错误
ErrorHandler.handleDataInconsistencyError('数据格式异常', { details });
```

### 包装异步操作

```typescript
// 自动处理错误的异步操作
const result = await ErrorHandler.wrapAsync(
  async () => {
    return await someAsyncOperation();
  },
  '操作失败',
  true  // 是否显示给用户
);

if (result === null) {
  // 操作失败
}
```

### 包装同步操作

```typescript
const result = ErrorHandler.wrapSync(
  () => {
    return someSyncOperation();
  },
  '操作失败'
);
```

## 2. Toast（消息提示）

### 基本使用

```typescript
import { Toast } from '../components/Toast';

// 成功提示
Toast.success('保存成功');

// 错误提示
Toast.error('保存失败');

// 警告提示
Toast.warning('请注意');

// 信息提示
Toast.info('这是一条信息');

// 自定义配置
Toast.show({
  message: '自定义消息',
  type: ToastType.SUCCESS,
  duration: 3000,
  bottom: 150
});
```

## 3. LoadingIndicator（加载指示器）

### 基本加载指示器

```typescript
import { LoadingIndicator } from '../components/LoadingIndicator';

@Component
struct MyComponent {
  @State isLoading: boolean = false;

  build() {
    if (this.isLoading) {
      LoadingIndicator({ 
        message: '加载中...',
        size: 48,
        color: ThemeColors.primary
      })
    }
  }
}
```

### 全屏加载

```typescript
import { FullScreenLoading } from '../components/LoadingIndicator';

if (this.showFullScreenLoading) {
  FullScreenLoading({ message: '处理中，请稍候...' })
}
```

### 内联加载

```typescript
import { InlineLoading } from '../components/LoadingIndicator';

InlineLoading({ 
  message: '正在加载...',
  size: 24
})
```

## 4. ErrorDisplay（错误显示）

### 错误显示组件

```typescript
import { ErrorDisplay } from '../components/ErrorDisplay';

ErrorDisplay({
  message: '加载失败',
  description: '无法连接到服务器',
  showRetry: true,
  onRetry: () => {
    // 重试逻辑
    this.loadData();
  }
})
```

### 空状态组件

```typescript
import { EmptyState } from '../components/ErrorDisplay';

EmptyState({
  message: '暂无数据',
  description: '点击下方按钮添加数据',
  icon: '📭',
  actionText: '添加',
  onAction: () => {
    // 添加逻辑
  }
})
```

### 内联错误提示

```typescript
import { InlineError } from '../components/ErrorDisplay';

if (this.hasError) {
  InlineError({
    message: '金额不能为空',
    showIcon: true
  })
}
```

### 错误页面

```typescript
import { ErrorPage } from '../components/ErrorDisplay';

ErrorPage({
  title: '出错了',
  message: '页面加载失败',
  errorCode: 'ERR_500',
  showRetry: true,
  showBack: true,
  onRetry: () => {
    // 重试逻辑
  },
  onBack: () => {
    router.back();
  }
})
```

## 5. 在服务层集成错误处理

### Repository 层

```typescript
import { ErrorHandler } from '../utils/ErrorHandler';

class MyRepository {
  async create(data: any): Promise<any> {
    try {
      // 数据库操作
      return await store.insert(data);
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'create record');
    }
  }
}
```

### Service 层

```typescript
import { ErrorHandler } from '../utils/ErrorHandler';
import { ValidationUtils } from '../utils/ValidationUtils';

class MyService {
  async addItem(data: any): Promise<any> {
    // 验证输入
    const validation = ValidationUtils.validate(data);
    if (!validation.valid) {
      throw ErrorHandler.handleValidationError(
        `验证失败: ${validation.errors.join(', ')}`
      );
    }

    try {
      return await this.repository.create(data);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;  // 已经处理过的错误
      }
      throw ErrorHandler.handleDatabaseError(error as Error, 'add item');
    }
  }
}
```

## 6. 在页面中集成错误处理

### 完整示例

```typescript
import { Toast } from '../components/Toast';
import { ErrorHandler, AppError } from '../utils/ErrorHandler';
import { LoadingIndicator, ErrorDisplay } from '../components';

@Component
struct MyPage {
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State data: any[] = [];

  async aboutToAppear() {
    await this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.hasError = false;

    try {
      this.data = await this.service.getData();
    } catch (error) {
      this.hasError = true;
      if (error instanceof AppError) {
        this.errorMessage = error.message;
      } else {
        ErrorHandler.handle(error as Error);
        this.errorMessage = '加载失败';
      }
    } finally {
      this.isLoading = false;
    }
  }

  async saveData() {
    try {
      await this.service.save(this.formData);
      Toast.success('保存成功');
    } catch (error) {
      if (error instanceof AppError) {
        // 错误已经被 ErrorHandler 处理并显示
      } else {
        ErrorHandler.handle(error as Error);
        Toast.error('保存失败');
      }
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingIndicator({ message: '加载中...' })
      } else if (this.hasError) {
        ErrorDisplay({
          message: this.errorMessage,
          showRetry: true,
          onRetry: () => this.loadData()
        })
      } else if (this.data.length === 0) {
        EmptyState({
          message: '暂无数据',
          actionText: '添加',
          onAction: () => this.addData()
        })
      } else {
        // 显示数据
        List() {
          ForEach(this.data, (item) => {
            ListItem() {
              // 渲染项目
            }
          })
        }
      }
    }
  }
}
```

## 7. 最佳实践

### 1. 错误处理层次

- **Repository 层**：捕获数据库错误，转换为 AppError
- **Service 层**：处理业务逻辑错误和验证错误
- **Page 层**：显示错误给用户，提供重试选项

### 2. 用户反馈

- 使用 Toast 显示简短的成功/失败消息
- 使用 ErrorDisplay 显示可重试的错误
- 使用 EmptyState 显示空数据状态
- 使用 LoadingIndicator 显示加载状态

### 3. 错误日志

所有错误都会自动记录到系统日志中，包括：
- 错误类型
- 错误消息
- 错误代码
- 详细信息
- 堆栈跟踪

### 4. 错误恢复

- 提供重试按钮用于可恢复的错误
- 保留用户输入数据，避免重新输入
- 提供返回按钮用于不可恢复的错误

## 8. 演示页面

查看 `ErrorHandlingDemo.ets` 页面了解所有组件的实际使用示例。

## 需求映射

本错误处理系统满足以下需求：

- **需求 11.3**：数据保存失败处理
  - 使用 ErrorHandler.handleDatabaseError
  - 显示错误提示并保留用户输入

- **需求 11.4**：数据加载失败处理和重试
  - 使用 ErrorDisplay 组件显示错误
  - 提供重试按钮重新加载数据
