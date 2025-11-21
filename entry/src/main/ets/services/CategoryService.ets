import { CategoryRepository } from '../repositories';
import { Category, TransactionType } from '../models';

/**
 * Category Service
 * 分类业务逻辑层
 */
export class CategoryService {
  private repository: CategoryRepository;

  constructor(repository: CategoryRepository) {
    this.repository = repository;
  }

  /**
   * Get income categories
   * 获取收入分类列表
   * 
   * @returns Promise<Category[]> 收入分类数组
   * @throws Error if database query fails
   */
  async getIncomeCategories(): Promise<Category[]> {
    return await this.repository.getByType(TransactionType.INCOME);
  }

  /**
   * Get expense categories
   * 获取支出分类列表
   * 
   * @returns Promise<Category[]> 支出分类数组
   * @throws Error if database query fails
   */
  async getExpenseCategories(): Promise<Category[]> {
    return await this.repository.getByType(TransactionType.EXPENSE);
  }

  /**
   * Get all categories
   * 获取所有分类
   * 
   * @returns Promise<Category[]> 所有分类数组
   */
  async getAllCategories(): Promise<Category[]> {
    return await this.repository.getAll();
  }

  /**
   * Get predefined categories
   * 获取预定义分类数据（餐饮、交通、购物、娱乐、工资、奖金等）
   * 
   * @returns Category[] 预定义分类数组
   */
  getDefaultCategories(): Category[] {
    return this.repository.getDefaultCategories();
  }
}
