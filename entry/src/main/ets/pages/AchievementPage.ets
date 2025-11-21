import { AchievementService } from '../services/AchievementService';
import { AchievementRepository, TransactionRepository, BudgetRepository } from '../repositories';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Achievement } from '../models';
import { BottomNavigation } from '../components/BottomNavigation';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DateUtils } from '../utils/DateUtils';

/**
 * AchievementPage - 成就页面
 * 显示已解锁和未解锁的成就列表
 * 需求：8.4, 8.5
 */
@Entry
@Component
struct AchievementPage {
  @State achievements: Achievement[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State newlyUnlockedId: string = ''; // For animation
  
  private achievementService: AchievementService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeServices();
    await this.loadAchievements();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext(this));
      
      const achievementRepository = new AchievementRepository();
      achievementRepository.setStore(store);
      const transactionRepository = new TransactionRepository();
      transactionRepository.setStore(store);
      const budgetRepository = new BudgetRepository();
      budgetRepository.setStore(store);
      
      this.achievementService = new AchievementService(
        achievementRepository,
        transactionRepository,
        budgetRepository
      );
    } catch (error) {
      console.error('Failed to initialize services:', error);
      this.errorMessage = '初始化失败，请重试';
    }
  }

  /**
   * Load achievements
   */
  private async loadAchievements() {
    if (!this.achievementService) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Check and update achievements
      this.achievements = await this.achievementService.checkAchievements();
      
      // Check for newly unlocked achievements
      const newlyUnlocked = this.achievements.find(a => 
        a.unlocked && a.unlockedAt && (Date.now() - a.unlockedAt < 5000)
      );
      
      if (newlyUnlocked) {
        this.newlyUnlockedId = newlyUnlocked.id;
        this.showUnlockNotification(newlyUnlocked);
      }
    } catch (error) {
      console.error('Failed to load achievements:', error);
      this.errorMessage = '加载成就失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Show unlock notification
   */
  private showUnlockNotification(achievement: Achievement) {
    try {
      promptAction.showToast({
        message: `🎉 恭喜解锁成就：${achievement.name}`,
        duration: 3000
      });
    } catch (error) {
      console.error('Failed to show unlock notification:', error);
    }
  }

  /**
   * Navigate back to home
   */
  private navigateBack() {
    router.replaceUrl({
      url: 'pages/Index'
    }).catch((error: Error) => {
      console.error('Failed to navigate back:', error);
    });
  }

  /**
   * Get unlocked achievements
   */
  private getUnlockedAchievements(): Achievement[] {
    return this.achievements.filter(a => a.unlocked);
  }

  /**
   * Get locked achievements
   */
  private getLockedAchievements(): Achievement[] {
    return this.achievements.filter(a => !a.unlocked);
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Content
      if (this.isLoading) {
        this.buildLoadingView();
      } else if (this.errorMessage) {
        this.buildErrorView();
      } else {
        this.buildAchievementList();
      }
      
      // Bottom navigation bar
      BottomNavigation({ currentPage: 'AchievementPage' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * Build header
   */
  @Builder
  buildHeader() {
    Row() {
      Button() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.navigateBack();
      })
      
      Text('成就')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 8 })
      
      Blank()
      
      // Achievement count
      Text(`${this.getUnlockedAchievements().length}/${this.achievements.length}`)
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * Build achievement list
   */
  @Builder
  buildAchievementList() {
    Scroll() {
      Column() {
        // Unlocked achievements section
        if (this.getUnlockedAchievements().length > 0) {
          this.buildSectionHeader('已解锁', this.getUnlockedAchievements().length);
          
          ForEach(this.getUnlockedAchievements(), (achievement: Achievement) => {
            this.buildAchievementBadge(achievement, true);
          }, (achievement: Achievement) => achievement.id);
        }
        
        // Locked achievements section
        if (this.getLockedAchievements().length > 0) {
          this.buildSectionHeader('未解锁', this.getLockedAchievements().length);
          
          ForEach(this.getLockedAchievements(), (achievement: Achievement) => {
            this.buildAchievementBadge(achievement, false);
          }, (achievement: Achievement) => achievement.id);
        }
        
        // Empty state
        if (this.achievements.length === 0) {
          this.buildEmptyState();
        }
      }
      .width('100%')
      .padding({ bottom: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  /**
   * Build section header
   */
  @Builder
  buildSectionHeader(title: string, count: number) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Text(`(${count})`)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  /**
   * Build achievement badge component
   * 成就徽章组件
   */
  @Builder
  buildAchievementBadge(achievement: Achievement, unlocked: boolean) {
    Column() {
      Row() {
        // Icon
        Column() {
          Text(achievement.icon || '🏆')
            .fontSize(48)
            .opacity(unlocked ? 1.0 : 0.3)
        }
        .width(80)
        .height(80)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(unlocked ? '#FFF7E6' : '#F5F5F5')
        .borderRadius(40)
        
        // Info
        Column() {
          Text(achievement.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(unlocked ? '#333333' : '#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(achievement.description)
            .fontSize(14)
            .fontColor(unlocked ? '#666666' : '#CCCCCC')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
          
          // Progress bar
          if (!unlocked) {
            this.buildProgressBar(achievement.progress);
          } else if (achievement.unlockedAt) {
            Text(`解锁于 ${DateUtils.formatDate(achievement.unlockedAt)}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(16)
      
      // Unlock animation overlay
      if (this.newlyUnlockedId === achievement.id) {
        this.buildUnlockAnimation();
      }
    }
    .width('100%')
    .margin({ left: 16, right: 16, top: 8 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: unlocked ? 8 : 4,
      color: unlocked ? '#FFD700' : '#E8E8E8',
      offsetX: 0,
      offsetY: 2
    })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  /**
   * Build progress bar
   */
  @Builder
  buildProgressBar(progress: number) {
    Column() {
      Row() {
        Text(`进度: ${Math.round(progress)}%`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 8, bottom: 4 })
      
      Row() {
        Row()
          .width(`${progress}%`)
          .height('100%')
          .backgroundColor('#1890FF')
          .borderRadius(2)
      }
      .width('100%')
      .height(6)
      .backgroundColor('#E8E8E8')
      .borderRadius(3)
    }
    .width('100%')
  }

  /**
   * Build unlock animation
   */
  @Builder
  buildUnlockAnimation() {
    Row() {
      Text('✨')
        .fontSize(32)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(255, 215, 0, 0.2)')
    .borderRadius(8)
  }

  /**
   * Build empty state
   */
  @Builder
  buildEmptyState() {
    Column() {
      Text('🏆')
        .fontSize(64)
        .margin({ bottom: 16 })
      
      Text('暂无成就')
        .fontSize(16)
        .fontColor('#999999')
      
      Text('开始记账解锁成就吧！')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build loading view
   */
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#1890FF')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build error view
   */
  @Builder
  buildErrorView() {
    Column() {
      Text('😕')
        .fontSize(48)
      
      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
      
      Button('重试')
        .fontSize(14)
        .margin({ top: 16 })
        .onClick(() => {
          this.loadAchievements();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
