import { BaseRepository } from './BaseRepository';
import { Budget, BudgetType, BudgetStatus } from '../models';
import relationalStore from '@ohos.data.relationalStore';
import { ErrorHandler } from '../utils/ErrorHandler';

/**
 * Budget creation data (without id)
 */
export interface BudgetCreateData {
  type: BudgetType;
  period: string;
  category?: string;
  amount: number;
  spent: number;
  remaining: number;
  percentage: number;
  status: BudgetStatus;
}

/**
 * Budget Repository
 * 预算数据访问层
 */
export class BudgetRepository extends BaseRepository {
  private readonly TABLE_NAME = 'budgets';

  /**
   * Create a new budget
   */
  async create(budget: BudgetCreateData): Promise<Budget> {
    const store = this.getStore();
    const now = Date.now();

    const valueBucket: relationalStore.ValuesBucket = {
      type: budget.type,
      period: budget.period,
      category: budget.category || null,
      amount: budget.amount,
      spent: budget.spent,
      remaining: budget.remaining,
      percentage: budget.percentage,
      status: budget.status,
      created_at: now,
      updated_at: now
    };

    try {
      const rowId = await store.insert(this.TABLE_NAME, valueBucket);
      
      // Retrieve the created budget
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', rowId);
      const resultSet = await store.query(predicates);
      
      if (resultSet.goToFirstRow()) {
        const createdBudget = this.mapResultSetToBudget(resultSet);
        resultSet.close();
        return createdBudget;
      }
      
      resultSet.close();
      throw new Error('Failed to retrieve created budget');
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'create budget');
    }
  }

  /**
   * Update a budget
   */
  async update(id: number, budget: Partial<Budget>): Promise<Budget> {
    const store = this.getStore();
    const now = Date.now();

    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: now
    };

    // Manually copy fields from budget, excluding id and createdAt
    if (budget.type !== undefined) {
      valueBucket.type = budget.type;
    }
    if (budget.period !== undefined) {
      valueBucket.period = budget.period;
    }
    if (budget.category !== undefined) {
      valueBucket.category = budget.category;
    }
    if (budget.amount !== undefined) {
      valueBucket.amount = budget.amount;
    }
    if (budget.spent !== undefined) {
      valueBucket.spent = budget.spent;
    }
    if (budget.remaining !== undefined) {
      valueBucket.remaining = budget.remaining;
    }
    if (budget.percentage !== undefined) {
      valueBucket.percentage = budget.percentage;
    }
    if (budget.status !== undefined) {
      valueBucket.status = budget.status;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      
      const rowsUpdated = await store.update(valueBucket, predicates);
      
      if (rowsUpdated === 0) {
        throw new Error(`Budget with id ${id} not found`);
      }

      // Retrieve the updated budget
      const queryPredicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      queryPredicates.equalTo('id', id);
      const resultSet = await store.query(queryPredicates);
      
      if (resultSet.goToFirstRow()) {
        const updatedBudget = this.mapResultSetToBudget(resultSet);
        resultSet.close();
        return updatedBudget;
      }
      
      resultSet.close();
      throw new Error('Failed to retrieve updated budget');
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'update budget');
    }
  }

  /**
   * Delete a budget
   */
  async delete(id: number): Promise<boolean> {
    const store = this.getStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      
      const rowsDeleted = await store.delete(predicates);
      return rowsDeleted > 0;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'delete budget');
    }
  }

  /**
   * Get monthly budget for a specific period
   */
  async getMonthlyBudget(period: string): Promise<Budget | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('type', BudgetType.MONTHLY);
    predicates.equalTo('period', period);
    
    try {
      const resultSet = await store.query(predicates);
      
      if (resultSet.goToFirstRow()) {
        const budget = this.mapResultSetToBudget(resultSet);
        resultSet.close();
        return budget;
      }
      
      resultSet.close();
      return null;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'get monthly budget');
    }
  }

  /**
   * Get weekly budget for a specific period
   */
  async getWeeklyBudget(period: string): Promise<Budget | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('type', BudgetType.WEEKLY);
    predicates.equalTo('period', period);
    
    try {
      const resultSet = await store.query(predicates);
      
      if (resultSet.goToFirstRow()) {
        const budget = this.mapResultSetToBudget(resultSet);
        resultSet.close();
        return budget;
      }
      
      resultSet.close();
      return null;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'get weekly budget');
    }
  }

  /**
   * Get category budgets for a specific period
   */
  async getCategoryBudgets(period: string): Promise<Budget[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('type', BudgetType.CATEGORY);
    predicates.equalTo('period', period);
    
    try {
      const resultSet = await store.query(predicates);
      const budgets = this.mapResultSetToBudgets(resultSet);
      resultSet.close();
      return budgets;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'get category budgets');
    }
  }

  /**
   * Get all budgets
   */
  async getAll(): Promise<Budget[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    
    try {
      const resultSet = await store.query(predicates);
      const budgets = this.mapResultSetToBudgets(resultSet);
      resultSet.close();
      return budgets;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'get all budgets');
    }
  }

  /**
   * Map ResultSet to Budget array
   */
  private mapResultSetToBudgets(resultSet: relationalStore.ResultSet): Budget[] {
    const budgets: Budget[] = [];
    
    if (resultSet.goToFirstRow()) {
      do {
        budgets.push(this.mapResultSetToBudget(resultSet));
      } while (resultSet.goToNextRow());
    }
    
    return budgets;
  }

  /**
   * Map single row from ResultSet to Budget
   */
  private mapResultSetToBudget(resultSet: relationalStore.ResultSet): Budget {
    const idIndex = resultSet.getColumnIndex('id');
    const typeIndex = resultSet.getColumnIndex('type');
    const periodIndex = resultSet.getColumnIndex('period');
    const categoryIndex = resultSet.getColumnIndex('category');
    const amountIndex = resultSet.getColumnIndex('amount');
    const spentIndex = resultSet.getColumnIndex('spent');
    const remainingIndex = resultSet.getColumnIndex('remaining');
    const percentageIndex = resultSet.getColumnIndex('percentage');
    const statusIndex = resultSet.getColumnIndex('status');
    const createdAtIndex = resultSet.getColumnIndex('created_at');
    const updatedAtIndex = resultSet.getColumnIndex('updated_at');

    const categoryValue = resultSet.getString(categoryIndex);

    return {
      id: resultSet.getLong(idIndex),
      type: resultSet.getString(typeIndex) as BudgetType,
      period: resultSet.getString(periodIndex),
      category: categoryValue ? categoryValue : undefined,
      amount: resultSet.getDouble(amountIndex),
      spent: resultSet.getDouble(spentIndex),
      remaining: resultSet.getDouble(remainingIndex),
      percentage: resultSet.getDouble(percentageIndex),
      status: resultSet.getString(statusIndex) as BudgetStatus,
      createdAt: resultSet.getLong(createdAtIndex),
      updatedAt: resultSet.getLong(updatedAtIndex)
    };
  }
}
