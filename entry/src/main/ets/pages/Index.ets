import { TransactionService } from '../services/TransactionService';
import { BudgetService } from '../services/BudgetService';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { BudgetRepository } from '../repositories/BudgetRepository';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Transaction, Summary, Budget, BudgetStatus } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { FormatUtils } from '../utils/FormatUtils';
import { SortUtils } from '../utils/SortUtils';
import { ResponsiveUtils, DeviceType } from '../utils/ResponsiveUtils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { TransactionList } from '../components/TransactionList';
import { BottomNavigation } from '../components/BottomNavigation';
import { ErrorDisplay } from '../components';
import { Toast } from '../components/Toast';
import { WarningAlert } from '../components/WarningAlert';
import router from '@ohos.router';
import display from '@ohos.display';

/**
 * HomePage - 首页
 * 显示当日收支概览和交易列表
 * 需求：3.1, 3.2, 9.1, 10.1, 10.2, 10.5
 */
@Entry
@Component
struct Index {
  @State dailyTransactions: Transaction[] = [];
  @State dailySummary: Summary | null = null;
  @State currentMonthlyBudget: Budget | null = null;
  @State budgetWarnings: Budget[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  @State deviceType: DeviceType = DeviceType.PHONE;
  
  private transactionService: TransactionService | null = null;
  private budgetService: BudgetService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeScreenSize();
    await this.initializeServices();
    await this.loadDailyData();
  }

  /**
   * Initialize screen size and device type
   * 需求：10.1, 10.2
   */
  private async initializeScreenSize() {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      this.screenWidth = px2vp(defaultDisplay.width);
      this.screenHeight = px2vp(defaultDisplay.height);
      this.deviceType = ResponsiveUtils.getDeviceType(this.screenWidth);
      
      console.info(`Screen size: ${this.screenWidth}x${this.screenHeight}, Device: ${this.deviceType}`);
    } catch (error) {
      console.error('Failed to get screen size:', error);
      // Fallback to default phone size
      this.screenWidth = 360;
      this.screenHeight = 780;
      this.deviceType = DeviceType.PHONE;
    }
  }

  /**
   * Component lifecycle - on page show (reload data when returning)
   */
  onPageShow() {
    // Reload data when returning from other pages
    if (this.transactionService) {
      this.loadDailyData().catch((error: Error) => {
        console.error('Failed to reload daily data:', error);
        ErrorHandler.handle(error);
      });
    }
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext(this));
      const transactionRepo = new TransactionRepository();
      transactionRepo.setStore(store);
      const budgetRepo = new BudgetRepository();
      budgetRepo.setStore(store);
      
      this.transactionService = new TransactionService(transactionRepo);
      this.budgetService = new BudgetService(budgetRepo, transactionRepo);
      
      // Link budget service to transaction service for automatic updates
      this.transactionService.setBudgetService(this.budgetService);
    } catch (error) {
      ErrorHandler.handle(error as Error);
      this.hasError = true;
      this.errorMessage = '初始化失败，请重试';
      Toast.error('初始化失败');
    }
  }

  /**
   * Load daily data (transactions and summary)
   * 需求：12.7 - 在首页显示当前预算状态概览
   */
  private async loadDailyData() {
    if (!this.transactionService) {
      return;
    }

    this.isLoading = true;
    this.hasError = false;
    this.errorMessage = '';

    try {
      const today = DateUtils.now();
      
      // Get daily summary
      this.dailySummary = await this.transactionService.getDailySummary(today);
      
      // Get daily transactions
      const startDate = DateUtils.getStartOfDay(today);
      const endDate = DateUtils.getEndOfDay(today);
      const transactions = await this.transactionService.searchTransactions({
        startDate,
        endDate
      });
      
      // Sort by date descending (newest first)
      this.dailyTransactions = SortUtils.sortByDateDesc(transactions);
      
      // Load budget data
      await this.loadBudgetData();
    } catch (error) {
      ErrorHandler.handle(error as Error);
      this.hasError = true;
      this.errorMessage = '加载数据失败';
      Toast.error('加载数据失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Load budget data (current monthly budget and warnings)
   * 需求：12.7 - 在首页显示当前预算状态概览和预警
   */
  private async loadBudgetData() {
    if (!this.budgetService) {
      return;
    }

    try {
      // Get current monthly budget
      this.currentMonthlyBudget = await this.budgetService.getCurrentMonthlyBudget();
      
      // Get budget warnings
      this.budgetWarnings = await this.budgetService.checkBudgetWarnings();
      
      // Show warning notification if there are warnings
      if (this.budgetWarnings.length > 0) {
        this.showBudgetWarningNotification();
      }
    } catch (error) {
      // Log error but don't fail the page load
      console.error('Failed to load budget data:', error);
    }
  }

  /**
   * Show budget warning notification
   * 需求：12.7 - 实现预算预警通知
   */
  private showBudgetWarningNotification() {
    if (this.budgetWarnings.length === 0) {
      return;
    }

    const exceededBudgets = this.budgetWarnings.filter(b => b.status === BudgetStatus.EXCEEDED);
    const warningBudgets = this.budgetWarnings.filter(b => b.status === BudgetStatus.WARNING);

    if (exceededBudgets.length > 0) {
      Toast.error(`⚠️ ${exceededBudgets.length}个预算已超支！`);
    } else if (warningBudgets.length > 0) {
      Toast.warning(`⚠️ ${warningBudgets.length}个预算接近上限！`);
    }
  }

  /**
   * Handle refresh action
   */
  private async handleRefresh() {
    this.isRefreshing = true;
    await this.loadDailyData();
    this.isRefreshing = false;
  }

  /**
   * Navigate to add transaction page
   */
  private navigateToAddTransaction() {
    router.pushUrl({
      url: 'pages/AddTransactionPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to AddTransactionPage:', error);
    });
  }

  /**
   * Navigate to month view page
   */
  private navigateToMonthView() {
    router.pushUrl({
      url: 'pages/MonthViewPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to MonthViewPage:', error);
    });
  }

  /**
   * Navigate to query page
   */
  private navigateToQueryPage() {
    router.pushUrl({
      url: 'pages/QueryPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to QueryPage:', error);
    });
  }

  /**
   * Navigate to statistics page
   */
  private navigateToStatisticsPage() {
    router.pushUrl({
      url: 'pages/StatisticsPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to StatisticsPage:', error);
    });
  }

  /**
   * Navigate to mood calendar page
   */
  private navigateToMoodCalendarPage() {
    router.pushUrl({
      url: 'pages/MoodCalendarPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to MoodCalendarPage:', error);
    });
  }

  /**
   * Navigate to achievement page
   */
  private navigateToAchievementPage() {
    router.pushUrl({
      url: 'pages/AchievementPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to AchievementPage:', error);
    });
  }

  /**
   * Navigate to budget page
   */
  private navigateToBudgetPage() {
    router.pushUrl({
      url: 'pages/BudgetPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to BudgetPage:', error);
    });
  }

  /**
   * Navigate to export page
   */
  private navigateToExportPage() {
    router.pushUrl({
      url: 'pages/ExportPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to ExportPage:', error);
    });
  }

  /**
   * Handle transaction deletion
   * 需求：1.3 - 删除交易记录
   */
  private async handleDeleteTransaction(transaction: Transaction) {
    if (!this.transactionService) {
      return;
    }

    try {
      await this.transactionService.deleteTransaction(transaction.id);
      
      // Reload data after deletion
      await this.loadDailyData();
      Toast.success('删除成功');
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('删除失败，请重试');
    }
  }

  /**
   * Build UI
   * 需求：10.1, 10.2, 10.5
   */
  build() {
    if (this.deviceType === DeviceType.TABLET && ResponsiveUtils.isLandscape(this.screenWidth, this.screenHeight)) {
      // Tablet landscape: use sidebar layout
      this.buildTabletLandscapeLayout();
    } else {
      // Phone or tablet portrait: use single column layout
      this.buildPhoneLayout();
    }
  }

  /**
   * Build phone/tablet portrait layout (single column)
   * 需求：10.1
   */
  @Builder
  buildPhoneLayout() {
    Column() {
      // Header with title
      this.buildHeader();
      
      // Daily summary card
      this.buildSummaryCard();
      
      // Budget overview card
      this.buildBudgetOverviewCard();
      
      // Budget warnings
      this.buildBudgetWarnings();
      
      // Transaction list with refresh
      Refresh({ refreshing: this.isRefreshing }) {
        if (this.isLoading) {
          this.buildLoadingView();
        } else if (this.errorMessage) {
          this.buildErrorView();
        } else {
          TransactionList({
            transactions: $dailyTransactions,
            showDate: false,
            emptyMessage: '今天还没有记账\n点击右上角 + 号开始记账',
            emptyIcon: '📝',
            onDelete: (transaction: Transaction) => {
              this.handleDeleteTransaction(transaction);
            }
          })
        }
      }
      .onRefreshing(() => {
        this.handleRefresh();
      })
      .layoutWeight(1)
      
      // Bottom navigation bar
      BottomNavigation({ currentPage: 'Index' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * Build tablet landscape layout (with sidebar)
   * 需求：10.2, 10.5
   */
  @Builder
  buildTabletLandscapeLayout() {
    Row() {
      // Sidebar navigation
      this.buildSidebar();
      
      // Main content area
      Column() {
        // Header with title
        this.buildHeader();
        
        // Daily summary card
        this.buildSummaryCard();
        
        // Budget overview card
        this.buildBudgetOverviewCard();
        
        // Budget warnings
        this.buildBudgetWarnings();
        
        // Transaction list with refresh
        Refresh({ refreshing: this.isRefreshing }) {
          if (this.isLoading) {
            this.buildLoadingView();
          } else if (this.errorMessage) {
            this.buildErrorView();
          } else {
            TransactionList({
              transactions: $dailyTransactions,
              showDate: false,
              emptyMessage: '今天还没有记账\n点击右上角 + 号开始记账',
              emptyIcon: '📝',
              onDelete: (transaction: Transaction) => {
                this.handleDeleteTransaction(transaction);
              }
            })
          }
        }
        .onRefreshing(() => {
          this.handleRefresh();
        })
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * Build sidebar for tablet landscape mode
   * 需求：10.5
   */
  @Builder
  buildSidebar() {
    Column() {
      // App title
      Text('收支记账')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .padding(16)
      
      Divider()
        .color('#E8E8E8')
      
      // Navigation items
      this.buildSidebarItem('🏠', '首页', true);
      this.buildSidebarItem('📅', '月视图', false, (): void => { this.navigateToMonthView(); });
      this.buildSidebarItem('🔍', '查询', false, (): void => { this.navigateToQueryPage(); });
      this.buildSidebarItem('📊', '统计', false, (): void => { this.navigateToStatisticsPage(); });
      this.buildSidebarItem('💰', '预算', false, (): void => { this.navigateToBudgetPage(); });
      this.buildSidebarItem('😊', '情绪日历', false, (): void => { this.navigateToMoodCalendarPage(); });
      this.buildSidebarItem('🏆', '成就', false, (): void => { this.navigateToAchievementPage(); });
      this.buildSidebarItem('📤', '数据导出', false, (): void => { this.navigateToExportPage(); });
      
      Blank()
      
      // Quick add button
      Button() {
        Row() {
          Text('+')
            .fontSize(24)
            .fontColor(Color.White)
            .margin({ right: 8 })
          Text('添加记账')
            .fontSize(16)
            .fontColor(Color.White)
        }
      }
      .width('90%')
      .height(48)
      .backgroundColor('#1890FF')
      .borderRadius(24)
      .margin({ bottom: 16 })
      .onClick(() => {
        this.navigateToAddTransaction();
      })
    }
    .width(ResponsiveUtils.getSidebarWidth(this.screenWidth))
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topRight: 8, bottomRight: 8 })
    .shadow({ radius: 8, color: '#00000010' })
  }

  /**
   * Build sidebar navigation item
   */
  @Builder
  buildSidebarItem(icon: string, label: string, active: boolean, onClick?: () => void): void {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Text(label)
        .fontSize(16)
        .fontColor(active ? '#1890FF' : '#666666')
        .fontWeight(active ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(active ? '#E6F7FF' : Color.Transparent)
    .borderRadius(8)
    .margin({ left: 8, right: 8, top: 4, bottom: 4 })
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  /**
   * Build header
   */
  @Builder
  buildHeader() {
    Row() {
      Text('今日账单')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Blank()
      
      // Budget button
      Button() {
        Text('💰')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToBudgetPage();
      })
      
      // Achievement button
      Button() {
        Text('🏆')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToAchievementPage();
      })
      
      // Mood calendar button
      Button() {
        Text('😊')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToMoodCalendarPage();
      })
      
      // Statistics button
      Button() {
        Text('📊')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToStatisticsPage();
      })
      
      // Query button
      Button() {
        Text('🔍')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToQueryPage();
      })
      
      // Month view button
      Button() {
        Text('📅')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F0F0F0')
      .borderRadius(24)
      .margin({ right: 8 })
      .onClick(() => {
        this.navigateToMonthView();
      })
      
      // Quick add button
      Button() {
        Text('+')
          .fontSize(28)
          .fontColor(Color.White)
      }
      .width(48)
      .height(48)
      .backgroundColor('#1890FF')
      .onClick(() => {
        this.navigateToAddTransaction();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * Build summary card
   */
  @Builder
  buildSummaryCard() {
    if (this.dailySummary) {
      Column() {
        Text(DateUtils.formatDate(DateUtils.now(), 'YYYY-MM-DD'))
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
        
        Row() {
          // Income
          Column() {
            Text('收入')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 4 })
            Text(FormatUtils.formatCurrency(this.dailySummary.totalIncome))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#52C41A')
          }
          .layoutWeight(1)
          
          // Divider
          Divider()
            .vertical(true)
            .height(40)
            .color('#E8E8E8')
          
          // Expense
          Column() {
            Text('支出')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 4 })
            Text(FormatUtils.formatCurrency(this.dailySummary.totalExpense))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')
          }
          .layoutWeight(1)
          
          // Divider
          Divider()
            .vertical(true)
            .height(40)
            .color('#E8E8E8')
          
          // Net amount
          Column() {
            Text('结余')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 4 })
            Text(FormatUtils.formatCurrency(this.dailySummary.netAmount))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.dailySummary.netAmount >= 0 ? '#52C41A' : '#FF4D4F')
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .borderRadius(8)
    }
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
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build error view
   * 需求：11.4 - 数据加载失败处理和重试
   */
  @Builder
  buildErrorView() {
    ErrorDisplay({
      message: this.errorMessage,
      description: '请检查网络连接或稍后重试',
      showRetry: true,
      onRetry: () => {
        this.loadDailyData();
      }
    })
  }

  /**
   * Build budget overview card
   * 需求：12.7 - 在首页显示当前预算状态概览
   */
  @Builder
  buildBudgetOverviewCard() {
    if (this.currentMonthlyBudget) {
      Column() {
        Row() {
          Text('💰 本月预算')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Blank()
          
          Button({ type: ButtonType.Normal }) {
            Text('详情 >')
              .fontSize(14)
              .fontColor('#1890FF')
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.navigateToBudgetPage();
          })
        }
        .width('100%')
        .margin({ bottom: 12 })
        
        // Budget progress bar
        Column() {
          Row() {
            Text(`已用 ${FormatUtils.formatCurrency(this.currentMonthlyBudget.spent)}`)
              .fontSize(14)
              .fontColor('#666666')
            
            Blank()
            
            Text(`剩余 ${FormatUtils.formatCurrency(this.currentMonthlyBudget.remaining)}`)
              .fontSize(14)
              .fontColor(this.currentMonthlyBudget.status === BudgetStatus.EXCEEDED ? '#FF4D4F' : '#52C41A')
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          // Progress bar
          Stack({ alignContent: Alignment.Start }) {
            // Background
            Row()
              .width('100%')
              .height(8)
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
            
            // Progress
            Row()
              .width(`${Math.min(this.currentMonthlyBudget.percentage, 100)}%`)
              .height(8)
              .backgroundColor(this.getBudgetColor(this.currentMonthlyBudget.status))
              .borderRadius(4)
          }
          .width('100%')
          .height(8)
          
          // Percentage text
          Text(`${this.currentMonthlyBudget.percentage.toFixed(1)}%`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
            .alignSelf(ItemAlign.End)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .borderRadius(8)
    }
  }

  /**
   * Build budget warnings
   * 需求：12.7 - 实现预算预警通知
   */
  @Builder
  buildBudgetWarnings() {
    if (this.budgetWarnings.length > 0) {
      Column({ space: 8 }) {
        ForEach(this.budgetWarnings, (budget: Budget) => {
          WarningAlert({
            budget: budget,
            onDismiss: () => {
              // Remove this warning from the list
              this.budgetWarnings = this.budgetWarnings.filter(b => b.id !== budget.id);
            }
          })
      }, (budget: Budget) => budget.id.toString())
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
  }

  /**
   * Get budget color based on status
   */
  private getBudgetColor(status: BudgetStatus): string {
    switch (status) {
      case BudgetStatus.NORMAL:
        return '#52C41A';
      case BudgetStatus.WARNING:
        return '#FAAD14';
      case BudgetStatus.EXCEEDED:
        return '#FF4D4F';
      default:
        return '#52C41A';
    }
  }

}
