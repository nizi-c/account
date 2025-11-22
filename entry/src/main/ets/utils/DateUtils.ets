/**
 * Date Utilities
 * 日期工具类
 */

export class DateUtils {
  /**
   * Format timestamp to date string
   */
  static formatDate(timestamp: number, format: string = 'YYYY-MM-DD'): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    return format
      .replace('YYYY', String(year))
      .replace('MM', month)
      .replace('DD', day);
  }

  /**
   * Get start of day timestamp
   */
  static getStartOfDay(timestamp: number): number {
    const date = new Date(timestamp);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }

  /**
   * Get end of day timestamp
   */
  static getEndOfDay(timestamp: number): number {
    const date = new Date(timestamp);
    date.setHours(23, 59, 59, 999);
    return date.getTime();
  }

  /**
   * Get start of week timestamp (Monday)
   */
  static getStartOfWeek(timestamp: number): number {
    const date = new Date(timestamp);
    const day = date.getDay();
    const diff = day === 0 ? -6 : 1 - day; // Adjust when day is Sunday
    date.setDate(date.getDate() + diff);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }

  /**
   * Get end of week timestamp (Sunday)
   */
  static getEndOfWeek(timestamp: number): number {
    const startOfWeek = DateUtils.getStartOfWeek(timestamp);
    const date = new Date(startOfWeek);
    date.setDate(date.getDate() + 6);
    date.setHours(23, 59, 59, 999);
    return date.getTime();
  }

  /**
   * Get start of month timestamp
   */
  static getStartOfMonth(year: number, month: number): number {
    const date = new Date(year, month - 1, 1, 0, 0, 0, 0);
    return date.getTime();
  }

  /**
   * Get end of month timestamp
   */
  static getEndOfMonth(year: number, month: number): number {
    const date = new Date(year, month, 0, 23, 59, 59, 999);
    return date.getTime();
  }

  /**
   * Get start of year timestamp
   */
  static getStartOfYear(year: number): number {
    const date = new Date(year, 0, 1, 0, 0, 0, 0);
    return date.getTime();
  }

  /**
   * Get end of year timestamp
   */
  static getEndOfYear(year: number): number {
    const date = new Date(year, 11, 31, 23, 59, 59, 999);
    return date.getTime();
  }

  /**
   * Check if date is in range
   */
  static isInRange(date: number, startDate: number, endDate: number): boolean {
    return date >= startDate && date <= endDate;
  }

  /**
   * Get current timestamp
   */
  static now(): number {
    return Date.now();
  }

  /**
   * Get year from timestamp
   */
  static getYear(timestamp: number): number {
    return new Date(timestamp).getFullYear();
  }

  /**
   * Get month from timestamp (1-12)
   */
  static getMonth(timestamp: number): number {
    return new Date(timestamp).getMonth() + 1;
  }

  /**
   * Get day from timestamp (1-31)
   */
  static getDay(timestamp: number): number {
    return new Date(timestamp).getDate();
  }

  /**
   * Get week number of the year
   */
  static getWeekNumber(timestamp: number): number {
    const date = new Date(timestamp);
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000;
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);
  }

  /**
   * Format timestamp to datetime string
   */
  static formatDateTime(timestamp: number, format: string = 'YYYY-MM-DD HH:mm:ss'): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return format
      .replace('YYYY', String(year))
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  }

  /**
   * Check if two timestamps are on the same day
   */
  static isSameDay(timestamp1: number, timestamp2: number): boolean {
    const date1 = new Date(timestamp1);
    const date2 = new Date(timestamp2);
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate();
  }

  /**
   * Add days to timestamp
   */
  static addDays(timestamp: number, days: number): number {
    const date = new Date(timestamp);
    date.setDate(date.getDate() + days);
    return date.getTime();
  }

  /**
   * Add months to timestamp
   */
  static addMonths(timestamp: number, months: number): number {
    const date = new Date(timestamp);
    date.setMonth(date.getMonth() + months);
    return date.getTime();
  }

  /**
   * Get days in month
   */
  static getDaysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate();
  }
}
