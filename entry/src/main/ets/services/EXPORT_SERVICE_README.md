# ExportService 使用说明

## 概述

ExportService 提供数据导出功能，支持将交易记录导出为 CSV 或 JSON 格式，并保存到用户可访问的目录。

## 功能特性

### 1. CSV 导出
- 支持导出所有交易记录或指定日期范围的记录
- CSV 格式包含表头：日期、类型、分类、金额、用途、情绪
- 自动处理特殊字符（逗号、引号、换行符）
- 情绪标签显示为中文（满意😊、后悔😟、惊喜🎉）

### 2. JSON 导出
- 支持导出所有交易记录或指定日期范围的记录
- 包含完整的数据结构和元数据
- 包含版本信息和导出时间戳

### 3. 完整备份
- 导出所有交易记录
- 导出所有分类定义
- 导出所有成就数据
- 导出所有预算数据（如果存在）

### 4. 文件保存
- 保存到应用的 filesDir（用户可访问）
- 支持错误重试机制（最多3次）
- 使用指数退避策略进行重试

## 使用示例

### 初始化服务

```typescript
import { ExportService } from '../services';
import { TransactionRepository, CategoryRepository, AchievementRepository, BudgetRepository } from '../repositories';
import { common } from '@kit.AbilityKit';

// 获取 context
const context = getContext(this) as common.UIAbilityContext;

// 创建服务实例
const exportService = new ExportService(
  transactionRepo,
  categoryRepo,
  achievementRepo,
  budgetRepo,
  context
);
```

### 导出为 CSV

```typescript
// 导出所有交易
const csvContent = await exportService.exportToCSV();

// 导出指定日期范围的交易
const startDate = Date.now() - 30 * 24 * 60 * 60 * 1000; // 30天前
const endDate = Date.now();
const csvContent = await exportService.exportToCSV(startDate, endDate);

// 保存 CSV 文件
const filePath = await exportService.saveExportFile(
  csvContent,
  'transactions_export',
  'csv'
);
console.log('文件已保存到:', filePath);
```

### 导出为 JSON

```typescript
// 导出所有交易
const exportData = await exportService.exportToJSON();

// 导出指定日期范围的交易
const exportData = await exportService.exportToJSON(startDate, endDate);

// 保存 JSON 文件
const jsonContent = JSON.stringify(exportData, null, 2);
const filePath = await exportService.saveExportFile(
  jsonContent,
  'transactions_export',
  'json'
);
```

### 生成完整备份

```typescript
// 生成完整备份
const backupData = await exportService.generateFullBackup();

// 保存备份文件
const backupContent = JSON.stringify(backupData, null, 2);
const filePath = await exportService.saveExportFile(
  backupContent,
  `backup_${Date.now()}`,
  'json'
);
```

## CSV 格式说明

### 表头
```
日期,类型,分类,金额,用途,情绪
```

### 数据行示例
```
2024-01-15,支出,餐饮,35.50,午餐,满意😊
2024-01-15,收入,工资,5000.00,月薪,
2024-01-14,支出,交通,12.00,"地铁, 公交",
```

### 特殊字符处理
- 包含逗号的字段会被引号包围
- 字段内的引号会被转义为双引号
- 换行符会被保留在引号内

## JSON 格式说明

### 数据结构
```typescript
{
  "version": "1.0.0",           // 数据版本
  "exportDate": 1705305600000,  // 导出时间戳
  "transactions": [...],         // 交易记录数组
  "categories": [...],           // 分类定义数组
  "achievements": [...],         // 成就数据数组
  "budgets": [...]              // 预算数据数组（可选）
}
```

## 错误处理

### 常见错误

1. **Context 未初始化**
   - 错误信息：`Context未初始化，无法保存文件`
   - 解决方法：确保在创建 ExportService 时传入有效的 context

2. **文件保存失败**
   - 错误信息：`文件保存失败: [具体错误]`
   - 解决方法：检查文件权限和存储空间

3. **数据导出失败**
   - 错误信息：`CSV导出失败` 或 `JSON导出失败`
   - 解决方法：检查数据库连接和数据完整性

### 重试机制

文件保存操作会自动重试最多3次，使用指数退避策略：
- 第1次重试：等待 100ms
- 第2次重试：等待 200ms
- 第3次重试：等待 400ms

## 性能考虑

1. **大数据集导出**
   - 对于大量交易记录，导出操作可能需要较长时间
   - 建议在后台线程执行导出操作
   - 可以使用日期范围过滤来减少数据量

2. **内存使用**
   - CSV 和 JSON 内容会完全加载到内存中
   - 对于超大数据集，考虑分批导出

3. **文件大小**
   - CSV 格式通常比 JSON 格式更紧凑
   - JSON 格式包含更多元数据，文件会更大

## 最佳实践

1. **定期备份**
   - 建议用户定期使用完整备份功能
   - 可以设置自动备份提醒

2. **导出前验证**
   - 在导出前检查数据完整性
   - 确保有足够的存储空间

3. **用户反馈**
   - 导出操作显示进度指示器
   - 成功后显示文件保存位置
   - 失败时提供明确的错误信息和重试选项

4. **文件命名**
   - 使用有意义的文件名（包含日期范围）
   - 示例：`transactions_2024-01_to_2024-03.csv`

## 相关需求

- 需求 13.1: 提供CSV和JSON两种导出格式选项
- 需求 13.2: 生成包含所有交易记录的CSV文件
- 需求 13.3: 生成包含所有交易记录和元数据的JSON文件
- 需求 13.4: 将文件保存到用户可访问的目录
- 需求 13.5: 支持日期范围导出
- 需求 13.6: CSV文件包含表头
- 需求 13.7: 导出失败时显示错误信息并提供重试选项
- 需求 13.8: 导出分类定义和成就数据以支持完整备份
