import { TransactionType } from './Transaction';

/**
 * Category Model
 * 分类模型
 */
export interface Category {
  id: string;
  name: string;
  type: TransactionType;
  icon: string;                  // 图标资源路径
  color: string;                 // 分类颜色
}
