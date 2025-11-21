import { Transaction } from './Transaction';
import { Category } from './Category';
import { Achievement } from './Achievement';
import { Budget } from './Budget';

/**
 * Export Data Model
 * 导出数据模型
 */
export interface ExportData {
  version: string;               // 数据版本
  exportDate: number;            // 导出时间
  transactions: Transaction[];
  categories: Category[];
  achievements: Achievement[];
  budgets?: Budget[];
}
