import { BudgetRepository, TransactionRepository } from '../repositories';
import type { BudgetCreateData } from '../repositories/BudgetRepository';
import { Budget, BudgetStatus, BudgetType, TransactionType } from '../models';
import { DateUtils } from '../utils';

/**
 * Budget Service
 * 预算业务逻辑层
 */
export class BudgetService {
  private repository: BudgetRepository;
  private transactionRepository: TransactionRepository;

  constructor(repository: BudgetRepository, transactionRepository: TransactionRepository) {
    this.repository = repository;
    this.transactionRepository = transactionRepository;
  }

  /**
   * Set monthly budget
   * 设置月度预算
   */
  async setMonthlyBudget(year: number, month: number, amount: number): Promise<Budget> {
    // Format period as "YYYY-MM"
    const period = `${year}-${String(month).padStart(2, '0')}`;
    
    // Check if budget already exists
    const existingBudget = await this.repository.getMonthlyBudget(period);
    
    if (existingBudget) {
      // Update existing budget
      return await this.repository.update(existingBudget.id, {
        amount: amount,
        remaining: amount - existingBudget.spent,
        percentage: existingBudget.spent > 0 ? (existingBudget.spent / amount) * 100 : 0,
        status: this.calculateBudgetStatus(existingBudget.spent, amount)
      });
    } else {
      // Create new budget
      const newBudget: BudgetCreateData = {
        type: BudgetType.MONTHLY,
        period: period,
        amount: amount,
        spent: 0,
        remaining: amount,
        percentage: 0,
        status: BudgetStatus.NORMAL
      };
      
      const created = await this.repository.create(newBudget);
      
      // Update progress with actual transactions
      await this.updateBudgetProgress(period);
      
      // Return updated budget
      return await this.repository.getMonthlyBudget(period) || created;
    }
  }

  /**
   * Set weekly budget
   * 设置周度预算
   */
  async setWeeklyBudget(year: number, week: number, amount: number): Promise<Budget> {
    // Format period as "YYYY-W##"
    const period = `${year}-W${String(week).padStart(2, '0')}`;
    
    // Check if budget already exists
    const existingBudget = await this.repository.getWeeklyBudget(period);
    
    if (existingBudget) {
      // Update existing budget
      return await this.repository.update(existingBudget.id, {
        amount: amount,
        remaining: amount - existingBudget.spent,
        percentage: existingBudget.spent > 0 ? (existingBudget.spent / amount) * 100 : 0,
        status: this.calculateBudgetStatus(existingBudget.spent, amount)
      });
    } else {
      // Create new budget
      const newBudget: BudgetCreateData = {
        type: BudgetType.WEEKLY,
        period: period,
        amount: amount,
        spent: 0,
        remaining: amount,
        percentage: 0,
        status: BudgetStatus.NORMAL
      };
      
      const created = await this.repository.create(newBudget);
      
      // Update progress with actual transactions
      await this.updateBudgetProgress(period);
      
      // Return updated budget
      return await this.repository.getWeeklyBudget(period) || created;
    }
  }

  /**
   * Set category budget
   * 设置分类预算
   */
  async setCategoryBudget(period: string, category: string, amount: number): Promise<Budget> {
    // Check if category budget already exists
    const existingBudgets = await this.repository.getCategoryBudgets(period);
    const existingBudget = existingBudgets.find(b => b.category === category);
    
    if (existingBudget) {
      // Update existing budget
      return await this.repository.update(existingBudget.id, {
        amount: amount,
        remaining: amount - existingBudget.spent,
        percentage: existingBudget.spent > 0 ? (existingBudget.spent / amount) * 100 : 0,
        status: this.calculateBudgetStatus(existingBudget.spent, amount)
      });
    } else {
      // Create new budget
      const newBudget: BudgetCreateData = {
        type: BudgetType.CATEGORY,
        period: period,
        category: category,
        amount: amount,
        spent: 0,
        remaining: amount,
        percentage: 0,
        status: BudgetStatus.NORMAL
      };
      
      const created = await this.repository.create(newBudget);
      
      // Update progress with actual transactions
      await this.updateBudgetProgress(period);
      
      // Return updated budget
      const updatedBudgets = await this.repository.getCategoryBudgets(period);
      return updatedBudgets.find(b => b.category === category) || created;
    }
  }

  /**
   * Get budget status
   * 获取预算状态
   */
  async getBudgetStatus(budgetId: number): Promise<BudgetStatus> {
    const budgets = await this.repository.getAll();
    const budget = budgets.find(b => b.id === budgetId);
    
    if (!budget) {
      throw new Error(`Budget with id ${budgetId} not found`);
    }
    
    return budget.status;
  }

  /**
   * Update budget progress
   * 根据交易自动更新预算进度
   */
  async updateBudgetProgress(period: string): Promise<void> {
    // Determine if this is a monthly or weekly period
    const isMonthly = /^\d{4}-\d{2}$/.test(period);
    const isWeekly = /^\d{4}-W\d{2}$/.test(period);
    
    if (isMonthly) {
      await this.updateMonthlyBudgetProgress(period);
    } else if (isWeekly) {
      await this.updateWeeklyBudgetProgress(period);
    }
    
    // Always update category budgets for this period
    await this.updateCategoryBudgetsProgress(period);
  }

  /**
   * Update monthly budget progress
   */
  private async updateMonthlyBudgetProgress(period: string): Promise<void> {
    const budget = await this.repository.getMonthlyBudget(period);
    if (!budget) {
      return;
    }
    
    // Parse period to get year and month
    const parts = period.split('-');
    const year = Number(parts[0]);
    const month = Number(parts[1]);
    
    // Get date range for the month
    const startDate = DateUtils.getStartOfMonth(year, month);
    const endDate = DateUtils.getEndOfMonth(year, month);
    
    // Get all expense transactions in this period
    const transactions = await this.transactionRepository.query({
      type: TransactionType.EXPENSE,
      startDate: startDate,
      endDate: endDate
    });
    
    // Calculate total spent
    const spent = transactions.reduce((sum, t) => sum + t.amount, 0);
    const remaining = budget.amount - spent;
    const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
    const status = this.calculateBudgetStatus(spent, budget.amount);
    
    // Update budget
    await this.repository.update(budget.id, {
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      status: status
    });
  }

  /**
   * Update weekly budget progress
   */
  private async updateWeeklyBudgetProgress(period: string): Promise<void> {
    const budget = await this.repository.getWeeklyBudget(period);
    if (!budget) {
      return;
    }
    
    // Parse period to get year and week
    const match = period.match(/^(\d{4})-W(\d{2})$/);
    if (!match) {
      return;
    }
    
    const year = parseInt(match[1]);
    const week = parseInt(match[2]);
    
    // Calculate the start date of the week
    // Week 1 is the week containing January 4th
    const jan4 = new Date(year, 0, 4);
    const jan4Day = jan4.getDay() || 7; // Sunday = 7
    const weekStart = new Date(jan4.getTime());
    weekStart.setDate(jan4.getDate() - jan4Day + 1 + (week - 1) * 7);
    weekStart.setHours(0, 0, 0, 0);
    
    const startDate = weekStart.getTime();
    const endDate = DateUtils.getEndOfWeek(startDate);
    
    // Get all expense transactions in this period
    const transactions = await this.transactionRepository.query({
      type: TransactionType.EXPENSE,
      startDate: startDate,
      endDate: endDate
    });
    
    // Calculate total spent
    const spent = transactions.reduce((sum, t) => sum + t.amount, 0);
    const remaining = budget.amount - spent;
    const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
    const status = this.calculateBudgetStatus(spent, budget.amount);
    
    // Update budget
    await this.repository.update(budget.id, {
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      status: status
    });
  }

  /**
   * Update category budgets progress
   */
  private async updateCategoryBudgetsProgress(period: string): Promise<void> {
    const budgets = await this.repository.getCategoryBudgets(period);
    
    for (const budget of budgets) {
      if (!budget.category) {
        continue;
      }
      
      // Determine date range based on period format
      let startDate: number;
      let endDate: number;
      
      const isMonthly = /^\d{4}-\d{2}$/.test(period);
      const isWeekly = /^\d{4}-W\d{2}$/.test(period);
      
      if (isMonthly) {
        const parts = period.split('-');
        const year = Number(parts[0]);
        const month = Number(parts[1]);
        startDate = DateUtils.getStartOfMonth(year, month);
        endDate = DateUtils.getEndOfMonth(year, month);
      } else if (isWeekly) {
        const match = period.match(/^(\d{4})-W(\d{2})$/);
        if (!match) {
          continue;
        }
        const year = parseInt(match[1]);
        const week = parseInt(match[2]);
        
        const jan4 = new Date(year, 0, 4);
        const jan4Day = jan4.getDay() || 7;
        const weekStart = new Date(jan4.getTime());
        weekStart.setDate(jan4.getDate() - jan4Day + 1 + (week - 1) * 7);
        weekStart.setHours(0, 0, 0, 0);
        
        startDate = weekStart.getTime();
        endDate = DateUtils.getEndOfWeek(startDate);
      } else {
        continue;
      }
      
      // Get all expense transactions for this category in this period
      const transactions = await this.transactionRepository.query({
        type: TransactionType.EXPENSE,
        categories: [budget.category],
        startDate: startDate,
        endDate: endDate
      });
      
      // Calculate total spent
      const spent = transactions.reduce((sum, t) => sum + t.amount, 0);
      const remaining = budget.amount - spent;
      const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
      const status = this.calculateBudgetStatus(spent, budget.amount);
      
      // Update budget
      await this.repository.update(budget.id, {
        spent: spent,
        remaining: remaining,
        percentage: percentage,
        status: status
      });
    }
  }

  /**
   * Check budget warnings
   * 检查80%预警和超支
   */
  async checkBudgetWarnings(): Promise<Budget[]> {
    const allBudgets = await this.repository.getAll();
    
    // Filter budgets that are in WARNING or EXCEEDED status
    return allBudgets.filter(budget => 
      budget.status === BudgetStatus.WARNING || 
      budget.status === BudgetStatus.EXCEEDED
    );
  }

  /**
   * Get current monthly budget
   * 获取当前月度预算
   */
  async getCurrentMonthlyBudget(): Promise<Budget | null> {
    const now = Date.now();
    const year = DateUtils.getYear(now);
    const month = DateUtils.getMonth(now);
    const period = `${year}-${String(month).padStart(2, '0')}`;
    
    return await this.repository.getMonthlyBudget(period);
  }

  /**
   * Get current weekly budget
   * 获取当前周度预算
   */
  async getCurrentWeeklyBudget(): Promise<Budget | null> {
    const now = Date.now();
    const year = DateUtils.getYear(now);
    const week = DateUtils.getWeekNumber(now);
    const period = `${year}-W${String(week).padStart(2, '0')}`;
    
    return await this.repository.getWeeklyBudget(period);
  }

  /**
   * Get category budgets
   * 获取分类预算列表
   */
  async getCategoryBudgets(period: string): Promise<Budget[]> {
    return await this.repository.getCategoryBudgets(period);
  }

  /**
   * Get all budgets
   * 获取所有预算
   */
  async getAllBudgets(): Promise<Budget[]> {
    return await this.repository.getAll();
  }

  /**
   * Get budget by ID
   * 根据ID获取预算
   */
  async getBudgetById(id: number): Promise<Budget> {
    const budgets = await this.repository.getAll();
    const budget = budgets.find(b => b.id === id);
    
    if (!budget) {
      throw new Error(`Budget with id ${id} not found`);
    }
    
    return budget;
  }

  /**
   * Delete budget
   * 删除预算
   */
  async deleteBudget(id: number): Promise<void> {
    await this.repository.delete(id);
  }

  /**
   * Calculate budget status based on spent amount and budget amount
   * 根据已花费金额和预算金额计算预算状态
   */
  private calculateBudgetStatus(spent: number, amount: number): BudgetStatus {
    if (amount === 0) {
      return BudgetStatus.NORMAL;
    }
    
    const percentage = (spent / amount) * 100;
    
    if (percentage >= 100) {
      return BudgetStatus.EXCEEDED;
    } else if (percentage >= 80) {
      return BudgetStatus.WARNING;
    } else {
      return BudgetStatus.NORMAL;
    }
  }
}
