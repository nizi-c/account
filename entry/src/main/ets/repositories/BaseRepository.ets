import relationalStore from '@ohos.data.relationalStore';

/**
 * Base Repository
 * 基础仓储类，提供数据库访问的基础功能
 */
export abstract class BaseRepository {
  protected store: relationalStore.RdbStore | null = null;

  /**
   * Set the database store instance
   */
  setStore(store: relationalStore.RdbStore): void {
    this.store = store;
  }

  /**
   * Get the database store instance
   */
  protected getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database store not initialized');
    }
    return this.store;
  }
}
