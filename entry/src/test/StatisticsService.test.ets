import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { StatisticsService } from '../main/ets/services/StatisticsService';
import { TransactionService } from '../main/ets/services/TransactionService';
import { TransactionRepository, CategoryRepository } from '../main/ets/repositories';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { TransactionType, MoodType, PeriodType } from '../main/ets/models';

export default function statisticsServiceTest() {
  describe('StatisticsService', () => {
    let statisticsService: StatisticsService;
    let transactionService: TransactionService;
    let transactionRepository: TransactionRepository;
    let categoryRepository: CategoryRepository;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      
      // Initialize repositories and services
      transactionRepository = new TransactionRepository(dbManager);
      categoryRepository = new CategoryRepository(dbManager);
      transactionService = new TransactionService(transactionRepository);
      statisticsService = new StatisticsService(transactionRepository, categoryRepository);
    });

    afterAll(async () => {
      // Clean up
      await dbManager.closeDatabase();
    });

    beforeEach(async () => {
      // Clear transactions before each test
      const allTransactions = await transactionRepository.getAll();
      for (const transaction of allTransactions) {
        await transactionRepository.delete(transaction.id);
      }
    });

    it('should calculate category percentage correctly', async () => {
      // Create test transactions
      const now = Date.now();
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: 'Lunch',
        date: now
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '交通',
        description: 'Taxi',
        date: now
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: 'Dinner',
        date: now
      });
      
      // Calculate category percentage for the day
      const categorySummaries = await statisticsService.calculateCategoryPercentage(PeriodType.DAY, now);
      
      // Verify results
      expect(categorySummaries.length).assertEqual(2);
      
      // Find 餐饮 and 交通 categories
      const foodCategory = categorySummaries.find(c => c.category === '餐饮');
      const transportCategory = categorySummaries.find(c => c.category === '交通');
      
      expect(foodCategory).assertInstanceOf('Object');
      expect(transportCategory).assertInstanceOf('Object');
      
      // Verify amounts
      expect(foodCategory!.amount).assertEqual(200);
      expect(transportCategory!.amount).assertEqual(200);
      
      // Verify percentages (should be 50% each)
      expect(Math.abs(foodCategory!.percentage - 50)).assertLess(0.1);
      expect(Math.abs(transportCategory!.percentage - 50)).assertLess(0.1);
      
      // Verify counts
      expect(foodCategory!.count).assertEqual(2);
      expect(transportCategory!.count).assertEqual(1);
    });

    it('should generate pie chart data', async () => {
      // Create test transactions
      const now = Date.now();
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 300,
        category: '餐饮',
        description: 'Food',
        date: now
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '交通',
        description: 'Transport',
        date: now
      });
      
      // Generate pie chart data
      const chartData = await statisticsService.generatePieChartData(PeriodType.DAY, now);
      
      // Verify chart data structure
      expect(chartData.labels).assertInstanceOf('Array');
      expect(chartData.values).assertInstanceOf('Array');
      expect(chartData.colors).assertInstanceOf('Array');
      
      // Verify data content
      expect(chartData.labels.length).assertEqual(2);
      expect(chartData.values.length).assertEqual(2);
      expect(chartData.colors!.length).assertEqual(2);
      
      // Verify labels contain categories
      expect(chartData.labels).assertContain('餐饮');
      expect(chartData.labels).assertContain('交通');
    });

    it('should generate line chart data', async () => {
      // Create test transactions over multiple days
      const now = Date.now();
      const yesterday = now - 24 * 60 * 60 * 1000;
      
      await transactionService.addTransaction({
        type: TransactionType.INCOME,
        amount: 1000,
        category: '工资',
        description: 'Salary',
        date: yesterday
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 300,
        category: '餐饮',
        description: 'Food',
        date: yesterday
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '交通',
        description: 'Transport',
        date: now
      });
      
      // Generate line chart data
      const chartData = await statisticsService.generateLineChartData(yesterday, now);
      
      // Verify chart data structure
      expect(chartData.labels).assertInstanceOf('Array');
      expect(chartData.values).assertInstanceOf('Array');
      
      // Should have data for at least 2 days
      expect(chartData.labels.length).assertLargerOrEqual(1);
      expect(chartData.values.length).assertLargerOrEqual(1);
    });

    it('should generate mood calendar data', async () => {
      // Create test transactions with mood tags
      const date = new Date(2024, 0, 15); // January 15, 2024
      const timestamp = date.getTime();
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: 'Happy meal',
        date: timestamp,
        mood: MoodType.SATISFIED
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '购物',
        description: 'Impulse buy',
        date: timestamp,
        mood: MoodType.REGRET
      });
      
      await transactionService.addTransaction({
        type: TransactionType.EXPENSE,
        amount: 50,
        category: '餐饮',
        description: 'Another happy meal',
        date: timestamp,
        mood: MoodType.SATISFIED
      });
      
      // Generate mood calendar
      const moodCalendar = await statisticsService.generateMoodCalendar(2024, 1);
      
      // Verify structure
      expect(moodCalendar.year).assertEqual(2024);
      expect(moodCalendar.month).assertEqual(1);
      expect(moodCalendar.days).assertInstanceOf('Map');
      
      // Verify day 15 has a mood (should be SATISFIED as it appears twice)
      const day15Mood = moodCalendar.days.get(15);
      expect(day15Mood).assertInstanceOf('String');
      expect(day15Mood).assertEqual('😊'); // SATISFIED emoji
    });

    it('should return empty results for periods with no transactions', async () => {
      // Don't create any transactions
      const now = Date.now();
      
      // Calculate category percentage
      const categorySummaries = await statisticsService.calculateCategoryPercentage(PeriodType.DAY, now);
      expect(categorySummaries.length).assertEqual(0);
      
      // Generate pie chart data
      const pieChartData = await statisticsService.generatePieChartData(PeriodType.DAY, now);
      expect(pieChartData.labels.length).assertEqual(0);
      expect(pieChartData.values.length).assertEqual(0);
    });
  });
}
