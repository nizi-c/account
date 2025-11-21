import preferences from '@ohos.data.preferences';
import { CategoryRepository } from '../repositories/CategoryRepository';
import { AchievementRepository } from '../repositories/AchievementRepository';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { Transaction, TransactionType, MoodType, TransactionInput } from '../models';
import relationalStore from '@ohos.data.relationalStore';

/**
 * Achievement data for initialization
 */
interface AchievementData {
  id: string;
  name: string;
  description: string;
  icon: string;
  unlocked: boolean;
  progress: number;
  target: number;
}

/**
 * Initialization Service
 * 数据初始化服务，负责首次启动检测和预定义数据初始化
 */
export class InitializationService {
  private static readonly PREFERENCES_NAME = 'app_preferences';
  private static readonly KEY_FIRST_LAUNCH = 'is_first_launch';
  private static readonly KEY_DATA_INITIALIZED = 'data_initialized';

  private categoryRepository: CategoryRepository;
  private achievementRepository: AchievementRepository;
  private transactionRepository: TransactionRepository;
  private preferencesStore: preferences.Preferences | null = null;

  constructor(
    categoryRepository: CategoryRepository,
    achievementRepository: AchievementRepository,
    transactionRepository: TransactionRepository
  ) {
    this.categoryRepository = categoryRepository;
    this.achievementRepository = achievementRepository;
    this.transactionRepository = transactionRepository;
  }

  /**
   * Initialize preferences store
   */
  private async initPreferences(context: Context): Promise<void> {
    if (!this.preferencesStore) {
      this.preferencesStore = await preferences.getPreferences(context, InitializationService.PREFERENCES_NAME);
    }
  }

  /**
   * Check if this is the first launch
   */
  async isFirstLaunch(context: Context): Promise<boolean> {
    await this.initPreferences(context);
    
    if (!this.preferencesStore) {
      return true;
    }

    const isFirstLaunch = await this.preferencesStore.get(InitializationService.KEY_FIRST_LAUNCH, true);
    return isFirstLaunch as boolean;
  }

  /**
   * Mark first launch as complete
   */
  private async markFirstLaunchComplete(context: Context): Promise<void> {
    await this.initPreferences(context);
    
    if (this.preferencesStore) {
      await this.preferencesStore.put(InitializationService.KEY_FIRST_LAUNCH, false);
      await this.preferencesStore.flush();
    }
  }

  /**
   * Check if data has been initialized
   */
  async isDataInitialized(context: Context): Promise<boolean> {
    await this.initPreferences(context);
    
    if (!this.preferencesStore) {
      return false;
    }

    const isInitialized = await this.preferencesStore.get(InitializationService.KEY_DATA_INITIALIZED, false);
    return isInitialized as boolean;
  }

  /**
   * Mark data as initialized
   */
  private async markDataInitialized(context: Context): Promise<void> {
    await this.initPreferences(context);
    
    if (this.preferencesStore) {
      await this.preferencesStore.put(InitializationService.KEY_DATA_INITIALIZED, true);
      await this.preferencesStore.flush();
    }
  }

  /**
   * Initialize all predefined data (categories and achievements)
   */
  async initializeData(context: Context, store: relationalStore.RdbStore): Promise<void> {
    const isInitialized = await this.isDataInitialized(context);
    
    if (isInitialized) {
      console.info('Data already initialized, skipping...');
      return;
    }

    console.info('Initializing predefined data...');

    try {
      await this.initializeCategories(store);
      await this.initializeAchievements(store);
      await this.markDataInitialized(context);
      await this.markFirstLaunchComplete(context);
      
      console.info('Data initialization completed successfully');
    } catch (error) {
      console.error('Failed to initialize data:', error);
      throw new Error(`Failed to initialize data: ${error}`);
    }
  }

  /**
   * Initialize predefined categories
   */
  private async initializeCategories(store: relationalStore.RdbStore): Promise<void> {
    const defaultCategories = this.categoryRepository.getDefaultCategories();
    
    for (const category of defaultCategories) {
      const valueBucket: relationalStore.ValuesBucket = {
        id: category.id,
        name: category.name,
        type: category.type,
        icon: category.icon,
        color: category.color
      };

      try {
        await store.insert('categories', valueBucket);
      } catch (error) {
        console.error(`Failed to insert category ${category.id}:`, error);
        // Continue with other categories even if one fails
      }
    }

    console.info(`Initialized ${defaultCategories.length} categories`);
  }

  /**
   * Get predefined achievements
   */
  private getDefaultAchievements(): AchievementData[] {
    const achievements: AchievementData[] = [
      {
        id: 'consecutive_7_days',
        name: '连续记账7天',
        description: '连续7天记录收支，养成良好的记账习惯',
        icon: '🔥',
        unlocked: false,
        progress: 0,
        target: 7
      },
      {
        id: 'budget_control',
        name: '月度预算控制达人',
        description: '当月支出未超过预算，理财有方',
        icon: '💎',
        unlocked: false,
        progress: 0,
        target: 1
      },
      {
        id: 'reasonable_food',
        name: '餐饮消费合理化',
        description: '餐饮支出占比控制在合理范围内',
        icon: '🍽️',
        unlocked: false,
        progress: 0,
        target: 1
      },
      {
        id: 'first_transaction',
        name: '记账新手',
        description: '完成第一笔交易记录',
        icon: '🌟',
        unlocked: false,
        progress: 0,
        target: 1
      },
      {
        id: 'transaction_100',
        name: '记账达人',
        description: '累计记录100笔交易',
        icon: '📊',
        unlocked: false,
        progress: 0,
        target: 100
      },
      {
        id: 'positive_balance',
        name: '收支平衡',
        description: '当月收入大于支出',
        icon: '💰',
        unlocked: false,
        progress: 0,
        target: 1
      }
    ];
    return achievements;
  }

  /**
   * Initialize predefined achievements
   */
  private async initializeAchievements(store: relationalStore.RdbStore): Promise<void> {
    const defaultAchievements = this.getDefaultAchievements();
    
    for (const achievement of defaultAchievements) {
      const valueBucket: relationalStore.ValuesBucket = {
        id: achievement.id,
        name: achievement.name,
        description: achievement.description,
        icon: achievement.icon,
        unlocked: achievement.unlocked ? 1 : 0,
        unlocked_at: null,
        progress: achievement.progress,
        target: achievement.target
      };

      try {
        await store.insert('achievements', valueBucket);
      } catch (error) {
        console.error(`Failed to insert achievement ${achievement.id}:`, error);
        // Continue with other achievements even if one fails
      }
    }

    console.info(`Initialized ${defaultAchievements.length} achievements`);
  }

  /**
   * Generate sample transaction data (optional)
   * 生成示例交易数据，用于演示和测试
   */
  async generateSampleData(context: Context): Promise<void> {
    console.info('Generating sample transaction data...');

    const now = Date.now();
    const oneDay = 24 * 60 * 60 * 1000;

    const sampleTransactions: TransactionInput[] = [
      // Recent transactions (last 7 days)
      {
        type: TransactionType.EXPENSE,
        amount: 35.5,
        category: 'expense_food',
        description: '午餐',
        date: now - oneDay,
        mood: MoodType.SATISFIED
      },
      {
        type: TransactionType.EXPENSE,
        amount: 12.0,
        category: 'expense_transport',
        description: '地铁',
        date: now - oneDay,
        mood: undefined
      },
      {
        type: TransactionType.EXPENSE,
        amount: 89.9,
        category: 'expense_shopping',
        description: '购买书籍',
        date: now - 2 * oneDay,
        mood: MoodType.SURPRISE
      },
      {
        type: TransactionType.INCOME,
        amount: 5000.0,
        category: 'income_salary',
        description: '月工资',
        date: now - 3 * oneDay,
        mood: MoodType.SATISFIED
      },
      {
        type: TransactionType.EXPENSE,
        amount: 45.0,
        category: 'expense_food',
        description: '晚餐聚会',
        date: now - 4 * oneDay,
        mood: MoodType.SATISFIED
      },
      {
        type: TransactionType.EXPENSE,
        amount: 150.0,
        category: 'expense_entertainment',
        description: '电影票',
        date: now - 5 * oneDay,
        mood: MoodType.REGRET
      },
      {
        type: TransactionType.EXPENSE,
        amount: 28.5,
        category: 'expense_food',
        description: '早餐',
        date: now - 6 * oneDay,
        mood: undefined
      },
      // Older transactions (this month)
      {
        type: TransactionType.EXPENSE,
        amount: 1200.0,
        category: 'expense_housing',
        description: '房租',
        date: now - 10 * oneDay,
        mood: undefined
      },
      {
        type: TransactionType.EXPENSE,
        amount: 200.0,
        category: 'expense_utilities',
        description: '水电费',
        date: now - 12 * oneDay,
        mood: undefined
      },
      {
        type: TransactionType.INCOME,
        amount: 1000.0,
        category: 'income_bonus',
        description: '季度奖金',
        date: now - 15 * oneDay,
        mood: MoodType.SURPRISE
      },
      {
        type: TransactionType.EXPENSE,
        amount: 300.0,
        category: 'expense_healthcare',
        description: '体检',
        date: now - 18 * oneDay,
        mood: undefined
      },
      {
        type: TransactionType.EXPENSE,
        amount: 500.0,
        category: 'expense_education',
        description: '在线课程',
        date: now - 20 * oneDay,
        mood: MoodType.SATISFIED
      }
    ];

    try {
      for (const transaction of sampleTransactions) {
        await this.transactionRepository.create(transaction);
      }
      
      console.info(`Generated ${sampleTransactions.length} sample transactions`);
    } catch (error) {
      console.error('Failed to generate sample data:', error);
      throw new Error(`Failed to generate sample data: ${error}`);
    }
  }

  /**
   * Initialize app on first launch
   * 首次启动时的完整初始化流程
   */
  async initializeApp(context: Context, store: relationalStore.RdbStore, includeSampleData: boolean = false): Promise<void> {
    const isFirst = await this.isFirstLaunch(context);
    
    if (!isFirst) {
      console.info('Not first launch, skipping initialization');
      return;
    }

    console.info('First launch detected, initializing app...');

    try {
      // Initialize predefined data
      await this.initializeData(context, store);

      // Optionally generate sample data
      if (includeSampleData) {
        await this.generateSampleData(context);
      }

      console.info('App initialization completed');
    } catch (error) {
      console.error('App initialization failed:', error);
      throw new Error(`App initialization failed: ${error}`);
    }
  }

  /**
   * Reset initialization flags (for testing or re-initialization)
   * 重置初始化标志（用于测试或重新初始化）
   */
  async resetInitialization(context: Context): Promise<void> {
    await this.initPreferences(context);
    
    if (this.preferencesStore) {
      await this.preferencesStore.delete(InitializationService.KEY_FIRST_LAUNCH);
      await this.preferencesStore.delete(InitializationService.KEY_DATA_INITIALIZED);
      await this.preferencesStore.flush();
      console.info('Initialization flags reset');
    }
  }
}
