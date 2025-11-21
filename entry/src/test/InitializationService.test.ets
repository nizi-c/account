import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import { InitializationService } from '../main/ets/services/InitializationService';
import { CategoryRepository } from '../main/ets/repositories/CategoryRepository';
import { AchievementRepository } from '../main/ets/repositories/AchievementRepository';
import { TransactionRepository } from '../main/ets/repositories/TransactionRepository';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import relationalStore from '@ohos.data.relationalStore';

export default function initializationServiceTest() {
  describe('InitializationService', () => {
    let dbManager: DatabaseManager;
    let store: relationalStore.RdbStore;
    let categoryRepo: CategoryRepository;
    let achievementRepo: AchievementRepository;
    let transactionRepo: TransactionRepository;
    let initService: InitializationService;

    beforeAll(async () => {
      // Note: In a real test environment, you would need a proper context
      // This is a simplified version for demonstration
      console.info('Setting up InitializationService test');
    });

    afterAll(async () => {
      console.info('Cleaning up InitializationService test');
    });

    it('should get default categories', () => {
      // Create a temporary repository to test getDefaultCategories
      const tempRepo = new CategoryRepository(null as any);
      const categories = tempRepo.getDefaultCategories();
      
      expect(categories.length).assertLarger(0);
      
      // Check that we have both income and expense categories
      const incomeCategories = categories.filter(c => c.type === 'income');
      const expenseCategories = categories.filter(c => c.type === 'expense');
      
      expect(incomeCategories.length).assertLarger(0);
      expect(expenseCategories.length).assertLarger(0);
      
      // Verify category structure
      const firstCategory = categories[0];
      expect(firstCategory.id).assertNotNull();
      expect(firstCategory.name).assertNotNull();
      expect(firstCategory.type).assertNotNull();
      expect(firstCategory.icon).assertNotNull();
      expect(firstCategory.color).assertNotNull();
    });

    it('should have predefined income categories', () => {
      const tempRepo = new CategoryRepository(null as any);
      const categories = tempRepo.getDefaultCategories();
      const incomeCategories = categories.filter(c => c.type === 'income');
      
      // Check for expected income categories
      const categoryNames = incomeCategories.map(c => c.name);
      expect(categoryNames).assertContain('工资');
      expect(categoryNames).assertContain('奖金');
      expect(categoryNames).assertContain('投资收益');
    });

    it('should have predefined expense categories', () => {
      const tempRepo = new CategoryRepository(null as any);
      const categories = tempRepo.getDefaultCategories();
      const expenseCategories = categories.filter(c => c.type === 'expense');
      
      // Check for expected expense categories
      const categoryNames = expenseCategories.map(c => c.name);
      expect(categoryNames).assertContain('餐饮');
      expect(categoryNames).assertContain('交通');
      expect(categoryNames).assertContain('购物');
      expect(categoryNames).assertContain('娱乐');
    });

    it('should have unique category IDs', () => {
      const tempRepo = new CategoryRepository(null as any);
      const categories = tempRepo.getDefaultCategories();
      
      const ids = categories.map(c => c.id);
      const uniqueIds = new Set(ids);
      
      expect(uniqueIds.size).assertEqual(ids.length);
    });

    it('should have valid category colors', () => {
      const tempRepo = new CategoryRepository(null as any);
      const categories = tempRepo.getDefaultCategories();
      
      for (const category of categories) {
        // Check that color starts with #
        expect(category.color.startsWith('#')).assertTrue();
        // Check that color has valid length (either #RGB or #RRGGBB)
        const validLength = category.color.length === 4 || category.color.length === 7;
        expect(validLength).assertTrue();
      }
    });
  });
}
