import { TransactionService } from '../services/TransactionService';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Transaction, Summary, CategorySummary } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { FormatUtils } from '../utils/FormatUtils';
import { SortUtils } from '../utils/SortUtils';
import { TransactionList } from '../components/TransactionList';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * MonthViewPage - 月视图页面
 * 显示当月收支流水记录和汇总
 * 需求：3.3, 3.4
 */
@Entry
@Component
struct MonthViewPage {
  @State monthlyTransactions: Transaction[] = [];
  @State monthlySummary: Summary | null = null;
  @State selectedYear: number = DateUtils.getYear(DateUtils.now());
  @State selectedMonth: number = DateUtils.getMonth(DateUtils.now());
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  
  private transactionService: TransactionService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeServices();
    await this.loadMonthlyData();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext(this));
      const repository = new TransactionRepository();
      repository.setStore(store);
      this.transactionService = new TransactionService(repository);
    } catch (error) {
      console.error('Failed to initialize services:', error);
      this.errorMessage = '初始化失败，请重试';
    }
  }

  /**
   * Load monthly data (transactions and summary)
   * 需求：3.3, 3.4 - 显示当月交易记录和汇总
   */
  private async loadMonthlyData() {
    if (!this.transactionService) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Get monthly summary
      this.monthlySummary = await this.transactionService.getMonthlySummary(
        this.selectedYear,
        this.selectedMonth
      );
      
      // Get monthly transactions
      const startDate = DateUtils.getStartOfMonth(this.selectedYear, this.selectedMonth);
      const endDate = DateUtils.getEndOfMonth(this.selectedYear, this.selectedMonth);
      const transactions = await this.transactionService.searchTransactions({
        startDate,
        endDate
      });
      
      // Sort by date descending (newest first)
      this.monthlyTransactions = SortUtils.sortByDateDesc(transactions);
    } catch (error) {
      console.error('Failed to load monthly data:', error);
      this.errorMessage = '加载数据失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Navigate to previous month
   */
  private async navigateToPreviousMonth() {
    if (this.selectedMonth === 1) {
      this.selectedMonth = 12;
      this.selectedYear -= 1;
    } else {
      this.selectedMonth -= 1;
    }
    await this.loadMonthlyData();
  }

  /**
   * Navigate to next month
   */
  private async navigateToNextMonth() {
    if (this.selectedMonth === 12) {
      this.selectedMonth = 1;
      this.selectedYear += 1;
    } else {
      this.selectedMonth += 1;
    }
    await this.loadMonthlyData();
  }

  /**
   * Navigate to current month
   */
  private async navigateToCurrentMonth() {
    this.selectedYear = DateUtils.getYear(DateUtils.now());
    this.selectedMonth = DateUtils.getMonth(DateUtils.now());
    await this.loadMonthlyData();
  }

  /**
   * Handle transaction deletion
   */
  private async handleDeleteTransaction(transaction: Transaction) {
    if (!this.transactionService) {
      return;
    }

    try {
      await this.transactionService.deleteTransaction(transaction.id);
      
      // Reload data after deletion
      await this.loadMonthlyData();
    } catch (error) {
      console.error('Failed to delete transaction:', error);
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * Handle back navigation
   */
  private handleBack() {
    router.back();
  }

  /**
   * Check if current month is selected
   */
  private isCurrentMonth(): boolean {
    const currentYear = DateUtils.getYear(DateUtils.now());
    const currentMonth = DateUtils.getMonth(DateUtils.now());
    return this.selectedYear === currentYear && this.selectedMonth === currentMonth;
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      // Header with back button
      this.buildHeader();
      
      // Month selector
      this.buildMonthSelector();
      
      // Monthly summary card
      this.buildMonthlySummaryCard();
      
      // Transaction list
      if (this.isLoading) {
        this.buildLoadingView();
      } else if (this.errorMessage) {
        this.buildErrorView();
      } else {
        TransactionList({
          transactions: $monthlyTransactions,
          showDate: true,
          emptyMessage: '本月还没有记账记录',
          emptyIcon: '📅',
          onDelete: (transaction: Transaction) => {
            this.handleDeleteTransaction(transaction);
          }
        })
      }
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
        Text('< 返回')
          .fontSize(16)
          .fontColor('#1890FF')
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.handleBack();
      })
      
      Text('月度账单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // Placeholder for alignment
      Text('      ')
        .fontSize(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  /**
   * Build month selector
   * 需求：3.3 - 月份选择器
   */
  @Builder
  buildMonthSelector() {
    Row() {
      // Previous month button
      Button() {
        Text('<')
          .fontSize(20)
          .fontColor('#1890FF')
      }
      .width(40)
      .height(40)
      .backgroundColor('#F0F0F0')
      .onClick(() => {
        this.navigateToPreviousMonth();
      })
      
      // Current month display
      Column() {
        Text(`${this.selectedYear}年${this.selectedMonth}月`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        if (!this.isCurrentMonth()) {
          Button('返回本月')
            .fontSize(12)
            .fontColor('#1890FF')
            .backgroundColor(Color.Transparent)
            .height(24)
            .margin({ top: 4 })
            .onClick(() => {
              this.navigateToCurrentMonth();
            })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      
      // Next month button
      Button() {
        Text('>')
          .fontSize(20)
          .fontColor('#1890FF')
      }
      .width(40)
      .height(40)
      .backgroundColor('#F0F0F0')
      .onClick(() => {
        this.navigateToNextMonth();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 1 })
  }

  /**
   * Build monthly summary card
   * 需求：3.4 - 显示当月收入/支出总额和月度汇总
   */
  @Builder
  buildMonthlySummaryCard() {
    if (this.monthlySummary) {
      Column() {
        Text('月度汇总')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })
        
        Row() {
          // Income
          Column() {
            Text('收入')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 4 })
            Text(FormatUtils.formatCurrency(this.monthlySummary.totalIncome))
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
            Text(FormatUtils.formatCurrency(this.monthlySummary.totalExpense))
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
            Text(FormatUtils.formatCurrency(this.monthlySummary.netAmount))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.monthlySummary.netAmount >= 0 ? '#52C41A' : '#FF4D4F')
          }
          .layoutWeight(1)
        }
        .width('100%')
        
        // Category breakdown (if available)
        if (this.monthlySummary.categoryBreakdown.length > 0) {
          Divider()
            .height(1)
            .color('#E8E8E8')
            .margin({ top: 16, bottom: 16 })
          
          Text('分类占比')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 12 })
          
          Column({ space: 8 }) {
            ForEach(this.monthlySummary.categoryBreakdown, (category: CategorySummary) => {
              Row() {
                Text(category.category)
                  .fontSize(14)
                  .fontColor('#666666')
                  .layoutWeight(1)
                
                Text(FormatUtils.formatCurrency(category.amount))
                  .fontSize(14)
                  .fontColor('#333333')
                  .margin({ right: 8 })
                
                Text(FormatUtils.formatPercentage(category.percentage / 100))
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
            }, (category: CategorySummary) => category.category)
          }
          .width('100%')
        }
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
          this.loadMonthlyData();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
