/**
 * Transaction Type Enum
 */
export enum TransactionType {
  INCOME = 'income',
  EXPENSE = 'expense'
}

/**
 * Mood Type Enum
 */
export enum MoodType {
  SATISFIED = 'satisfied',  // 😊满意
  REGRET = 'regret',        // 😟后悔
  SURPRISE = 'surprise'     // 🎉惊喜
}

/**
 * Transaction Model
 * 交易记录模型
 */
export interface Transaction {
  id: number;                    // 主键
  type: TransactionType;         // 收入/支出
  amount: number;                // 金额
  category: string;              // 分类
  description: string;           // 用途描述
  date: number;                  // 时间戳
  mood?: MoodType;               // 情绪标签（可选）
  createdAt: number;             // 创建时间
  updatedAt: number;             // 更新时间
}

/**
 * Transaction Input (for creating new transactions)
 */
export interface TransactionInput {
  type: TransactionType;
  amount: number;
  category: string;
  description: string;
  date: number;
  mood?: MoodType;
}

/**
 * Transaction Filter (for querying transactions)
 */
export interface TransactionFilter {
  type?: TransactionType;
  categories?: string[];
  minAmount?: number;
  maxAmount?: number;
  startDate?: number;
  endDate?: number;
  description?: string;
  mood?: MoodType;
}
