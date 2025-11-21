import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { AchievementService } from '../main/ets/services/AchievementService';
import { AchievementRepository } from '../main/ets/repositories/AchievementRepository';
import { TransactionRepository } from '../main/ets/repositories/TransactionRepository';
import { BudgetRepository } from '../main/ets/repositories/BudgetRepository';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { TransactionType } from '../main/ets/models';

export default function achievementServiceTest() {
  describe('AchievementService', () => {
    let achievementService: AchievementService;
    let achievementRepository: AchievementRepository;
    let transactionRepository: TransactionRepository;
    let budgetRepository: BudgetRepository;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      
      // Initialize repositories
      achievementRepository = new AchievementRepository(dbManager);
      transactionRepository = new TransactionRepository(dbManager);
      budgetRepository = new BudgetRepository(dbManager);
      
      // Initialize service
      achievementService = new AchievementService(
        achievementRepository,
        transactionRepository,
        budgetRepository
      );
    });

    afterAll(async () => {
      // Clean up
      await dbManager.closeDatabase();
    });

    it('should check achievements without errors', async () => {
      // Test checkAchievements method
      const achievements = await achievementService.checkAchievements();
      
      // Verify achievements array is returned
      expect(achievements).assertInstanceOf('Array');
    });

    it('should get achievement progress', async () => {
      // First, get all achievements to find a valid ID
      const achievements = await achievementRepository.getAll();
      
      if (achievements.length > 0) {
        const achievementId = achievements[0].id;
        
        // Test getAchievementProgress method
        const progress = await achievementService.getAchievementProgress(achievementId);
        
        // Verify progress is a number between 0 and 100
        expect(typeof progress).assertEqual('number');
        expect(progress).assertLargerOrEqual(0);
        expect(progress).assertLessOrEqual(100);
      }
    });

    it('should check consecutive days achievement', async () => {
      // Test checkConsecutiveDays method
      await achievementService.checkConsecutiveDays();
      
      // Verify no errors thrown
      expect(true).assertTrue();
    });

    it('should check reasonable spending achievement', async () => {
      // Test checkReasonableSpending method
      await achievementService.checkReasonableSpending();
      
      // Verify no errors thrown
      expect(true).assertTrue();
    });

    it('should detect consecutive days with sample transactions', async () => {
      // Create transactions for 3 consecutive days
      const now = Date.now();
      const oneDayMs = 24 * 60 * 60 * 1000;
      
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: 'Day 1',
        date: now
      });
      
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 50,
        category: '交通',
        description: 'Day 2',
        date: now + oneDayMs
      });
      
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 75,
        category: '购物',
        description: 'Day 3',
        date: now + (2 * oneDayMs)
      });
      
      // Check consecutive days achievement
      await achievementService.checkConsecutiveDays();
      
      // Get the achievement to verify progress
      const achievements = await achievementRepository.getAll();
      const consecutiveDaysAchievement = achievements.find(a => a.id === 'consecutive_7_days');
      
      if (consecutiveDaysAchievement) {
        // Should have progress > 0 since we have 3 consecutive days
        expect(consecutiveDaysAchievement.progress).assertLarger(0);
      }
    });

    it('should detect reasonable dining spending', async () => {
      // Create transactions with low dining percentage
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 100,
        category: '餐饮',
        description: 'Dining',
        date: Date.now()
      });
      
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 500,
        category: '交通',
        description: 'Transport',
        date: Date.now()
      });
      
      // Check reasonable spending achievement
      await achievementService.checkReasonableSpending();
      
      // Get the achievement to verify
      const achievements = await achievementRepository.getAll();
      const reasonableDiningAchievement = achievements.find(a => a.id === 'reasonable_dining');
      
      if (reasonableDiningAchievement) {
        // Dining is 100/600 = 16.67%, which is below 30% threshold
        // So achievement should be unlocked
        expect(reasonableDiningAchievement.unlocked).assertTrue();
      }
    });
  });
}
