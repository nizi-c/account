import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseManager } from '../utils/DatabaseManager';
import { CategoryRepository } from '../repositories/CategoryRepository';
import { AchievementRepository } from '../repositories/AchievementRepository';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { InitializationService } from '../services/InitializationService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // Initialize database and data on first launch
    this.initializeApp();
  }
  
  private async initializeApp(): Promise<void> {
    try {
      // Initialize database
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(this.context);
      
      // Create repositories
      const categoryRepo = new CategoryRepository(store);
      const achievementRepo = new AchievementRepository(store);
      const transactionRepo = new TransactionRepository(store);
      
      // Create initialization service
      const initService = new InitializationService(categoryRepo, achievementRepo, transactionRepo);
      
      // Initialize app (will only run on first launch)
      // Set includeSampleData to true if you want sample transactions
      await initService.initializeApp(this.context, store, false);
      
      hilog.info(DOMAIN, 'testTag', 'App initialization completed');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize app: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}