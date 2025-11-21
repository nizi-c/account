import { BaseRepository } from './BaseRepository';
import { Category, TransactionType } from '../models';
import relationalStore from '@ohos.data.relationalStore';

/**
 * Category Repository
 * 分类数据访问层
 */
export class CategoryRepository extends BaseRepository {
  private readonly TABLE_NAME = 'categories';

  /**
   * Get all categories
   */
  async getAll(): Promise<Category[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    
    try {
      const resultSet = await store.query(predicates);
      const categories = this.mapResultSetToCategories(resultSet);
      resultSet.close();
      return categories;
    } catch (error) {
      console.error('Failed to get all categories:', error);
      throw new Error(`Failed to get all categories: ${error}`);
    }
  }

  /**
   * Get categories by type (income/expense)
   */
  async getByType(type: TransactionType): Promise<Category[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('type', type);
    
    try {
      const resultSet = await store.query(predicates);
      const categories = this.mapResultSetToCategories(resultSet);
      resultSet.close();
      return categories;
    } catch (error) {
      console.error('Failed to get categories by type:', error);
      throw new Error(`Failed to get categories by type: ${error}`);
    }
  }

  /**
   * Get default predefined categories
   */
  getDefaultCategories(): Category[] {
    return [
      // Income categories
      { id: 'income_salary', name: '工资', type: TransactionType.INCOME, icon: '💰', color: '#4CAF50' },
      { id: 'income_bonus', name: '奖金', type: TransactionType.INCOME, icon: '🎁', color: '#8BC34A' },
      { id: 'income_investment', name: '投资收益', type: TransactionType.INCOME, icon: '📈', color: '#CDDC39' },
      { id: 'income_parttime', name: '兼职', type: TransactionType.INCOME, icon: '💼', color: '#66BB6A' },
      { id: 'income_other', name: '其他收入', type: TransactionType.INCOME, icon: '💵', color: '#81C784' },
      
      // Expense categories
      { id: 'expense_food', name: '餐饮', type: TransactionType.EXPENSE, icon: '🍔', color: '#FF9800' },
      { id: 'expense_transport', name: '交通', type: TransactionType.EXPENSE, icon: '🚗', color: '#2196F3' },
      { id: 'expense_shopping', name: '购物', type: TransactionType.EXPENSE, icon: '🛍️', color: '#E91E63' },
      { id: 'expense_entertainment', name: '娱乐', type: TransactionType.EXPENSE, icon: '🎮', color: '#9C27B0' },
      { id: 'expense_housing', name: '住房', type: TransactionType.EXPENSE, icon: '🏠', color: '#795548' },
      { id: 'expense_healthcare', name: '医疗', type: TransactionType.EXPENSE, icon: '💊', color: '#F44336' },
      { id: 'expense_education', name: '教育', type: TransactionType.EXPENSE, icon: '📚', color: '#3F51B5' },
      { id: 'expense_utilities', name: '水电费', type: TransactionType.EXPENSE, icon: '💡', color: '#FFC107' },
      { id: 'expense_other', name: '其他支出', type: TransactionType.EXPENSE, icon: '📝', color: '#9E9E9E' }
    ];
  }

  /**
   * Map ResultSet to Category array
   */
  private mapResultSetToCategories(resultSet: relationalStore.ResultSet): Category[] {
    const categories: Category[] = [];
    
    if (resultSet.goToFirstRow()) {
      do {
        categories.push(this.mapResultSetToCategory(resultSet));
      } while (resultSet.goToNextRow());
    }
    
    return categories;
  }

  /**
   * Map single row from ResultSet to Category
   */
  private mapResultSetToCategory(resultSet: relationalStore.ResultSet): Category {
    const idIndex = resultSet.getColumnIndex('id');
    const nameIndex = resultSet.getColumnIndex('name');
    const typeIndex = resultSet.getColumnIndex('type');
    const iconIndex = resultSet.getColumnIndex('icon');
    const colorIndex = resultSet.getColumnIndex('color');

    return {
      id: resultSet.getString(idIndex),
      name: resultSet.getString(nameIndex),
      type: resultSet.getString(typeIndex) as TransactionType,
      icon: resultSet.getString(iconIndex),
      color: resultSet.getString(colorIndex)
    };
  }
}
