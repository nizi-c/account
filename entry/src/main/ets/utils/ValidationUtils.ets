import { TransactionInput, TransactionType } from '../models';

/**
 * Validation Utilities
 * 数据验证工具类
 */

export class ValidationUtils {
  /**
   * Validate amount (must be positive)
   */
  static isValidAmount(amount: number): boolean {
    return typeof amount === 'number' && !isNaN(amount) && amount > 0;
  }

  /**
   * Validate date timestamp
   */
  static isValidDate(timestamp: number): boolean {
    if (typeof timestamp !== 'number' || isNaN(timestamp)) {
      return false;
    }
    const date = new Date(timestamp);
    return date.getTime() === timestamp && !isNaN(date.getTime());
  }

  /**
   * Validate required string field
   */
  static isValidString(value: string): boolean {
    return typeof value === 'string' && value.trim().length > 0;
  }

  /**
   * Validate transaction input
   */
  static validateTransactionInput(data: TransactionInput): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Validate amount
    if (!this.isValidAmount(data.amount)) {
      errors.push('Amount must be a positive number');
    }

    // Validate date
    if (!this.isValidDate(data.date)) {
      errors.push('Date must be a valid timestamp');
    }

    // Validate category
    if (!this.isValidString(data.category)) {
      errors.push('Category is required');
    }

    // Validate description
    if (!this.isValidString(data.description)) {
      errors.push('Description is required');
    }

    // Validate type
    if (data.type !== TransactionType.INCOME && data.type !== TransactionType.EXPENSE) {
      errors.push('Type must be either income or expense');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }
}
