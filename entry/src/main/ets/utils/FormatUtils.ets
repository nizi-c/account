/**
 * Format Utilities
 * 格式化工具类
 */

export class FormatUtils {
  /**
   * Format currency amount
   * @param amount - The amount to format
   * @param currency - Currency symbol (default: ¥)
   * @returns Formatted currency string (e.g., "¥1,234.56")
   */
  static formatCurrency(amount: number, currency: string = '¥'): string {
    const formatted = FormatUtils.formatNumber(amount, 2);
    return `${currency}${formatted}`;
  }

  /**
   * Format percentage
   * @param value - The value to format (0-1 or 0-100)
   * @param decimals - Number of decimal places (default: 2)
   * @returns Formatted percentage string (e.g., "45.67%")
   */
  static formatPercentage(value: number, decimals: number = 2): string {
    // If value is between 0 and 1, treat as decimal (multiply by 100)
    // If value is greater than 1, treat as already in percentage form
    const percentage = value <= 1 ? value * 100 : value;
    return `${percentage.toFixed(decimals)}%`;
  }

  /**
   * Format number with thousand separators
   * @param value - The number to format
   * @param decimals - Number of decimal places (default: 2)
   * @returns Formatted number string (e.g., "1,234.56")
   */
  static formatNumber(value: number, decimals: number = 2): string {
    // Round to specified decimal places
    const fixed = value.toFixed(decimals);
    
    // Split into integer and decimal parts
    const parts = fixed.split('.');
    const integerPart = parts[0];
    const decimalPart = parts[1];
    
    // Add thousand separators to integer part
    const withSeparators = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    
    // Combine with decimal part
    return decimalPart ? `${withSeparators}.${decimalPart}` : withSeparators;
  }
}
