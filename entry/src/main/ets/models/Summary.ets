/**
 * Period Type Enum
 */
export enum PeriodType {
  DAY = 'day',
  WEEK = 'week',
  MONTH = 'month',
  YEAR = 'year'
}

/**
 * Category Summary
 * 分类汇总
 */
export interface CategorySummary {
  category: string;
  amount: number;
  percentage: number;
  count: number;
}

/**
 * Summary Model
 * 汇总统计模型
 */
export interface Summary {
  period: PeriodType;
  startDate: number;
  endDate: number;
  totalIncome: number;
  totalExpense: number;
  netAmount: number;
  categoryBreakdown: CategorySummary[];
}
