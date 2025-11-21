import { AchievementRepository, TransactionRepository, BudgetRepository } from '../repositories';
import { Achievement, TransactionType, Budget } from '../models';
import { DateUtils } from '../utils';

/**
 * Achievement Service
 * 成就业务逻辑层
 */
export class AchievementService {
  private repository: AchievementRepository;
  private transactionRepository: TransactionRepository;
  private budgetRepository: BudgetRepository;

  // Achievement IDs
  private readonly CONSECUTIVE_DAYS_ID = 'consecutive_7_days';
  private readonly BUDGET_CONTROL_ID = 'budget_control';
  private readonly REASONABLE_DINING_ID = 'reasonable_dining';

  // Thresholds
  private readonly CONSECUTIVE_DAYS_TARGET = 7;
  private readonly DINING_THRESHOLD = 0.30; // 30% of total expenses

  constructor(
    repository: AchievementRepository,
    transactionRepository: TransactionRepository,
    budgetRepository: BudgetRepository
  ) {
    this.repository = repository;
    this.transactionRepository = transactionRepository;
    this.budgetRepository = budgetRepository;
  }

  /**
   * Check and update achievements
   * 检查并更新所有成就
   */
  async checkAchievements(): Promise<Achievement[]> {
    await this.checkConsecutiveDays();
    await this.checkBudgetControl();
    await this.checkReasonableSpending();
    
    return await this.repository.getAll();
  }

  /**
   * Check consecutive days achievement
   * 检查连续记账7天成就
   */
  async checkConsecutiveDays(): Promise<void> {
    try {
      // Get all transactions
      const transactions = await this.transactionRepository.getAll();
      
      if (transactions.length === 0) {
        await this.repository.updateAchievement(this.CONSECUTIVE_DAYS_ID, false, 0);
        return;
      }

      // Get unique dates (normalized to start of day)
      const uniqueDates = new Set<number>();
      transactions.forEach(t => {
        const startOfDay = DateUtils.getStartOfDay(t.date);
        uniqueDates.add(startOfDay);
      });

      // Sort dates in ascending order
      const sortedDates = Array.from(uniqueDates).sort((a, b) => a - b);

      // Find longest consecutive streak
      let maxStreak = 1;
      let currentStreak = 1;

      for (let i = 1; i < sortedDates.length; i++) {
        const prevDate = sortedDates[i - 1];
        const currentDate = sortedDates[i];
        const dayDiff = (currentDate - prevDate) / (1000 * 60 * 60 * 24);

        if (dayDiff === 1) {
          // Consecutive day
          currentStreak++;
          maxStreak = Math.max(maxStreak, currentStreak);
        } else {
          // Streak broken
          currentStreak = 1;
        }
      }

      // Calculate progress (0-100)
      const progress = Math.min(100, (maxStreak / this.CONSECUTIVE_DAYS_TARGET) * 100);
      const unlocked = maxStreak >= this.CONSECUTIVE_DAYS_TARGET;

      await this.repository.updateAchievement(this.CONSECUTIVE_DAYS_ID, unlocked, progress);
    } catch (error) {
      console.error('Failed to check consecutive days achievement:', error);
      throw new Error(`Failed to check consecutive days achievement: ${error}`);
    }
  }

  /**
   * Check budget control achievement
   * 检查月度预算控制成就
   */
  async checkBudgetControl(): Promise<void> {
    try {
      // Get current month
      const now = new Date();
      const year = now.getFullYear();
      const month = now.getMonth() + 1;
      const period = `${year}-${String(month).padStart(2, '0')}`;

      // Get monthly budget for current month
      let monthlyBudget: Budget | null = null;
      try {
        monthlyBudget = await this.budgetRepository.getMonthlyBudget(period);
      } catch (error) {
        // Budget repository not implemented yet, skip this achievement
        console.log('Budget repository not implemented, skipping budget control achievement');
        return;
      }

      if (!monthlyBudget) {
        // No budget set, cannot check achievement
        await this.repository.updateAchievement(this.BUDGET_CONTROL_ID, false, 0);
        return;
      }

      // Get transactions for current month
      const startDate = DateUtils.getStartOfMonth(year, month);
      const endDate = DateUtils.getEndOfMonth(year, month);
      const transactions = await this.transactionRepository.getByDateRange(startDate, endDate);

      // Calculate total expenses
      const totalExpenses = transactions
        .filter(t => t.type === TransactionType.EXPENSE)
        .reduce((sum, t) => sum + t.amount, 0);

      // Check if within budget
      const unlocked = totalExpenses <= monthlyBudget.amount;
      const progress = unlocked ? 100 : Math.min(100, (monthlyBudget.amount / totalExpenses) * 100);

      await this.repository.updateAchievement(this.BUDGET_CONTROL_ID, unlocked, progress);
    } catch (error) {
      console.error('Failed to check budget control achievement:', error);
      // Don't throw, just log - budget feature might not be implemented yet
    }
  }

  /**
   * Check reasonable spending achievement
   * 检查餐饮消费合理化成就
   */
  async checkReasonableSpending(): Promise<void> {
    try {
      // Get all transactions
      const transactions = await this.transactionRepository.getAll();

      // Filter expenses only
      const expenses = transactions.filter(t => t.type === TransactionType.EXPENSE);

      if (expenses.length === 0) {
        await this.repository.updateAchievement(this.REASONABLE_DINING_ID, false, 0);
        return;
      }

      // Calculate total expenses
      const totalExpenses = expenses.reduce((sum, t) => sum + t.amount, 0);

      // Calculate dining expenses (assuming category name contains "餐饮" or "dining")
      const diningExpenses = expenses
        .filter(t => t.category.includes('餐饮') || t.category.toLowerCase().includes('dining'))
        .reduce((sum, t) => sum + t.amount, 0);

      // Calculate dining percentage
      const diningPercentage = totalExpenses > 0 ? diningExpenses / totalExpenses : 0;

      // Check if below threshold
      const unlocked = diningPercentage < this.DINING_THRESHOLD;
      
      // Progress: inverse of how close to threshold (100% when at 0%, 0% when at threshold or above)
      const progress = unlocked 
        ? Math.max(0, 100 - (diningPercentage / this.DINING_THRESHOLD) * 100)
        : 0;

      await this.repository.updateAchievement(this.REASONABLE_DINING_ID, unlocked, progress);
    } catch (error) {
      console.error('Failed to check reasonable spending achievement:', error);
      throw new Error(`Failed to check reasonable spending achievement: ${error}`);
    }
  }

  /**
   * Get all achievements
   * 获取所有成就
   */
  async getAllAchievements(): Promise<Achievement[]> {
    return await this.repository.getAll();
  }

  /**
   * Get achievement progress
   * 获取成就进度
   */
  async getAchievementProgress(id: string): Promise<number> {
    try {
      const achievements = await this.repository.getAll();
      const achievement = achievements.find(a => a.id === id);
      
      if (!achievement) {
        throw new Error(`Achievement with id ${id} not found`);
      }

      return achievement.progress;
    } catch (error) {
      console.error('Failed to get achievement progress:', error);
      throw new Error(`Failed to get achievement progress: ${error}`);
    }
  }
}
