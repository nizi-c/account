import { TransactionRepository } from '../repositories';
import { Transaction, TransactionInput, TransactionFilter, Summary, TransactionType, PeriodType, CategorySummary } from '../models';
import { ValidationUtils } from '../utils/ValidationUtils';
import { DateUtils } from '../utils/DateUtils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { CacheManager } from '../utils/CacheManager';
import { BudgetService } from './BudgetService';

/**
 * Category accumulator for summary calculation
 */
interface CategoryAccumulator {
  amount: number;
  count: number;
}

/**
 * Transaction Service
 * 交易业务逻辑层
 * 性能优化：使用缓存减少重复计算
 */
export class TransactionService {
  private repository: TransactionRepository;
  private cacheManager: CacheManager;
  private budgetService: BudgetService | null = null;

  constructor(repository: TransactionRepository) {
    this.repository = repository;
    this.cacheManager = CacheManager.getInstance();
  }

  /**
   * Set budget service for automatic budget updates
   * 设置预算服务以自动更新预算
   */
  setBudgetService(budgetService: BudgetService): void {
    this.budgetService = budgetService;
  }

  /**
   * Add a new transaction
   * 添加新交易（包含输入验证）
   * 需求：1.1, 1.4, 12.7
   * 性能优化：添加后清除相关缓存
   * 集成：添加交易后自动更新相关预算进度
   */
  async addTransaction(data: TransactionInput): Promise<Transaction> {
    // Validate input
    const validation = ValidationUtils.validateTransactionInput(data);
    if (!validation.valid) {
      throw ErrorHandler.handleValidationError(
        `输入验证失败: ${validation.errors.join(', ')}`
      );
    }

    try {
      // Create transaction
      const transaction = await this.repository.create(data);
      
      // Invalidate related caches
      this.invalidateRelatedCaches(transaction.date);
      
      // Update budget progress if transaction is an expense
      if (transaction.type === TransactionType.EXPENSE && this.budgetService) {
        await this.updateBudgetsForTransaction(transaction);
      }
      
      return transaction;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'add transaction');
    }
  }

  /**
   * Delete a transaction
   * 删除交易
   * 需求：1.3, 12.7
   * 性能优化：删除后清除相关缓存
   * 集成：删除交易后自动更新相关预算进度
   */
  async deleteTransaction(id: number): Promise<void> {
    try {
      // Get transaction before deleting to update budgets
      const transactions = await this.repository.getAll();
      const transaction = transactions.find(t => t.id === id);
      
      const success = await this.repository.delete(id);
      if (!success) {
        throw ErrorHandler.handleDataInconsistencyError(
          `交易记录不存在 (ID: ${id})`
        );
      }
      
      // Invalidate all caches since we don't know the transaction date
      this.cacheManager.invalidatePattern('summary:.*');
      this.cacheManager.invalidatePattern('chart:.*');
      this.cacheManager.invalidatePattern('transactions:.*');
      
      // Update budget progress if transaction was an expense
      if (transaction && transaction.type === TransactionType.EXPENSE && this.budgetService) {
        await this.updateBudgetsForTransaction(transaction);
      }
    } catch (error) {
      if (error instanceof Error && error.name === 'AppError') {
        throw error;
      }
      throw ErrorHandler.handleDatabaseError(error as Error, 'delete transaction');
    }
  }

  /**
   * Search transactions with filters
   * 多条件查询交易
   * 需求：5.1, 5.2, 5.3, 5.4, 5.5
   */
  async searchTransactions(filter: TransactionFilter): Promise<Transaction[]> {
    return await this.repository.query(filter);
  }

  /**
   * Get daily summary
   * 获取日汇总
   * 需求：3.1, 3.2
   * 性能优化：使用缓存避免重复计算
   */
  async getDailySummary(date: number): Promise<Summary> {
    const startDate = DateUtils.getStartOfDay(date);
    const endDate = DateUtils.getEndOfDay(date);

    // Check cache first
    const cacheKey = CacheManager.generateSummaryKey('day', startDate, endDate);
    const cached = this.cacheManager.get<Summary>(cacheKey);
    if (cached) {
      return cached;
    }

    const transactions = await this.repository.getByDateRange(startDate, endDate);
    const summary = this.calculateSummary(transactions, PeriodType.DAY, startDate, endDate);
    
    // Cache the result (1 minute TTL for daily data)
    this.cacheManager.set(cacheKey, summary, 60 * 1000);
    
    return summary;
  }

  /**
   * Get monthly summary
   * 获取月汇总
   * 需求：3.3, 3.4, 4.2
   * 性能优化：使用缓存避免重复计算
   */
  async getMonthlySummary(year: number, month: number): Promise<Summary> {
    const startDate = DateUtils.getStartOfMonth(year, month);
    const endDate = DateUtils.getEndOfMonth(year, month);

    // Check cache first
    const cacheKey = CacheManager.generateSummaryKey('month', startDate, endDate);
    const cached = this.cacheManager.get<Summary>(cacheKey);
    if (cached) {
      return cached;
    }

    const transactions = await this.repository.getByDateRange(startDate, endDate);
    const summary = this.calculateSummary(transactions, PeriodType.MONTH, startDate, endDate);
    
    // Cache the result (5 minutes TTL for monthly data)
    this.cacheManager.set(cacheKey, summary, 5 * 60 * 1000);
    
    return summary;
  }

  /**
   * Get weekly summary
   * 获取周汇总
   * 需求：4.1
   * 性能优化：使用缓存避免重复计算
   */
  async getWeeklySummary(date: number): Promise<Summary> {
    const startDate = DateUtils.getStartOfWeek(date);
    const endDate = DateUtils.getEndOfWeek(date);

    // Check cache first
    const cacheKey = CacheManager.generateSummaryKey('week', startDate, endDate);
    const cached = this.cacheManager.get<Summary>(cacheKey);
    if (cached) {
      return cached;
    }

    const transactions = await this.repository.getByDateRange(startDate, endDate);
    const summary = this.calculateSummary(transactions, PeriodType.WEEK, startDate, endDate);
    
    // Cache the result (2 minutes TTL for weekly data)
    this.cacheManager.set(cacheKey, summary, 2 * 60 * 1000);
    
    return summary;
  }

  /**
   * Get yearly summary
   * 获取年汇总
   * 需求：4.3
   * 性能优化：使用缓存避免重复计算
   */
  async getYearlySummary(year: number): Promise<Summary> {
    const startDate = DateUtils.getStartOfYear(year);
    const endDate = DateUtils.getEndOfYear(year);

    // Check cache first
    const cacheKey = CacheManager.generateSummaryKey('year', startDate, endDate);
    const cached = this.cacheManager.get<Summary>(cacheKey);
    if (cached) {
      return cached;
    }

    const transactions = await this.repository.getByDateRange(startDate, endDate);
    const summary = this.calculateSummary(transactions, PeriodType.YEAR, startDate, endDate);
    
    // Cache the result (10 minutes TTL for yearly data)
    this.cacheManager.set(cacheKey, summary, 10 * 60 * 1000);
    
    return summary;
  }

  /**
   * Invalidate caches related to a transaction date
   * 清除与交易日期相关的缓存
   * 私有辅助方法
   */
  private invalidateRelatedCaches(transactionDate: number): void {
    const dateObj = new Date(transactionDate);
    const year = dateObj.getFullYear();
    const month = dateObj.getMonth() + 1;
    
    // Invalidate day cache
    const dayStart = DateUtils.getStartOfDay(transactionDate);
    const dayEnd = DateUtils.getEndOfDay(transactionDate);
    this.cacheManager.invalidate(CacheManager.generateSummaryKey('day', dayStart, dayEnd));
    
    // Invalidate week cache
    const weekStart = DateUtils.getStartOfWeek(transactionDate);
    const weekEnd = DateUtils.getEndOfWeek(transactionDate);
    this.cacheManager.invalidate(CacheManager.generateSummaryKey('week', weekStart, weekEnd));
    
    // Invalidate month cache
    const monthStart = DateUtils.getStartOfMonth(year, month);
    const monthEnd = DateUtils.getEndOfMonth(year, month);
    this.cacheManager.invalidate(CacheManager.generateSummaryKey('month', monthStart, monthEnd));
    
    // Invalidate year cache
    const yearStart = DateUtils.getStartOfYear(year);
    const yearEnd = DateUtils.getEndOfYear(year);
    this.cacheManager.invalidate(CacheManager.generateSummaryKey('year', yearStart, yearEnd));
    
    // Invalidate chart caches
    this.cacheManager.invalidatePattern('chart:.*');
  }

  /**
   * Calculate summary from transactions
   * 从交易列表计算汇总数据
   * 私有辅助方法
   */
  private calculateSummary(
    transactions: Transaction[],
    period: PeriodType,
    startDate: number,
    endDate: number
  ): Summary {
    let totalIncome = 0;
    let totalExpense = 0;
    const categoryMap = new Map<string, CategoryAccumulator>();

    // Calculate totals and category breakdown
    for (const transaction of transactions) {
      if (transaction.type === TransactionType.INCOME) {
        totalIncome += transaction.amount;
      } else if (transaction.type === TransactionType.EXPENSE) {
        totalExpense += transaction.amount;
        
        // Track expense categories for breakdown
        const existing = categoryMap.get(transaction.category);
        if (existing) {
          existing.amount += transaction.amount;
          existing.count += 1;
        } else {
          const newCategory: CategoryAccumulator = {
            amount: transaction.amount,
            count: 1
          };
          categoryMap.set(transaction.category, newCategory);
        }
      }
    }

    // Calculate net amount
    const netAmount = totalIncome - totalExpense;

    // Build category breakdown with percentages
    const categoryBreakdown: CategorySummary[] = [];
    if (totalExpense > 0) {
      categoryMap.forEach((data: CategoryAccumulator, category: string) => {
        categoryBreakdown.push({
          category,
          amount: data.amount,
          percentage: (data.amount / totalExpense) * 100,
          count: data.count
        });
      });
    }

    return {
      period,
      startDate,
      endDate,
      totalIncome,
      totalExpense,
      netAmount,
      categoryBreakdown
    };
  }

  /**
   * Get all transactions
   * 获取所有交易
   */
  async getAllTransactions(): Promise<Transaction[]> {
    return await this.repository.getAll();
  }

  /**
   * Get transaction by ID
   * 根据ID获取交易
   */
  async getTransactionById(id: number): Promise<Transaction> {
    const transactions = await this.repository.getAll();
    const transaction = transactions.find(t => t.id === id);
    
    if (!transaction) {
      throw ErrorHandler.handleDataInconsistencyError(
        `交易记录不存在 (ID: ${id})`
      );
    }
    
    return transaction;
  }

  /**
   * Update budgets for a transaction
   * 为交易更新相关预算
   * 需求：12.7
   * 私有辅助方法
   */
  private async updateBudgetsForTransaction(transaction: Transaction): Promise<void> {
    if (!this.budgetService) {
      return;
    }

    try {
      const dateObj = new Date(transaction.date);
      const year = dateObj.getFullYear();
      const month = dateObj.getMonth() + 1;
      const week = DateUtils.getWeekNumber(transaction.date);

      // Update monthly budget
      const monthlyPeriod = `${year}-${String(month).padStart(2, '0')}`;
      await this.budgetService.updateBudgetProgress(monthlyPeriod);

      // Update weekly budget
      const weeklyPeriod = `${year}-W${String(week).padStart(2, '0')}`;
      await this.budgetService.updateBudgetProgress(weeklyPeriod);
    } catch (error) {
      // Log error but don't fail the transaction
      console.error('Failed to update budget progress:', error);
    }
  }
}
