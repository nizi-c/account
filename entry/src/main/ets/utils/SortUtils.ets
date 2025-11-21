import { Transaction } from '../models';

/**
 * Sort Utilities
 * 排序工具类
 */

export class SortUtils {
  /**
   * Sort transactions by date (descending - newest first)
   * @param transactions - Array of transactions to sort
   * @returns New sorted array (does not modify original)
   */
  static sortByDateDesc(transactions: Transaction[]): Transaction[] {
    return [...transactions].sort((a, b) => b.date - a.date);
  }

  /**
   * Sort transactions by date (ascending - oldest first)
   * @param transactions - Array of transactions to sort
   * @returns New sorted array (does not modify original)
   */
  static sortByDateAsc(transactions: Transaction[]): Transaction[] {
    return [...transactions].sort((a, b) => a.date - b.date);
  }

  /**
   * Sort transactions by amount (descending)
   * @param transactions - Array of transactions to sort
   * @returns New sorted array (does not modify original)
   */
  static sortByAmountDesc(transactions: Transaction[]): Transaction[] {
    return [...transactions].sort((a, b) => b.amount - a.amount);
  }

  /**
   * Sort transactions by amount (ascending)
   * @param transactions - Array of transactions to sort
   * @returns New sorted array (does not modify original)
   */
  static sortByAmountAsc(transactions: Transaction[]): Transaction[] {
    return [...transactions].sort((a, b) => a.amount - b.amount);
  }
}
