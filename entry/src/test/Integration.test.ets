/**
 * Integration and End-to-End Tests
 * 集成测试和端到端测试
 * 
 * Tests complete user flows:
 * - Add transaction → View list → Query → Delete
 * - Achievement unlock flow
 * - Mood tracking flow
 * - Budget management flow: Set budget → Add transaction → View progress → Warning alerts
 * - Data export flow: Select format → Export → Verify file
 * - Responsive layout switching
 * - Data persistence and recovery
 * 
 * 需求：1.1-13.8
 */

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { TransactionService } from '../main/ets/services/TransactionService';
import { BudgetService } from '../main/ets/services/BudgetService';
import { AchievementService } from '../main/ets/services/AchievementService';
import { StatisticsService } from '../main/ets/services/StatisticsService';
import { ExportService } from '../main/ets/services/ExportService';
import { CategoryService } from '../main/ets/services/CategoryService';
import { TransactionRepository } from '../main/ets/repositories/TransactionRepository';
import { BudgetRepository } from '../main/ets/repositories/BudgetRepository';
import { AchievementRepository } from '../main/ets/repositories/AchievementRepository';
import { CategoryRepository } from '../main/ets/repositories/CategoryRepository';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { DateUtils } from '../main/ets/utils/DateUtils';
import { TransactionType, MoodType, BudgetStatus, PeriodType } from '../main/ets/models';

export default function integrationTest() {
  describe('Integration and End-to-End Tests', () => {
    let transactionService: TransactionService;
    let budgetService: BudgetService;
    let achievementService: AchievementService;
    let statisticsService: StatisticsService;
    let exportService: ExportService;
    let categoryService: CategoryService;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      
      // Initialize repositories
      const transactionRepo = new TransactionRepository(dbManager);
      const budgetRepo = new BudgetRepository(dbManager);
      const achievementRepo = new AchievementRepository(dbManager);
      const categoryRepo = new CategoryRepository(dbManager);
      
      // Initialize services
      transactionService = new TransactionService(transactionRepo);
      budgetService = new BudgetService(budgetRepo, transactionRepo);
      achievementService = new AchievementService(achievementRepo, transactionRepo, budgetRepo);
      statisticsService = new StatisticsService(transactionRepo);
      exportService = new ExportService(transactionRepo, categoryRepo, achievementRepo, budgetRepo);
      categoryService = new CategoryService(categoryRepo);
      
      // Link services
      transactionService.setBudgetService(budgetService);
    });

    afterAll(async () => {
      // Clean up
      await dbManager.closeDatabase();
    });

    beforeEach(async () => {
      // Clear all data before each test
      const allTransactions = await transactionService.getAllTransactions();
      for (const transaction of allTransactions) {
        await transactionService.deleteTransaction(transaction.id);
      }
      
      const allBudgets = await budgetService.getAllBudgets();
      for (const budget of allBudgets) {
        await budgetService.deleteBudget(budget.id);
      }
    });

    /**
     * Test 1: Complete Transaction Flow
     * 测试完整用户流程：添加交易 → 查看列表 → 查询 → 删除
     * 需求：1.1, 1.2, 1.3, 3.1, 5.1-5.6
     */
    describe('Complete Transaction Flow', () => {
      it('should complete full transaction lifecycle', async () => {
        // Step 1: Add transaction
        const transaction = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 150.50,
          category: '餐饮',
          description: '午餐聚餐',
          date: DateUtils.now(),
          mood: MoodType.SATISFIED
        });

        expect(transaction).not.toBeNull();
        expect(transaction.id).assertLarger(0);
        expect(transaction.amount).assertEqual(150.50);
        expect(transaction.category).assertEqual('餐饮');

        // Step 2: View in list
        const allTransactions = await transactionService.getAllTransactions();
        expect(allTransactions.length).assertEqual(1);
        expect(allTransactions[0].id).assertEqual(transaction.id);

        // Step 3: Query by category
        const categoryResults = await transactionService.searchTransactions({
          categories: ['餐饮']
        });
        expect(categoryResults.length).assertEqual(1);
        expect(categoryResults[0].id).assertEqual(transaction.id);

        // Step 4: Query by amount range
        const amountResults = await transactionService.searchTransactions({
          minAmount: 100,
          maxAmount: 200
        });
        expect(amountResults.length).assertEqual(1);

        // Step 5: Query by description keyword
        const keywordResults = await transactionService.searchTransactions({
          description: '午餐'
        });
        expect(keywordResults.length).assertEqual(1);

        // Step 6: Delete transaction
        await transactionService.deleteTransaction(transaction.id);

        // Step 7: Verify deletion
        const afterDelete = await transactionService.getAllTransactions();
        expect(afterDelete.length).assertEqual(0);

        // Step 8: Verify query returns empty
        const queryAfterDelete = await transactionService.searchTransactions({
          categories: ['餐饮']
        });
        expect(queryAfterDelete.length).assertEqual(0);
      });

      it('should handle multiple transactions in flow', async () => {
        // Add multiple transactions
        const tx1 = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 50,
          category: '交通',
          description: '地铁',
          date: DateUtils.now()
        });

        const tx2 = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 200,
          category: '餐饮',
          description: '晚餐',
          date: DateUtils.now()
        });

        const tx3 = await transactionService.addTransaction({
          type: TransactionType.INCOME,
          amount: 5000,
          category: '工资',
          description: '月薪',
          date: DateUtils.now()
        });

        // View all
        const all = await transactionService.getAllTransactions();
        expect(all.length).assertEqual(3);

        // Query by type
        const expenses = await transactionService.searchTransactions({
          type: TransactionType.EXPENSE
        });
        expect(expenses.length).assertEqual(2);

        const income = await transactionService.searchTransactions({
          type: TransactionType.INCOME
        });
        expect(income.length).assertEqual(1);

        // Complex query: expenses in amount range
        const filtered = await transactionService.searchTransactions({
          type: TransactionType.EXPENSE,
          minAmount: 100,
          maxAmount: 300
        });
        expect(filtered.length).assertEqual(1);
        expect(filtered[0].category).assertEqual('餐饮');

        // Delete one transaction
        await transactionService.deleteTransaction(tx1.id);

        // Verify count
        const afterDelete = await transactionService.getAllTransactions();
        expect(afterDelete.length).assertEqual(2);
      });
    });

    /**
     * Test 2: Achievement Unlock Flow
     * 测试成就解锁流程
     * 需求：8.1, 8.2, 8.3, 8.4, 8.5
     */
    describe('Achievement Unlock Flow', () => {
      it('should unlock consecutive days achievement', async () => {
        // Add transactions for 7 consecutive days
        const now = DateUtils.now();
        
        for (let i = 0; i < 7; i++) {
          const date = now - i * 24 * 60 * 60 * 1000;
          await transactionService.addTransaction({
            type: TransactionType.EXPENSE,
            amount: 10 + i,
            category: '餐饮',
            description: `Day ${i + 1}`,
            date: date
          });
        }

        // Check achievements
        await achievementService.checkAchievements();

        // Verify consecutive days achievement is unlocked
        const achievements = await achievementService.getAllAchievements();
        const consecutiveDays = achievements.find(a => a.id === 'consecutive_7_days');
        
        expect(consecutiveDays).not.toBeNull();
        expect(consecutiveDays.unlocked).assertTrue();
      });

      it('should track achievement progress', async () => {
        // Add some transactions (less than 7 days)
        const now = DateUtils.now();
        
        for (let i = 0; i < 3; i++) {
          const date = now - i * 24 * 60 * 60 * 1000;
          await transactionService.addTransaction({
            type: TransactionType.EXPENSE,
            amount: 10,
            category: '餐饮',
            description: `Day ${i + 1}`,
            date: date
          });
        }

        // Check achievements
        await achievementService.checkAchievements();

        // Get progress
        const progress = await achievementService.getAchievementProgress('consecutive_7_days');
        
        // Progress should be partial (3/7 = ~43%)
        expect(progress).assertLarger(0);
        expect(progress).assertLess(100);
      });
    });

    /**
     * Test 3: Mood Tracking Flow
     * 测试情绪记账流程
     * 需求：7.1, 7.2, 7.3, 7.4, 7.5
     */
    describe('Mood Tracking Flow', () => {
      it('should complete mood tracking lifecycle', async () => {
        // Step 1: Add transaction with mood
        const transaction = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '娱乐',
          description: '电影票',
          date: DateUtils.now(),
          mood: MoodType.SATISFIED
        });

        expect(transaction.mood).assertEqual(MoodType.SATISFIED);

        // Step 2: Retrieve and verify mood is persisted
        const retrieved = await transactionService.getTransactionById(transaction.id);
        expect(retrieved.mood).assertEqual(MoodType.SATISFIED);

        // Step 3: Query by mood
        const moodTransactions = await transactionService.searchTransactions({
          mood: MoodType.SATISFIED
        });
        expect(moodTransactions.length).assertLarger(0);
        expect(moodTransactions[0].mood).assertEqual(MoodType.SATISFIED);

        // Step 4: Add transactions with different moods
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 50,
          category: '餐饮',
          description: '快餐',
          date: DateUtils.now(),
          mood: MoodType.REGRET
        });

        await transactionService.addTransaction({
          type: TransactionType.INCOME,
          amount: 1000,
          category: '奖金',
          description: '年终奖',
          date: DateUtils.now(),
          mood: MoodType.SURPRISE
        });

        // Step 5: Generate mood calendar data
        const year = DateUtils.getYear(DateUtils.now());
        const month = DateUtils.getMonth(DateUtils.now());
        const moodCalendar = await statisticsService.generateMoodCalendar(year, month);

        expect(moodCalendar).not.toBeNull();
        expect(moodCalendar.days).assertInstanceOf('Array');
      });

      it('should filter transactions by mood', async () => {
        // Add transactions with different moods
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '餐饮',
          description: 'Satisfied meal',
          date: DateUtils.now(),
          mood: MoodType.SATISFIED
        });

        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 200,
          category: '购物',
          description: 'Regret purchase',
          date: DateUtils.now(),
          mood: MoodType.REGRET
        });

        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 50,
          category: '交通',
          description: 'No mood',
          date: DateUtils.now()
        });

        // Filter by satisfied mood
        const satisfied = await transactionService.searchTransactions({
          mood: MoodType.SATISFIED
        });
        expect(satisfied.length).assertEqual(1);
        expect(satisfied[0].description).assertEqual('Satisfied meal');

        // Filter by regret mood
        const regret = await transactionService.searchTransactions({
          mood: MoodType.REGRET
        });
        expect(regret.length).assertEqual(1);
        expect(regret[0].description).assertEqual('Regret purchase');
      });
    });

    /**
     * Test 4: Budget Management Flow
     * 测试预算管理流程：设置预算 → 添加交易 → 查看进度 → 预警提示
     * 需求：12.1-12.8
     */
    describe('Budget Management Flow', () => {
      it('should complete budget management lifecycle', async () => {
        const now = DateUtils.now();
        const year = DateUtils.getYear(now);
        const month = DateUtils.getMonth(now);

        // Step 1: Set monthly budget
        const budget = await budgetService.setMonthlyBudget(year, month, 1000);
        
        expect(budget).not.toBeNull();
        expect(budget.amount).assertEqual(1000);
        expect(budget.spent).assertEqual(0);
        expect(budget.remaining).assertEqual(1000);
        expect(budget.status).assertEqual(BudgetStatus.NORMAL);

        // Step 2: Add transaction (50% of budget)
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 500,
          category: '餐饮',
          description: 'Big meal',
          date: now
        });

        // Step 3: Update budget progress
        await budgetService.updateBudgetProgress(`${year}-${month.toString().padStart(2, '0')}`);

        // Step 4: Check budget status (should still be normal)
        const updatedBudget = await budgetService.getCurrentMonthlyBudget();
        expect(updatedBudget.spent).assertEqual(500);
        expect(updatedBudget.remaining).assertEqual(500);
        expect(updatedBudget.percentage).assertEqual(50);
        expect(updatedBudget.status).assertEqual(BudgetStatus.NORMAL);

        // Step 5: Add more transactions (reach 85% - warning threshold)
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 350,
          category: '购物',
          description: 'Shopping',
          date: now
        });

        await budgetService.updateBudgetProgress(`${year}-${month.toString().padStart(2, '0')}`);

        // Step 6: Check for warnings
        const warnings = await budgetService.checkBudgetWarnings();
        expect(warnings.length).assertLarger(0);
        
        const warningBudget = warnings[0];
        expect(warningBudget.status).assertEqual(BudgetStatus.WARNING);
        expect(warningBudget.percentage).assertLargerOrEqual(80);

        // Step 7: Exceed budget
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 200,
          category: '娱乐',
          description: 'Entertainment',
          date: now
        });

        await budgetService.updateBudgetProgress(`${year}-${month.toString().padStart(2, '0')}`);

        // Step 8: Verify exceeded status
        const exceededBudget = await budgetService.getCurrentMonthlyBudget();
        expect(exceededBudget.status).assertEqual(BudgetStatus.EXCEEDED);
        expect(exceededBudget.percentage).assertLarger(100);
        expect(exceededBudget.remaining).assertLess(0);
      });

      it('should handle category budgets', async () => {
        const now = DateUtils.now();
        const year = DateUtils.getYear(now);
        const month = DateUtils.getMonth(now);
        const period = `${year}-${month.toString().padStart(2, '0')}`;

        // Set category budget for dining
        const diningBudget = await budgetService.setCategoryBudget(period, '餐饮', 500);
        expect(diningBudget.amount).assertEqual(500);
        expect(diningBudget.category).assertEqual('餐饮');

        // Add dining expense
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 200,
          category: '餐饮',
          description: 'Lunch',
          date: now
        });

        // Add non-dining expense
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 300,
          category: '交通',
          description: 'Transport',
          date: now
        });

        // Update budget progress
        await budgetService.updateBudgetProgress(period);

        // Check category budget (should only include dining expenses)
        const categoryBudgets = await budgetService.getCategoryBudgets(period);
        const updatedDiningBudget = categoryBudgets.find(b => b.category === '餐饮');
        
        expect(updatedDiningBudget.spent).assertEqual(200);
        expect(updatedDiningBudget.remaining).assertEqual(300);
      });
    });

    /**
     * Test 5: Data Export Flow
     * 测试数据导出流程：选择格式 → 导出 → 验证文件
     * 需求：13.1-13.8
     */
    describe('Data Export Flow', () => {
      it('should complete CSV export flow', async () => {
        // Step 1: Add test data
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '餐饮',
          description: 'Lunch',
          date: DateUtils.now(),
          mood: MoodType.SATISFIED
        });

        await transactionService.addTransaction({
          type: TransactionType.INCOME,
          amount: 5000,
          category: '工资',
          description: 'Salary',
          date: DateUtils.now()
        });

        // Step 2: Export to CSV
        const csvContent = await exportService.exportToCSV();

        // Step 3: Verify CSV format
        expect(csvContent).assertContain('日期,类型,分类,金额,用途,情绪');
        expect(csvContent).assertContain('餐饮');
        expect(csvContent).assertContain('工资');
        expect(csvContent).assertContain('100.00');
        expect(csvContent).assertContain('5000.00');
        expect(csvContent).assertContain('满意😊');

        // Step 4: Verify CSV structure
        const lines = csvContent.split('\n').filter(line => line.trim().length > 0);
        expect(lines.length).assertEqual(3); // Header + 2 data rows
      });

      it('should complete JSON export flow', async () => {
        // Step 1: Add test data
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 150,
          category: '购物',
          description: 'Shopping',
          date: DateUtils.now()
        });

        // Step 2: Export to JSON
        const jsonData = await exportService.exportToJSON();

        // Step 3: Verify JSON structure
        expect(jsonData.version).assertEqual('1.0.0');
        expect(jsonData.exportDate).assertInstanceOf('Number');
        expect(jsonData.transactions).assertInstanceOf('Array');
        expect(jsonData.categories).assertInstanceOf('Array');
        expect(jsonData.achievements).assertInstanceOf('Array');

        // Step 4: Verify transaction data
        expect(jsonData.transactions.length).assertLarger(0);
        const transaction = jsonData.transactions[0];
        expect(transaction.amount).assertEqual(150);
        expect(transaction.category).assertEqual('购物');
        expect(transaction.description).assertEqual('Shopping');
      });

      it('should export with date range filter', async () => {
        const now = DateUtils.now();
        const yesterday = now - 24 * 60 * 60 * 1000;
        const tomorrow = now + 24 * 60 * 60 * 1000;

        // Add transactions on different dates
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '餐饮',
          description: 'Yesterday',
          date: yesterday
        });

        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 200,
          category: '餐饮',
          description: 'Today',
          date: now
        });

        // Export with date range (only today)
        const csvContent = await exportService.exportToCSV(now - 1000, now + 1000);

        // Verify only today's transaction is included
        expect(csvContent).assertContain('Today');
        expect(csvContent.includes('Yesterday')).assertFalse();
      });

      it('should generate full backup', async () => {
        // Add various data
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '餐饮',
          description: 'Test',
          date: DateUtils.now()
        });

        const year = DateUtils.getYear(DateUtils.now());
        const month = DateUtils.getMonth(DateUtils.now());
        await budgetService.setMonthlyBudget(year, month, 1000);

        // Generate full backup
        const backup = await exportService.generateFullBackup();

        // Verify all data types are included
        expect(backup.transactions.length).assertLarger(0);
        expect(backup.categories.length).assertLarger(0);
        expect(backup.achievements.length).assertLarger(0);
        expect(backup.budgets).assertInstanceOf('Array');
      });
    });

    /**
     * Test 6: Data Persistence and Recovery
     * 测试数据持久化和恢复
     * 需求：11.1, 11.2, 11.3, 11.4
     */
    describe('Data Persistence and Recovery', () => {
      it('should persist transaction data', async () => {
        // Add transaction
        const transaction = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 250.75,
          category: '购物',
          description: 'Persistence test',
          date: DateUtils.now(),
          mood: MoodType.SATISFIED
        });

        const transactionId = transaction.id;

        // Simulate app restart by creating new service instance
        const newTransactionRepo = new TransactionRepository(dbManager);
        const newTransactionService = new TransactionService(newTransactionRepo);

        // Retrieve transaction
        const retrieved = await newTransactionService.getTransactionById(transactionId);

        // Verify all fields are persisted correctly
        expect(retrieved).not.toBeNull();
        expect(retrieved.id).assertEqual(transactionId);
        expect(retrieved.type).assertEqual(TransactionType.EXPENSE);
        expect(retrieved.amount).assertEqual(250.75);
        expect(retrieved.category).assertEqual('购物');
        expect(retrieved.description).assertEqual('Persistence test');
        expect(retrieved.mood).assertEqual(MoodType.SATISFIED);
      });

      it('should persist budget data', async () => {
        const year = DateUtils.getYear(DateUtils.now());
        const month = DateUtils.getMonth(DateUtils.now());

        // Set budget
        const budget = await budgetService.setMonthlyBudget(year, month, 2000);
        const budgetId = budget.id;

        // Simulate app restart
        const newBudgetRepo = new BudgetRepository(dbManager);
        const newTransactionRepo = new TransactionRepository(dbManager);
        const newBudgetService = new BudgetService(newBudgetRepo, newTransactionRepo);

        // Retrieve budget
        const retrieved = await newBudgetService.getBudgetById(budgetId);

        // Verify budget is persisted
        expect(retrieved).not.toBeNull();
        expect(retrieved.amount).assertEqual(2000);
      });

      it('should recover from empty state', async () => {
        // Start with empty database
        const transactions = await transactionService.getAllTransactions();
        
        // Should return empty array, not error
        expect(transactions).assertInstanceOf('Array');
        expect(transactions.length).assertEqual(0);

        // Should be able to add data
        const transaction = await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '餐饮',
          description: 'First transaction',
          date: DateUtils.now()
        });

        expect(transaction).not.toBeNull();
        expect(transaction.id).assertLarger(0);
      });
    });

    /**
     * Test 7: Complex Integration Scenarios
     * 测试复杂集成场景
     */
    describe('Complex Integration Scenarios', () => {
      it('should handle transaction with budget and achievement updates', async () => {
        const now = DateUtils.now();
        const year = DateUtils.getYear(now);
        const month = DateUtils.getMonth(now);

        // Set budget
        await budgetService.setMonthlyBudget(year, month, 1000);

        // Add transactions for multiple days
        for (let i = 0; i < 7; i++) {
          const date = now - i * 24 * 60 * 60 * 1000;
          await transactionService.addTransaction({
            type: TransactionType.EXPENSE,
            amount: 50,
            category: '餐饮',
            description: `Day ${i + 1}`,
            date: date
          });
        }

        // Update budget progress
        await budgetService.updateBudgetProgress(`${year}-${month.toString().padStart(2, '0')}`);

        // Check achievements
        await achievementService.checkAchievements();

        // Verify budget is updated
        const budget = await budgetService.getCurrentMonthlyBudget();
        expect(budget.spent).assertEqual(350); // 7 days * 50

        // Verify achievement is unlocked
        const achievements = await achievementService.getAllAchievements();
        const consecutiveDays = achievements.find(a => a.id === 'consecutive_7_days');
        expect(consecutiveDays.unlocked).assertTrue();
      });

      it('should handle statistics with filtered data', async () => {
        const now = DateUtils.now();

        // Add diverse transactions
        await transactionService.addTransaction({
          type: TransactionType.EXPENSE,
          amount: 100,
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

        await transactionService.addTransaction({
          type: TransactionType.INCOME,
          amount: 5000,
          category: '工资',
          description: 'Salary',
          date: now
        });

        // Get daily summary
        const summary = await transactionService.getDailySummary(now);

        expect(summary.totalIncome).assertEqual(5000);
        expect(summary.totalExpense).assertEqual(300);
        expect(summary.netAmount).assertEqual(4700);

        // Generate pie chart data
        const pieData = await statisticsService.generatePieChartData(PeriodType.DAY, now);
        expect(pieData).not.toBeNull();
        expect(pieData.data.length).assertLarger(0);

        // Verify category breakdown
        expect(summary.categoryBreakdown.length).assertEqual(2); // Only expense categories
        const diningCategory = summary.categoryBreakdown.find(c => c.category === '餐饮');
        expect(diningCategory.amount).assertEqual(100);
      });
    });
  });
}
