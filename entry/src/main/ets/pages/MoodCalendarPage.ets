import { TransactionService } from '../services/TransactionService';
import { StatisticsService } from '../services/StatisticsService';
import { TransactionRepository, CategoryRepository } from '../repositories';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Transaction, MoodType } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { TransactionList } from '../components/TransactionList';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

/**
 * Mood Calendar Page - 情绪日历页面
 * 显示每日的主要消费情绪，支持点击查看详情
 * 需求：7.4, 7.5
 */
@Entry
@Component
struct MoodCalendarPage {
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth() + 1;
  @State moodCalendarData: Map<number, string> = new Map();
  @State selectedDay: number = 0;
  @State selectedDayTransactions: Transaction[] = [];
  @State showTransactionList: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State moodStatistics: Map<MoodType, number> = new Map();

  private transactionService: TransactionService | null = null;
  private statisticsService: StatisticsService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeServices();
    await this.loadMoodCalendar();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const context = getContext() as common.UIAbilityContext;
      const store = await dbManager.initialize(context);
      const transactionRepository = new TransactionRepository();
      transactionRepository.setStore(store);
      const categoryRepository = new CategoryRepository();
      categoryRepository.setStore(store);

      this.transactionService = new TransactionService(transactionRepository);
      this.statisticsService = new StatisticsService(transactionRepository, categoryRepository);
    } catch (error) {
      console.error('Failed to initialize services:', error);
      this.errorMessage = '初始化失败，请重试';
    }
  }

  /**
   * Load mood calendar data for current month
   */
  private async loadMoodCalendar() {
    if (!this.statisticsService || !this.transactionService) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Generate mood calendar data
      const calendarData = await this.statisticsService!.generateMoodCalendar(this.currentYear, this.currentMonth);

      this.moodCalendarData = calendarData.days;

      // Calculate mood statistics for the month
      await this.calculateMoodStatistics();
    } catch (error) {
      console.error('Failed to load mood calendar:', error);
      this.errorMessage = '加载情绪日历失败';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Calculate mood statistics for the current month
   */
  private async calculateMoodStatistics() {
    if (!this.transactionService) {
      return;
    }

    try {
      const startDate = DateUtils.getStartOfMonth(this.currentYear, this.currentMonth);
      const endDate = DateUtils.getEndOfMonth(this.currentYear, this.currentMonth);

      const transactions = await this.transactionService!.searchTransactions({
        startDate,
        endDate
      });

      // Count moods
      const moodCounts = new Map<MoodType, number>();
      moodCounts.set(MoodType.SATISFIED, 0);
      moodCounts.set(MoodType.REGRET, 0);
      moodCounts.set(MoodType.SURPRISE, 0);

      transactions.forEach(transaction => {
        if (transaction.mood) {
          moodCounts.set(transaction.mood, (moodCounts.get(transaction.mood) || 0) + 1);
        }
      });

      this.moodStatistics = moodCounts;
    } catch (error) {
      console.error('Failed to calculate mood statistics:', error);
    }
  }

  /**
   * Navigate to previous month
   */
  private previousMonth() {
    if (this.currentMonth === 1) {
      this.currentMonth = 12;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
    this.loadMoodCalendar();
  }

  /**
   * Navigate to next month
   */
  private nextMonth() {
    if (this.currentMonth === 12) {
      this.currentMonth = 1;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
    this.loadMoodCalendar();
  }

  /**
   * Handle day cell click
   */
  private async handleDayClick(day: number) {
    if (!this.transactionService) {
      return;
    }

    this.selectedDay = day;

    try {
      // Get transactions for the selected day
      const selectedDate = new Date(this.currentYear, this.currentMonth - 1, day);
      const startDate = DateUtils.getStartOfDay(selectedDate.getTime());
      const endDate = DateUtils.getEndOfDay(selectedDate.getTime());

      const transactions = await this.transactionService!.searchTransactions({
        startDate,
        endDate
      });

      // Filter transactions with mood tags
      this.selectedDayTransactions = transactions.filter(t => t.mood !== undefined);

      if (this.selectedDayTransactions.length > 0) {
        this.showTransactionList = true;
      } else {
        promptAction.showToast({
          message: '该日期没有情绪记录',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to load day transactions:', error);
      promptAction.showToast({
        message: '加载失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * Close transaction list dialog
   */
  private closeTransactionList() {
    this.showTransactionList = false;
    this.selectedDay = 0;
    this.selectedDayTransactions = [];
  }

  /**
   * Handle transaction deletion
   */
  private async handleDeleteTransaction(transaction: Transaction) {
    if (!this.transactionService) {
      return;
    }

    try {
      await this.transactionService!.deleteTransaction(transaction.id);

      // Reload calendar and selected day transactions
      await this.loadMoodCalendar();

      // Update selected day transactions
      if (this.selectedDay > 0) {
        const selectedDate = new Date(this.currentYear, this.currentMonth - 1, this.selectedDay);
        const startDate = DateUtils.getStartOfDay(selectedDate.getTime());
        const endDate = DateUtils.getEndOfDay(selectedDate.getTime());

        const transactions = await this.transactionService!.searchTransactions({
          startDate,
          endDate
        });

        this.selectedDayTransactions = transactions.filter(t => t.mood !== undefined);

        if (this.selectedDayTransactions.length === 0) {
          this.closeTransactionList();
        }
      }
    } catch (error) {
      console.error('Failed to delete transaction:', error);
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * Get mood emoji
   */
  private getMoodEmoji(mood: MoodType): string {
    switch (mood) {
      case MoodType.SATISFIED:
        return '😊';
      case MoodType.REGRET:
        return '😟';
      case MoodType.SURPRISE:
        return '🎉';
      default:
        return '😐';
    }
  }

  /**
   * Get mood name
   */
  private getMoodName(mood: MoodType): string {
    switch (mood) {
      case MoodType.SATISFIED:
        return '满意';
      case MoodType.REGRET:
        return '后悔';
      case MoodType.SURPRISE:
        return '惊喜';
      default:
        return '未知';
    }
  }

  /**
   * Helper methods for buildDayCell
   */
  private getDayNumber(index: number, firstDayOfMonth: number): number {
    return index - firstDayOfMonth + 1;
  }

  private isDayValid(index: number, firstDayOfMonth: number, daysInMonth: number): boolean {
    const day = this.getDayNumber(index, firstDayOfMonth);
    return day > 0 && day <= daysInMonth;
  }

  private hasMoodForDay(index: number, firstDayOfMonth: number, daysInMonth: number): boolean {
    if (!this.isDayValid(index, firstDayOfMonth, daysInMonth)) {
      return false;
    }
    const day = this.getDayNumber(index, firstDayOfMonth);
    return this.moodCalendarData.has(day);
  }

  private getMoodEmojiForDay(index: number, firstDayOfMonth: number, daysInMonth: number): string {
    if (!this.hasMoodForDay(index, firstDayOfMonth, daysInMonth)) {
      return '';
    }
    const day = this.getDayNumber(index, firstDayOfMonth);
    return this.moodCalendarData.get(day) || '';
  }

  private getDayCellBackgroundColor(index: number, firstDayOfMonth: number, daysInMonth: number): string {
    if (this.isDayValid(index, firstDayOfMonth, daysInMonth) && 
        this.hasMoodForDay(index, firstDayOfMonth, daysInMonth)) {
      return '#E6F7FF';
    }
    return '#FAFAFA';
  }

  /**
   * Build UI
   */
  build() {
    Stack() {
      Column() {
        // Header
        this.buildHeader();

        // Month navigation
        this.buildMonthNavigation();

        // Mood statistics
        this.buildMoodStatistics();

        // Calendar grid
        if (this.isLoading) {
          this.buildLoadingView();
        } else if (this.errorMessage) {
          this.buildErrorView();
        } else {
          this.buildCalendar();
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // Transaction list overlay
      if (this.showTransactionList) {
        this.buildTransactionListOverlay();
      }
    }
    .width('100%')
    .height('100%')
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
        router.back();
      })

      Text('情绪日历')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // Placeholder for symmetry
      Row()
        .width(48)
        .height(48)
    }
    .width('100%')
    .padding({ left: 8, right: 16, top: 16, bottom: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * Build month navigation
   */
  @Builder
  buildMonthNavigation() {
    Row() {
      Button() {
        Text('◀')
          .fontSize(20)
          .fontColor('#1890FF')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.previousMonth();
      })

      Text(`${this.currentYear}年 ${this.currentMonth}月`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button() {
        Text('▶')
          .fontSize(20)
          .fontColor('#1890FF')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.nextMonth();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .margin({ top: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * Build mood statistics
   */
  @Builder
  buildMoodStatistics() {
    Column() {
      Text('本月情绪统计')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 12 })

      Row() {
        // Satisfied
        Column() {
          Text('😊')
            .fontSize(32)
          Text('满意')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
          Text(`${this.moodStatistics.get(MoodType.SATISFIED) || 0}次`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        // Regret
        Column() {
          Text('😟')
            .fontSize(32)
          Text('后悔')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
          Text(`${this.moodStatistics.get(MoodType.REGRET) || 0}次`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        // Surprise
        Column() {
          Text('🎉')
            .fontSize(32)
          Text('惊喜')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
          Text(`${this.moodStatistics.get(MoodType.SURPRISE) || 0}次`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FA8C16')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 8 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build calendar grid
   */
  @Builder
  buildCalendar() {
    Column() {
      // Weekday headers
      Row() {
        Text('日').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('一').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('二').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('三').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('四').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('五').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
        Text('六').fontSize(14).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      // Calendar grid
      this.buildCalendarGrid();
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 8 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build calendar grid with days
   */
  @Builder
  buildCalendarGrid() {
    Grid() {
      ForEach(this.generateCellIndices(), (index: number) => {
        GridItem() {
          this.buildDayCell(
            index,
            new Date(this.currentYear, this.currentMonth - 1, 1).getDay(),
            DateUtils.getDaysInMonth(this.currentYear, this.currentMonth)
          )
        }
      }, (index: number) => index.toString())
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(8)
    .columnsGap(8)
    .width('100%')
  }

  /**
   * Generate array of cell indices
   */
  private generateCellIndices(): number[] {
    const daysInMonth = DateUtils.getDaysInMonth(this.currentYear, this.currentMonth);
    const firstDayOfMonth = new Date(this.currentYear, this.currentMonth - 1, 1).getDay();
    const totalCells = Math.ceil((daysInMonth + firstDayOfMonth) / 7) * 7;

    // Create array of indices
    const cellIndices: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      cellIndices.push(i);
    }

    return cellIndices;
  }

  /**
   * Build individual day cell
   */
  @Builder
  buildDayCell(index: number, firstDayOfMonth: number, daysInMonth: number) {
    Column() {
      if (this.isDayValid(index, firstDayOfMonth, daysInMonth)) {
        Text(`${this.getDayNumber(index, firstDayOfMonth)}`)
          .fontSize(14)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        if (this.hasMoodForDay(index, firstDayOfMonth, daysInMonth)) {
          Text(this.getMoodEmojiForDay(index, firstDayOfMonth, daysInMonth))
            .fontSize(24)
        }
      }
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getDayCellBackgroundColor(index, firstDayOfMonth, daysInMonth))
    .borderRadius(4)
    .onClick(() => {
      if (this.isDayValid(index, firstDayOfMonth, daysInMonth) && 
          this.hasMoodForDay(index, firstDayOfMonth, daysInMonth)) {
        this.handleDayClick(this.getDayNumber(index, firstDayOfMonth));
      }
    })
  }

  /**
   * Build transaction list overlay
   */
  @Builder
  buildTransactionListOverlay() {
    Stack() {
      // Semi-transparent background
      Column() {
        // Empty content for background
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .onClick(() => {
        this.closeTransactionList();
      })

      // Transaction list panel
      this.buildTransactionPanel()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * Build transaction panel
   */
  @Builder
  buildTransactionPanel() {
    Column() {
      // Header
      Row() {
        Text(this.getTransactionHeader())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        Button() {
          Text('✕')
            .fontSize(24)
            .fontColor('#999999')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.closeTransactionList();
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // Transaction list
      TransactionList({
        transactions: $selectedDayTransactions,
        showDate: false,
        emptyMessage: '该日期没有情绪记录',
        emptyIcon: '😐',
        onDelete: (transaction: Transaction) => {
          this.handleDeleteTransaction(transaction);
        }
      })
        .height(400)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: this.showTransactionList ? -400 : 0 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  /**
   * Get transaction header text
   */
  private getTransactionHeader(): string {
    return `${this.currentMonth}月${this.selectedDay}日 情绪记录`;
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
    .height(300)
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
          this.loadMoodCalendar();
        })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }
}
