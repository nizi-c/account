import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ExportService } from '../main/ets/services/ExportService';
import { TransactionRepository, CategoryRepository, AchievementRepository, BudgetRepository } from '../main/ets/repositories';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { TransactionType, MoodType, Transaction } from '../main/ets/models';

export default function exportServiceTest() {
  describe('ExportService', () => {
    let exportService: ExportService;
    let transactionRepo: TransactionRepository;
    let categoryRepo: CategoryRepository;
    let achievementRepo: AchievementRepository;
    let budgetRepo: BudgetRepository;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      
      // Initialize repositories
      transactionRepo = new TransactionRepository(dbManager);
      categoryRepo = new CategoryRepository(dbManager);
      achievementRepo = new AchievementRepository(dbManager);
      budgetRepo = new BudgetRepository(dbManager);
      
      // Initialize service (without context for basic tests)
      exportService = new ExportService(
        transactionRepo,
        categoryRepo,
        achievementRepo,
        budgetRepo
      );
    });

    afterAll(async () => {
      // Clean up
      await dbManager.closeDatabase();
    });

    beforeEach(async () => {
      // Clear transactions before each test
      const allTransactions = await transactionRepo.getAll();
      for (const transaction of allTransactions) {
        await transactionRepo.delete(transaction.id);
      }
    });

    it('should generate CSV content with correct headers', () => {
      // Test generateCSVContent with empty array
      const csvContent = exportService.generateCSVContent([]);
      
      // Verify header exists
      expect(csvContent).assertContain('日期,类型,分类,金额,用途,情绪');
    });

    it('should generate CSV content for transactions', async () => {
      // Create test transaction
      const transaction = await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 100.50,
        category: '餐饮',
        description: '午餐',
        date: Date.now(),
        mood: MoodType.SATISFIED
      });

      // Generate CSV
      const csvContent = exportService.generateCSVContent([transaction]);
      
      // Verify content includes transaction data
      expect(csvContent).assertContain('支出');
      expect(csvContent).assertContain('餐饮');
      expect(csvContent).assertContain('100.50');
      expect(csvContent).assertContain('午餐');
      expect(csvContent).assertContain('满意😊');
    });

    it('should escape CSV fields with commas', () => {
      const transaction: Transaction = {
        id: 1,
        type: TransactionType.EXPENSE,
        amount: 50.00,
        category: '餐饮',
        description: '午餐, 晚餐',
        date: Date.now(),
        mood: MoodType.SATISFIED,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      const csvContent = exportService.generateCSVContent([transaction]);
      
      // Verify field with comma is quoted
      expect(csvContent).assertContain('"午餐, 晚餐"');
    });

    it('should export to CSV with all transactions', async () => {
      // Create multiple transactions
      await transactionRepo.create({
        type: TransactionType.INCOME,
        amount: 5000,
        category: '工资',
        description: '月薪',
        date: Date.now()
      });

      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '交通',
        description: '地铁',
        date: Date.now(),
        mood: MoodType.REGRET
      });

      // Export to CSV
      const csvContent = await exportService.exportToCSV();
      
      // Verify both transactions are included
      expect(csvContent).assertContain('工资');
      expect(csvContent).assertContain('交通');
      expect(csvContent).assertContain('5000.00');
      expect(csvContent).assertContain('200.00');
    });

    it('should export to CSV with date range filter', async () => {
      const now = Date.now();
      const yesterday = now - 24 * 60 * 60 * 1000;
      const tomorrow = now + 24 * 60 * 60 * 1000;

      // Create transactions on different dates
      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: '昨天',
        date: yesterday
      });

      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '餐饮',
        description: '今天',
        date: now
      });

      // Export with date range (only today)
      const csvContent = await exportService.exportToCSV(now - 1000, now + 1000);
      
      // Verify only today's transaction is included
      expect(csvContent).assertContain('今天');
      expect(csvContent.includes('昨天')).assertFalse();
    });

    it('should export to JSON with all data', async () => {
      // Create test transaction
      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: '测试',
        date: Date.now()
      });

      // Export to JSON
      const exportData = await exportService.exportToJSON();
      
      // Verify structure
      expect(exportData.version).assertEqual('1.0.0');
      expect(exportData.exportDate).assertInstanceOf('Number');
      expect(exportData.transactions).assertInstanceOf('Array');
      expect(exportData.categories).assertInstanceOf('Array');
      expect(exportData.achievements).assertInstanceOf('Array');
      
      // Verify transaction is included
      expect(exportData.transactions.length).assertLarger(0);
    });

    it('should export to JSON with date range filter', async () => {
      const now = Date.now();
      const yesterday = now - 24 * 60 * 60 * 1000;

      // Create transactions on different dates
      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: '昨天',
        date: yesterday
      });

      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '餐饮',
        description: '今天',
        date: now
      });

      // Export with date range (only today)
      const exportData = await exportService.exportToJSON(now - 1000, now + 1000);
      
      // Verify only today's transaction is included
      expect(exportData.transactions.length).assertEqual(1);
      expect(exportData.transactions[0].description).assertEqual('今天');
    });

    it('should generate full backup with all data', async () => {
      // Create test data
      await transactionRepo.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: '测试',
        date: Date.now()
      });

      // Generate full backup
      const backupData = await exportService.generateFullBackup();
      
      // Verify all data types are included
      expect(backupData.version).assertEqual('1.0.0');
      expect(backupData.transactions).assertInstanceOf('Array');
      expect(backupData.categories).assertInstanceOf('Array');
      expect(backupData.achievements).assertInstanceOf('Array');
      
      // Verify data is not empty
      expect(backupData.transactions.length).assertLarger(0);
      expect(backupData.categories.length).assertLarger(0);
      expect(backupData.achievements.length).assertLarger(0);
    });

    it('should handle empty transactions in CSV export', async () => {
      // Export with no transactions
      const csvContent = await exportService.exportToCSV();
      
      // Should only have header
      const lines = csvContent.split('\n').filter(line => line.trim().length > 0);
      expect(lines.length).assertEqual(1);
      expect(lines[0]).assertContain('日期,类型,分类,金额,用途,情绪');
    });

    it('should handle transactions without mood in CSV', () => {
      const transaction: Transaction = {
        id: 1,
        type: TransactionType.EXPENSE,
        amount: 50.00,
        category: '餐饮',
        description: '午餐',
        date: Date.now(),
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      const csvContent = exportService.generateCSVContent([transaction]);
      
      // Verify CSV is generated without error
      expect(csvContent).assertContain('午餐');
      
      // Mood field should be empty
      const lines = csvContent.split('\n');
      const dataLine = lines[1];
      expect(dataLine.endsWith(',')).assertFalse();
    });
  });
}
