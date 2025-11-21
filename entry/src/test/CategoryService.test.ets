import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { CategoryService } from '../main/ets/services/CategoryService';
import { CategoryRepository } from '../main/ets/repositories/CategoryRepository';
import { DatabaseManager } from '../main/ets/utils/DatabaseManager';
import { TransactionType } from '../main/ets/models';

export default function categoryServiceTest() {
  describe('CategoryService', () => {
    let categoryService: CategoryService;
    let categoryRepository: CategoryRepository;
    let dbManager: DatabaseManager;

    beforeAll(async () => {
      // Initialize database
      dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      
      // Initialize repository and service
      categoryRepository = new CategoryRepository(dbManager);
      categoryService = new CategoryService(categoryRepository);
    });

    afterAll(async () => {
      // Clean up
      await dbManager.closeDatabase();
    });

    it('should get income categories', async () => {
      // Test getIncomeCategories method
      const incomeCategories = await categoryService.getIncomeCategories();
      
      // Verify all returned categories are income type
      expect(incomeCategories).assertInstanceOf('Array');
      
      for (const category of incomeCategories) {
        expect(category.type).assertEqual(TransactionType.INCOME);
      }
    });

    it('should get expense categories', async () => {
      // Test getExpenseCategories method
      const expenseCategories = await categoryService.getExpenseCategories();
      
      // Verify all returned categories are expense type
      expect(expenseCategories).assertInstanceOf('Array');
      
      for (const category of expenseCategories) {
        expect(category.type).assertEqual(TransactionType.EXPENSE);
      }
    });

    it('should get default predefined categories', () => {
      // Test getDefaultCategories method
      const defaultCategories = categoryService.getDefaultCategories();
      
      // Verify we have predefined categories
      expect(defaultCategories.length).assertLarger(0);
      
      // Verify we have both income and expense categories
      const incomeCount = defaultCategories.filter(c => c.type === TransactionType.INCOME).length;
      const expenseCount = defaultCategories.filter(c => c.type === TransactionType.EXPENSE).length;
      
      expect(incomeCount).assertLarger(0);
      expect(expenseCount).assertLarger(0);
      
      // Verify specific categories exist (餐饮、交通、购物、娱乐、工资、奖金等)
      const categoryNames = defaultCategories.map(c => c.name);
      expect(categoryNames).assertContain('餐饮');
      expect(categoryNames).assertContain('交通');
      expect(categoryNames).assertContain('购物');
      expect(categoryNames).assertContain('娱乐');
      expect(categoryNames).assertContain('工资');
      expect(categoryNames).assertContain('奖金');
    });

    it('should have all required fields in categories', () => {
      const defaultCategories = categoryService.getDefaultCategories();
      
      for (const category of defaultCategories) {
        // Verify all required fields exist
        expect(category.id).assertInstanceOf('String');
        expect(category.name).assertInstanceOf('String');
        expect(category.type).assertInstanceOf('String');
        expect(category.icon).assertInstanceOf('String');
        expect(category.color).assertInstanceOf('String');
        
        // Verify fields are not empty
        expect(category.id.length).assertLarger(0);
        expect(category.name.length).assertLarger(0);
        expect(category.icon.length).assertLarger(0);
        expect(category.color.length).assertLarger(0);
      }
    });
  });
}
