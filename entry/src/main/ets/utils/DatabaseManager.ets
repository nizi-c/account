
import relationalStore from '@ohos.data.relationalStore';
import {
  DATABASE_NAME,
  DATABASE_VERSION,
  ALL_TABLE_SCHEMAS,
  ALL_INDEX_SCHEMAS
} from './DatabaseConfig';
import { AppError, ErrorType } from './ErrorHandler';

/**
 * Database Manager
 * 数据库管理器，负责数据库的初始化和连接管理
 */
export class DatabaseManager {
  private static instance: DatabaseManager;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {}

  /**
   * Get singleton instance
   */
  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  /**
   * Initialize database
   */
  async initialize(context: Context): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }

    const config: relationalStore.StoreConfig = {
      name: DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      await this.createIndexes();
      return this.store;
    } catch (error) {
      console.error('Failed to initialize database:', error);
      throw new AppError('Database initialization failed', ErrorType.DATABASE, 'DB_INIT_ERROR', error);
    }
  }

  /**
   * Create all tables
   */
  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('Database store not initialized');
    }

    for (const schema of ALL_TABLE_SCHEMAS) {
      try {
        await this.store.executeSql(schema);
      } catch (error) {
        console.error('Failed to create table:', error);
        throw new AppError('Table creation failed', ErrorType.DATABASE, 'TABLE_CREATE_ERROR', error);
      }
    }
  }

  /**
   * Create all indexes
   */
  private async createIndexes(): Promise<void> {
    if (!this.store) {
      throw new Error('Database store not initialized');
    }

    for (const indexSchema of ALL_INDEX_SCHEMAS) {
      try {
        await this.store.executeSql(indexSchema);
      } catch (error) {
        console.error('Failed to create index:', error);
        // Don't throw on index creation failure, just log it
        console.warn('Continuing without index');
      }
    }
  }

  /**
   * Get database store
   */
  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database not initialized. Call initialize() first.');
    }
    return this.store;
  }

  /**
   * Close database connection
   */
  async close(): Promise<void> {
    if (this.store) {
      // Note: RdbStore doesn't have a close method in current API
      // Just set to null for now
      this.store = null;
    }
  }
}
