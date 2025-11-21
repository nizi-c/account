import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { AchievementService } from '../main/ets/services/AchievementService';
import { AchievementRepository } from '../main/ets/repositories/AchievementRepository';
import { TransactionRepository } from '../main/ets/repositories/TransactionRepository';
import { BudgetRepository } from '../main/ets/repositories/BudgetRepository';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { Achievement, TransactionType } from '../main/ets/models';

/**
 * Unit tests for Achievement Page
 * 测试成就列表包含所有成就
 * 测试已解锁成就正确显示
 * 测试成就进度正确计算
 * 需求：8.4, 8.5
 */
export default function achievementPageTest() {
  describe('AchievementPage Display Tests', () => {
    let achievementService: AchievementService;
    let achievementRepository: AchievementRepository;
    let transactionRepository: TransactionRepository;
    let budgetRepository: BudgetRepository;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initDatabase();
      
      // Initialize repositories
      achievementRepository = new AchievementRepository(store);
      transactionRepository = new TransactionRepository(store);
      budgetRepository = new BudgetRepository(store);
      
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

    /**
     * Test: Achievement list contains all achievements
     * 测试成就列表包含所有成就
     */
    it('should display all achievements in the list', async () => {
      // Get all achievements
      const achievements = await achievementRepository.getAll();
      
      // Verify achievements array is not empty
      expect(achievements).assertInstanceOf('Array');
      expect(achievements.length).assertLarger(0);
      
      // Verify each achievement has required fields
      achievements.forEach((achievement: Achievement) => {
        expect(achievement.id).assertInstanceOf('string');
        expect(achievement.name).assertInstanceOf('string');
        expect(achievement.description).assertInstanceOf('string');
        expect(typeof achievement.unlocked).assertEqual('boolean');
        expect(typeof achievement.progress).assertEqual('number');
        expect(typeof achievement.target).assertEqual('number');
      });
    });

    /**
     * Test: Unlocked achievements are correctly displayed
     * 测试已解锁成就正确显示
     */
    it('should correctly display unlocked achievements', async () => {
      // Create transactions to unlock an achievement
      const now = Date.now();
      const oneDayMs = 24 * 60 * 60 * 1000;
      
      // Create 7 consecutive days of transactions to unlock consecutive days achievement
      for (let i = 0; i < 7; i++) {
        await transactionRepository.create({
          type: TransactionType.EXPENSE,
          amount: 50 + i * 10,
          category: '餐饮',
          description: `Day ${i + 1}`,
          date: now + (i * oneDayMs)
        });
      }
      
      // Check achievements
      await achievementService.checkAchievements();
      
      // Get all achievements
      const achievements = await achievementRepository.getAll();
      
      // Find the consecutive days achievement
      const consecutiveDaysAchievement = achievements.find(a => a.id === 'consecutive_7_days');
      
      // Verify it exists and is unlocked
      expect(consecutiveDaysAchievement).assertInstanceOf('object');
      if (consecutiveDaysAchievement) {
        expect(consecutiveDaysAchievement.unlocked).assertTrue();
        expect(consecutiveDaysAchievement.progress).assertEqual(100);
        
        // Verify unlocked timestamp is set
        expect(consecutiveDaysAchievement.unlockedAt).assertInstanceOf('number');
        if (consecutiveDaysAchievement.unlockedAt) {
          expect(consecutiveDaysAchievement.unlockedAt).assertLarger(0);
        }
      }
    });

    /**
     * Test: Achievement progress is correctly calculated
     * 测试成就进度正确计算
     */
    it('should correctly calculate achievement progress', async () => {
      // Clear previous transactions
      const allTransactions = await transactionRepository.getAll();
      for (const transaction of allTransactions) {
        await transactionRepository.delete(transaction.id);
      }
      
      // Create 3 consecutive days of transactions (less than 7 required)
      const now = Date.now();
      const oneDayMs = 24 * 60 * 60 * 1000;
      
      for (let i = 0; i < 3; i++) {
        await transactionRepository.create({
          type: TransactionType.EXPENSE,
          amount: 100,
          category: '交通',
          description: `Day ${i + 1}`,
          date: now + (i * oneDayMs)
        });
      }
      
      // Check achievements
      await achievementService.checkAchievements();
      
      // Get the consecutive days achievement
      const achievements = await achievementRepository.getAll();
      const consecutiveDaysAchievement = achievements.find(a => a.id === 'consecutive_7_days');
      
      // Verify progress is calculated correctly
      if (consecutiveDaysAchievement) {
        // 3 days out of 7 = 42.86% progress
        const expectedProgress = (3 / 7) * 100;
        expect(consecutiveDaysAchievement.progress).assertClose(expectedProgress, 1);
        
        // Should not be unlocked yet
        expect(consecutiveDaysAchievement.unlocked).assertFalse();
      }
    });

    /**
     * Test: Achievement progress for reasonable dining
     * 测试餐饮消费成就进度计算
     */
    it('should correctly calculate reasonable dining achievement progress', async () => {
      // Clear previous transactions
      const allTransactions = await transactionRepository.getAll();
      for (const transaction of allTransactions) {
        await transactionRepository.delete(transaction.id);
      }
      
      // Create transactions with dining below 30% threshold
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 200,
        category: '餐饮',
        description: 'Dining',
        date: Date.now()
      });
      
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 800,
        category: '交通',
        description: 'Transport',
        date: Date.now()
      });
      
      // Check achievements
      await achievementService.checkAchievements();
      
      // Get the reasonable dining achievement
      const achievements = await achievementRepository.getAll();
      const reasonableDiningAchievement = achievements.find(a => a.id === 'reasonable_dining');
      
      // Verify achievement is unlocked (200/1000 = 20% < 30%)
      if (reasonableDiningAchievement) {
        expect(reasonableDiningAchievement.unlocked).assertTrue();
        expect(reasonableDiningAchievement.progress).assertLarger(0);
      }
    });

    /**
     * Test: Locked achievements display progress
     * 测试未解锁成就显示进度
     */
    it('should display progress for locked achievements', async () => {
      // Clear previous transactions
      const allTransactions = await transactionRepository.getAll();
      for (const transaction of allTransactions) {
        await transactionRepository.delete(transaction.id);
      }
      
      // Create only 1 day of transaction
      await transactionRepository.create({
        type: TransactionType.EXPENSE,
        amount: 50,
        category: '购物',
        description: 'Shopping',
        date: Date.now()
      });
      
      // Check achievements
      await achievementService.checkAchievements();
      
      // Get all achievements
      const achievements = await achievementRepository.getAll();
      
      // Verify locked achievements have progress between 0 and 100
      const lockedAchievements = achievements.filter(a => !a.unlocked);
      
      lockedAchievements.forEach((achievement: Achievement) => {
        expect(achievement.progress).assertLargerOrEqual(0);
        expect(achievement.progress).assertLessOrEqual(100);
      });
    });

    /**
     * Test: Achievement count is correct
     * 测试成就数量正确
     */
    it('should have correct achievement count', async () => {
      // Get all achievements
      const achievements = await achievementRepository.getAll();
      
      // Verify we have at least 3 achievements (consecutive days, budget control, reasonable dining)
      expect(achievements.length).assertLargerOrEqual(3);
      
      // Verify achievement IDs are unique
      const ids = achievements.map(a => a.id);
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).assertEqual(achievements.length);
    });

    /**
     * Test: Achievement service returns updated achievements
     * 测试成就服务返回更新的成就
     */
    it('should return updated achievements after checking', async () => {
      // Check achievements
      const achievements = await achievementService.checkAchievements();
      
      // Verify achievements are returned
      expect(achievements).assertInstanceOf('Array');
      expect(achievements.length).assertLarger(0);
      
      // Verify each achievement has valid data
      achievements.forEach((achievement: Achievement) => {
        expect(achievement.id).assertInstanceOf('string');
        expect(achievement.name).assertInstanceOf('string');
        expect(typeof achievement.unlocked).assertEqual('boolean');
        expect(typeof achievement.progress).assertEqual('number');
      });
    });
  });
}
