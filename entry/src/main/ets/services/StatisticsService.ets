import { TransactionRepository, CategoryRepository } from '../repositories';
import { PeriodType, CategorySummary, TransactionType, MoodType } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { CacheManager } from '../utils/CacheManager';

/**
 * Chart Data Interface
 */
export interface ChartData {
  labels: string[];
  values: number[];
  colors?: string[];
}

/**
 * Mood Calendar Data Interface
 */
export interface MoodCalendarData {
  year: number;
  month: number;
  days: Map<number, string>; // day -> mood
}

/**
 * Day data for line chart
 */
interface DayData {
  income: number;
  expense: number;
}

/**
 * Category data for statistics
 */
interface CategoryData {
  amount: number;
  count: number;
}

/**
 * Statistics Service
 * 统计业务逻辑层
 * 性能优化：使用缓存减少图表数据计算
 */
export class StatisticsService {
  private repository: TransactionRepository;
  private categoryRepository: CategoryRepository;
  private cacheManager: CacheManager;

  constructor(repository: TransactionRepository, categoryRepository: CategoryRepository) {
    this.repository = repository;
    this.categoryRepository = categoryRepository;
    this.cacheManager = CacheManager.getInstance();
  }

  /**
   * Generate pie chart data for expense category breakdown
   * 生成支出分类占比饼图数据
   * 性能优化：使用缓存避免重复计算
   */
  async generatePieChartData(period: PeriodType, date: number): Promise<ChartData> {
    // Check cache first
    const cacheKey = CacheManager.generateChartKey('pie', period, date);
    const cached = this.cacheManager.get<ChartData>(cacheKey);
    if (cached) {
      return cached;
    }

    // Calculate category percentages for the period
    const categorySummaries = await this.calculateCategoryPercentage(period, date);
    
    // Get all categories to retrieve colors
    const allCategories = await this.categoryRepository.getAll();
    const categoryColorMap = new Map<string, string>();
    allCategories.forEach(cat => {
      categoryColorMap.set(cat.name, cat.color);
    });
    
    // Extract labels, values, and colors
    const labels: string[] = [];
    const values: number[] = [];
    const colors: string[] = [];
    
    categorySummaries.forEach(summary => {
      labels.push(summary.category);
      values.push(summary.amount);
      colors.push(categoryColorMap.get(summary.category) || '#9E9E9E');
    });
    
    const chartData: ChartData = {
      labels,
      values,
      colors
    };
    
    // Cache the result (3 minutes TTL)
    this.cacheManager.set(cacheKey, chartData, 3 * 60 * 1000);
    
    return chartData;
  }

  /**
   * Generate line chart data for income/expense trends
   * 生成收支趋势折线图数据
   * 性能优化：使用缓存避免重复计算
   */
  async generateLineChartData(startDate: number, endDate: number): Promise<ChartData> {
    // Check cache first
    const cacheKey = CacheManager.generateChartKey('line', 'range', startDate);
    const cached = this.cacheManager.get<ChartData>(cacheKey);
    if (cached) {
      return cached;
    }

    // Get all transactions in the date range
    const transactions = await this.repository.getByDateRange(startDate, endDate);
    
    // Group transactions by date
    const dateMap = new Map<string, DayData>();
    
    transactions.forEach(transaction => {
      const dateKey = DateUtils.formatDate(transaction.date, 'YYYY-MM-DD');
      
      if (!dateMap.has(dateKey)) {
        const initialData: DayData = { income: 0, expense: 0 };
        dateMap.set(dateKey, initialData);
      }
      
      const dayData = dateMap.get(dateKey)!;
      if (transaction.type === TransactionType.INCOME) {
        dayData.income += transaction.amount;
      } else {
        dayData.expense += transaction.amount;
      }
    });
    
    // Sort dates and prepare chart data
    const sortedDates = Array.from(dateMap.keys()).sort();
    const labels: string[] = [];
    const incomeValues: number[] = [];
    const expenseValues: number[] = [];
    
    sortedDates.forEach(dateKey => {
      const dayData = dateMap.get(dateKey)!;
      labels.push(dateKey);
      incomeValues.push(dayData.income);
      expenseValues.push(dayData.expense);
    });
    
    // Return combined data (income and expense as separate series)
    // For simplicity, we'll return net amount (income - expense)
    const netValues = incomeValues.map((income, index) => income - expenseValues[index]);
    
    const chartData: ChartData = {
      labels,
      values: netValues,
      colors: ['#4CAF50', '#F44336'] // Green for income, red for expense
    };
    
    // Cache the result (3 minutes TTL)
    this.cacheManager.set(cacheKey, chartData, 3 * 60 * 1000);
    
    return chartData;
  }

  /**
   * Generate mood calendar data
   * 生成情绪日历数据
   */
  async generateMoodCalendar(year: number, month: number): Promise<MoodCalendarData> {
    // Get start and end of month
    const startDate = DateUtils.getStartOfMonth(year, month);
    const endDate = DateUtils.getEndOfMonth(year, month);
    
    // Get all transactions in the month with mood tags
    const transactions = await this.repository.getByDateRange(startDate, endDate);
    
    // Group by day and determine primary mood
    const dayMoodMap = new Map<number, Map<MoodType, number>>();
    
    transactions.forEach(transaction => {
      if (transaction.mood) {
        const date = new Date(transaction.date);
        const day = date.getDate();
        
        if (!dayMoodMap.has(day)) {
          dayMoodMap.set(day, new Map<MoodType, number>());
        }
        
        const moodCounts = dayMoodMap.get(day)!;
        moodCounts.set(transaction.mood, (moodCounts.get(transaction.mood) || 0) + 1);
      }
    });
    
    // Determine primary mood for each day (most frequent)
    const days = new Map<number, string>();
    
    dayMoodMap.forEach((moodCounts, day) => {
      let maxCount = 0;
      let primaryMood: MoodType | null = null;
      
      moodCounts.forEach((count, mood) => {
        if (count > maxCount) {
          maxCount = count;
          primaryMood = mood;
        }
      });
      
      if (primaryMood) {
        // Map mood to emoji
        const moodEmoji = this.getMoodEmoji(primaryMood);
        days.set(day, moodEmoji);
      }
    });
    
    return {
      year,
      month,
      days
    };
  }

  /**
   * Calculate category percentage for a given period
   * 计算指定时间段的分类占比
   */
  async calculateCategoryPercentage(period: PeriodType, date: number): Promise<CategorySummary[]> {
    // Determine date range based on period type
    let startDate: number;
    let endDate: number;
    
    const dateObj = new Date(date);
    const year = dateObj.getFullYear();
    const month = dateObj.getMonth() + 1;
    
    switch (period) {
      case PeriodType.DAY:
        startDate = DateUtils.getStartOfDay(date);
        endDate = DateUtils.getEndOfDay(date);
        break;
      case PeriodType.WEEK:
        startDate = DateUtils.getStartOfWeek(date);
        endDate = DateUtils.getEndOfWeek(date);
        break;
      case PeriodType.MONTH:
        startDate = DateUtils.getStartOfMonth(year, month);
        endDate = DateUtils.getEndOfMonth(year, month);
        break;
      case PeriodType.YEAR:
        startDate = DateUtils.getStartOfYear(year);
        endDate = DateUtils.getEndOfYear(year);
        break;
      default:
        throw new Error(`Unsupported period type: ${period}`);
    }
    
    // Get all expense transactions in the period
    const transactions = await this.repository.query({
      type: TransactionType.EXPENSE,
      startDate,
      endDate
    });
    
    // Group by category and calculate totals
    const categoryMap = new Map<string, CategoryData>();
    let totalExpense = 0;
    
    transactions.forEach(transaction => {
      const category = transaction.category;
      
      if (!categoryMap.has(category)) {
        const initialData: CategoryData = { amount: 0, count: 0 };
        categoryMap.set(category, initialData);
      }
      
      const categoryData = categoryMap.get(category)!;
      categoryData.amount += transaction.amount;
      categoryData.count += 1;
      totalExpense += transaction.amount;
    });
    
    // Calculate percentages
    const categorySummaries: CategorySummary[] = [];
    
    categoryMap.forEach((data, category) => {
      const percentage = totalExpense > 0 ? (data.amount / totalExpense) * 100 : 0;
      
      categorySummaries.push({
        category,
        amount: data.amount,
        percentage,
        count: data.count
      });
    });
    
    // Sort by amount descending
    categorySummaries.sort((a, b) => b.amount - a.amount);
    
    return categorySummaries;
  }

  /**
   * Get mood emoji from MoodType
   */
  private getMoodEmoji(mood: MoodType): string {
    switch (mood) {
      case MoodType.SATISFIED:
        return '😊';
      case MoodType.REGRET:
        return '😟';
      case MoodType.SURPRISE:
        return '🎉';
      default:
        return '😐';
    }
  }
}
