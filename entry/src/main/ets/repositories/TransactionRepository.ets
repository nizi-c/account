import { BaseRepository } from './BaseRepository';
import { Transaction, TransactionInput, TransactionFilter, TransactionType, MoodType } from '../models';
import relationalStore from '@ohos.data.relationalStore';
import { ErrorHandler } from '../utils/ErrorHandler';

/**
 * Transaction Repository
 * 交易记录数据访问层
 */
export class TransactionRepository extends BaseRepository {
  private readonly TABLE_NAME = 'transactions';

  /**
   * Create a new transaction
   */
  async create(transaction: TransactionInput): Promise<Transaction> {
    const store = this.getStore();
    const now = Date.now();

    const valueBucket: relationalStore.ValuesBucket = {
      type: transaction.type,
      amount: transaction.amount,
      category: transaction.category,
      description: transaction.description,
      date: transaction.date,
      mood: transaction.mood || null,
      created_at: now,
      updated_at: now
    };

    try {
      const rowId = await store.insert(this.TABLE_NAME, valueBucket);
      
      // Retrieve the created transaction
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', rowId);
      const resultSet = await store.query(predicates);
      
      if (resultSet.goToFirstRow()) {
        const createdTransaction = this.mapResultSetToTransaction(resultSet);
        resultSet.close();
        return createdTransaction;
      }
      
      resultSet.close();
      throw new Error('Failed to retrieve created transaction');
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'create transaction');
    }
  }

  /**
   * Delete a transaction by ID
   */
  async delete(id: number): Promise<boolean> {
    const store = this.getStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      
      const rowsDeleted = await store.delete(predicates);
      return rowsDeleted > 0;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'delete transaction');
    }
  }

  /**
   * Query transactions with filters
   */
  async query(filter: TransactionFilter): Promise<Transaction[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    
    let hasCondition = false;

    // Apply type filter
    if (filter.type) {
      predicates.equalTo('type', filter.type);
      hasCondition = true;
    }

    // Apply category filter
    if (filter.categories && filter.categories.length > 0) {
      predicates.in('category', filter.categories);
      hasCondition = true;
    }

    // Apply amount range filter
    if (filter.minAmount !== undefined) {
      predicates.greaterThanOrEqualTo('amount', filter.minAmount);
      hasCondition = true;
    }
    if (filter.maxAmount !== undefined) {
      predicates.lessThanOrEqualTo('amount', filter.maxAmount);
      hasCondition = true;
    }

    // Apply date range filter
    if (filter.startDate !== undefined) {
      predicates.greaterThanOrEqualTo('date', filter.startDate);
      hasCondition = true;
    }
    if (filter.endDate !== undefined) {
      predicates.lessThanOrEqualTo('date', filter.endDate);
      hasCondition = true;
    }

    // Apply description filter (contains)
    if (filter.description) {
      predicates.like('description', `%${filter.description}%`);
      hasCondition = true;
    }

    // Apply mood filter
    if (filter.mood) {
      predicates.equalTo('mood', filter.mood);
      hasCondition = true;
    }

    try {
      const resultSet = await store.query(predicates);
      const transactions = this.mapResultSetToTransactions(resultSet);
      resultSet.close();
      return transactions;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'query transactions');
    }
  }

  /**
   * Get all transactions
   */
  async getAll(): Promise<Transaction[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    
    try {
      const resultSet = await store.query(predicates);
      const transactions = this.mapResultSetToTransactions(resultSet);
      resultSet.close();
      return transactions;
    } catch (error) {
      throw ErrorHandler.handleDatabaseError(error as Error, 'get all transactions');
    }
  }

  /**
   * Get transactions by date range
   */
  async getByDateRange(startDate: number, endDate: number): Promise<Transaction[]> {
    return this.query({ startDate, endDate });
  }

  /**
   * Get transactions by category
   */
  async getByCategory(category: string): Promise<Transaction[]> {
    return this.query({ categories: [category] });
  }

  /**
   * Map ResultSet to Transaction array
   */
  private mapResultSetToTransactions(resultSet: relationalStore.ResultSet): Transaction[] {
    const transactions: Transaction[] = [];
    
    if (resultSet.goToFirstRow()) {
      do {
        transactions.push(this.mapResultSetToTransaction(resultSet));
      } while (resultSet.goToNextRow());
    }
    
    return transactions;
  }

  /**
   * Map single row from ResultSet to Transaction
   */
  private mapResultSetToTransaction(resultSet: relationalStore.ResultSet): Transaction {
    const idIndex = resultSet.getColumnIndex('id');
    const typeIndex = resultSet.getColumnIndex('type');
    const amountIndex = resultSet.getColumnIndex('amount');
    const categoryIndex = resultSet.getColumnIndex('category');
    const descriptionIndex = resultSet.getColumnIndex('description');
    const dateIndex = resultSet.getColumnIndex('date');
    const moodIndex = resultSet.getColumnIndex('mood');
    const createdAtIndex = resultSet.getColumnIndex('created_at');
    const updatedAtIndex = resultSet.getColumnIndex('updated_at');

    const moodValue = resultSet.getString(moodIndex);

    return {
      id: resultSet.getLong(idIndex),
      type: resultSet.getString(typeIndex) as TransactionType,
      amount: resultSet.getDouble(amountIndex),
      category: resultSet.getString(categoryIndex),
      description: resultSet.getString(descriptionIndex),
      date: resultSet.getLong(dateIndex),
      mood: moodValue ? (moodValue as MoodType) : undefined,
      createdAt: resultSet.getLong(createdAtIndex),
      updatedAt: resultSet.getLong(updatedAtIndex)
    };
  }
}
