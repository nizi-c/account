/**
 * Budget Type Enum
 */
export enum BudgetType {
  MONTHLY = 'monthly',
  WEEKLY = 'weekly',
  CATEGORY = 'category'
}

/**
 * Budget Status Enum
 */
export enum BudgetStatus {
  NORMAL = 'normal',             // < 80%
  WARNING = 'warning',           // 80% - 100%
  EXCEEDED = 'exceeded'          // > 100%
}

/**
 * Budget Model
 * 预算模型
 */
export interface Budget {
  id: number;
  type: BudgetType;              // 月度/周度/分类
  period: string;                // 时间段标识（如"2024-01"或"2024-W01"）
  category?: string;             // 分类预算的分类名称（可选）
  amount: number;                // 预算金额
  spent: number;                 // 已花费金额
  remaining: number;             // 剩余金额
  percentage: number;            // 使用百分比
  status: BudgetStatus;          // 正常/预警/超支
  createdAt: number;
  updatedAt: number;
}
