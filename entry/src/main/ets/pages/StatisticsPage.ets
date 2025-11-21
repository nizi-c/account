import { TransactionService } from '../services/TransactionService';
import { StatisticsService, ChartData } from '../services/StatisticsService';
import { TransactionRepository, CategoryRepository } from '../repositories';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Summary, PeriodType, CategorySummary } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { FormatUtils } from '../utils/FormatUtils';
import { ResponsiveUtils } from '../utils/ResponsiveUtils';
import { PieChart } from '../components/PieChart';
import { LineChart } from '../components/LineChart';
import { BottomNavigation } from '../components/BottomNavigation';
import router from '@ohos.router';
import display from '@ohos.display';

/**
 * Chart size interface
 */
interface ChartSize {
  width: number;
  height: number;
}

/**
 * StatisticsPage - 统计页面
 * 显示多维度汇总统计和分类占比
 * 需求：4.1, 4.2, 4.3, 4.5
 */
@Entry
@Component
struct StatisticsPage {
  @State currentPeriod: PeriodType = PeriodType.MONTH;
  @State summary: Summary | null = null;
  @State categoryBreakdown: CategorySummary[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State currentDate: number = DateUtils.now();
  @State displayDateText: string = '';
  @State pieChartData: ChartData = { labels: [], values: [], colors: [] };
  @State lineChartData: ChartData = { labels: [], values: [], colors: [] };
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  @State chartSize: ChartSize = { width: 300, height: 300 };
  
  private transactionService: TransactionService | null = null;
  private statisticsService: StatisticsService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeScreenSize();
    await this.initializeServices();
    await this.loadStatistics();
  }

  /**
   * Initialize screen size for responsive charts
   * 需求：10.4
   */
  private async initializeScreenSize() {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      this.screenWidth = px2vp(defaultDisplay.width);
      this.screenHeight = px2vp(defaultDisplay.height);
      this.chartSize = ResponsiveUtils.getChartSize(this.screenWidth, this.screenHeight);
      
      console.info(`Chart size: ${this.chartSize.width}x${this.chartSize.height}`);
    } catch (error) {
      console.error('Failed to get screen size:', error);
      // Fallback to default size
      this.screenWidth = 360;
      this.screenHeight = 780;
      const fallbackSize: ChartSize = { width: 300, height: 300 };
      this.chartSize = fallbackSize;
    }
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext());
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
   * Load statistics data based on current period
   */
  private async loadStatistics() {
    if (!this.transactionService || !this.statisticsService) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const dateObj = new Date(this.currentDate);
      const year = dateObj.getFullYear();
      const month = dateObj.getMonth() + 1;

      // Get summary based on period type
      switch (this.currentPeriod) {
        case PeriodType.WEEK:
          this.summary = await this.transactionService.getWeeklySummary(this.currentDate);
          this.displayDateText = this.getWeekDisplayText(this.currentDate);
          break;
        case PeriodType.MONTH:
          this.summary = await this.transactionService.getMonthlySummary(year, month);
          this.displayDateText = DateUtils.formatDate(this.currentDate, 'YYYY年MM月');
          break;
        case PeriodType.YEAR:
          this.summary = await this.transactionService.getYearlySummary(year);
          this.displayDateText = `${year}年`;
          break;
        default:
          throw new Error(`Unsupported period type: ${this.currentPeriod}`);
      }

      // Get category breakdown
      this.categoryBreakdown = this.summary.categoryBreakdown;
      
      // Generate chart data
      await this.loadChartData();
    } catch (error) {
      console.error('Failed to load statistics:', error);
      this.errorMessage = '加载统计数据失败';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Load chart data (pie chart and line chart)
   */
  private async loadChartData() {
    if (!this.statisticsService) {
      return;
    }

    try {
      // Generate pie chart data for expense category breakdown
      this.pieChartData = await this.statisticsService.generatePieChartData(
        this.currentPeriod,
        this.currentDate
      );

      // Generate line chart data for income/expense trends
      // Use the period's date range
      const dateObj = new Date(this.currentDate);
      const year = dateObj.getFullYear();
      const month = dateObj.getMonth() + 1;

      let startDate: number;
      let endDate: number;

      switch (this.currentPeriod) {
        case PeriodType.WEEK:
          startDate = DateUtils.getStartOfWeek(this.currentDate);
          endDate = DateUtils.getEndOfWeek(this.currentDate);
          break;
        case PeriodType.MONTH:
          startDate = DateUtils.getStartOfMonth(year, month);
          endDate = DateUtils.getEndOfMonth(year, month);
          break;
        case PeriodType.YEAR:
          startDate = DateUtils.getStartOfYear(year);
          endDate = DateUtils.getEndOfYear(year);
          break;
        default:
          startDate = DateUtils.getStartOfMonth(year, month);
          endDate = DateUtils.getEndOfMonth(year, month);
      }

      this.lineChartData = await this.statisticsService.generateLineChartData(startDate, endDate);
    } catch (error) {
      console.error('Failed to load chart data:', error);
    }
  }

  /**
   * Get week display text
   */
  private getWeekDisplayText(date: number): string {
    const startDate = DateUtils.getStartOfWeek(date);
    const endDate = DateUtils.getEndOfWeek(date);
    const startStr = DateUtils.formatDate(startDate, 'MM-DD');
    const endStr = DateUtils.formatDate(endDate, 'MM-DD');
    return `${startStr} 至 ${endStr}`;
  }

  /**
   * Handle period change
   */
  private async handlePeriodChange(period: PeriodType) {
    if (this.currentPeriod === period) {
      return;
    }
    
    this.currentPeriod = period;
    await this.loadStatistics();
  }

  /**
   * Navigate to previous period
   */
  private async navigateToPreviousPeriod() {
    const dateObj = new Date(this.currentDate);
    
    switch (this.currentPeriod) {
      case PeriodType.WEEK:
        dateObj.setDate(dateObj.getDate() - 7);
        break;
      case PeriodType.MONTH:
        dateObj.setMonth(dateObj.getMonth() - 1);
        break;
      case PeriodType.YEAR:
        dateObj.setFullYear(dateObj.getFullYear() - 1);
        break;
    }
    
    this.currentDate = dateObj.getTime();
    await this.loadStatistics();
  }

  /**
   * Navigate to next period
   */
  private async navigateToNextPeriod() {
    const dateObj = new Date(this.currentDate);
    
    switch (this.currentPeriod) {
      case PeriodType.WEEK:
        dateObj.setDate(dateObj.getDate() + 7);
        break;
      case PeriodType.MONTH:
        dateObj.setMonth(dateObj.getMonth() + 1);
        break;
      case PeriodType.YEAR:
        dateObj.setFullYear(dateObj.getFullYear() + 1);
        break;
    }
    
    this.currentDate = dateObj.getTime();
    await this.loadStatistics();
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
   * Build UI
   */
  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Period selector
      this.buildPeriodSelector();
      
      // Date navigation
      this.buildDateNavigation();
      
      // Content
      if (this.isLoading) {
        this.buildLoadingView();
      } else if (this.errorMessage) {
        this.buildErrorView();
      } else {
        Scroll() {
          Column() {
            // Summary cards
            this.buildSummaryCards();
            
            // Pie chart - Expense category breakdown
            this.buildPieChartSection();
            
            // Line chart - Income/Expense trends
            this.buildLineChartSection();
            
            // Category breakdown list
            this.buildCategoryBreakdown();
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      
      // Bottom navigation bar
      BottomNavigation({ currentPage: 'StatisticsPage' })
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
      
      Text('统计分析')
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
   * Build period selector (周/月/年)
   */
  @Builder
  buildPeriodSelector() {
    Row() {
      this.buildPeriodButton('周', PeriodType.WEEK);
      this.buildPeriodButton('月', PeriodType.MONTH);
      this.buildPeriodButton('年', PeriodType.YEAR);
    }
    .width('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
  }

  /**
   * Build period button
   */
  @Builder
  buildPeriodButton(label: string, period: PeriodType) {
    Button() {
      Text(label)
        .fontSize(16)
        .fontColor(this.currentPeriod === period ? Color.White : '#666666')
    }
    .width(100)
    .height(40)
    .backgroundColor(this.currentPeriod === period ? '#1890FF' : '#F0F0F0')
    .borderRadius(20)
    .onClick(() => {
      this.handlePeriodChange(period);
    })
  }

  /**
   * Build date navigation
   */
  @Builder
  buildDateNavigation() {
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
        this.navigateToPreviousPeriod();
      })
      
      Text(this.displayDateText)
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
        this.navigateToNextPeriod();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * Build summary cards (收入、支出、净收支)
   */
  @Builder
  buildSummaryCards() {
    Column() {
      if (this.summary) {
        // Income card
        this.buildSummaryCard('收入', this.summary.totalIncome, '#52C41A', '💰');
        
        // Expense card
        this.buildSummaryCard('支出', this.summary.totalExpense, '#FF4D4F', '💸');
        
        // Net amount card
        this.buildSummaryCard(
          '结余',
          this.summary.netAmount,
          this.summary.netAmount >= 0 ? '#52C41A' : '#FF4D4F',
          this.summary.netAmount >= 0 ? '📈' : '📉'
        );
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  /**
   * Build single summary card
   */
  @Builder
  buildSummaryCard(label: string, amount: number, color: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(32)
        .margin({ right: 16 })
      
      Column() {
        Text(label)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 4 })
        
        Text(FormatUtils.formatCurrency(amount))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build pie chart section
   */
  @Builder
  buildPieChartSection() {
    Column() {
      // Section header
      Row() {
        Text('支出分类占比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(16)
      
      // Pie chart (responsive size)
      if (this.pieChartData.values.length > 0) {
        Column() {
          PieChart({
            chartData: this.pieChartData,
            width: this.chartSize.width,
            height: this.chartSize.height
          })
        }
        .width('100%')
        .padding(16)
      } else {
        Column() {
          Text('📊')
            .fontSize(48)
            .margin({ bottom: 8 })
          
          Text('暂无支出数据')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(32)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build line chart section
   */
  @Builder
  buildLineChartSection() {
    Column() {
      // Section header
      Row() {
        Text('收支趋势')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(16)
      
      // Line chart (responsive size)
      if (this.lineChartData.values.length > 0) {
        Column() {
          LineChart({
            chartData: this.lineChartData,
            width: this.chartSize.width,
            height: this.chartSize.height * 0.8
          })
        }
        .width('100%')
        .padding(16)
      } else {
        Column() {
          Text('📈')
            .fontSize(48)
            .margin({ bottom: 8 })
          
          Text('暂无趋势数据')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(32)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build category breakdown list
   */
  @Builder
  buildCategoryBreakdown() {
    Column() {
      // Section header
      Row() {
        Text('分类占比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      
      // Category list
      if (this.categoryBreakdown.length === 0) {
        this.buildEmptyCategoryView();
      } else {
        Column() {
          ForEach(this.categoryBreakdown, (category: CategorySummary, index: number) => {
            this.buildCategoryItem(category, index);
          }, (category: CategorySummary) => category.category)
        }
        .width('100%')
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
  }

  /**
   * Build category item
   */
  @Builder
  buildCategoryItem(category: CategorySummary, index: number) {
    Column() {
      Row() {
        // Category name
        Text(category.category)
          .fontSize(16)
          .fontColor('#333333')
          .layoutWeight(1)
        
        // Amount
        Text(FormatUtils.formatCurrency(category.amount))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF4D4F')
          .margin({ right: 8 })
        
        // Percentage
        Text(`${FormatUtils.formatPercentage(category.percentage)}`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      
      // Progress bar
      Row() {
        Row()
          .width(`${category.percentage}%`)
          .height(4)
          .backgroundColor('#1890FF')
          .borderRadius(2)
      }
      .width('100%')
      .height(4)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F0F0F0')
      .borderRadius(2)
      .margin({ bottom: 12 })
      
      // Divider (except for last item)
      if (index < this.categoryBreakdown.length - 1) {
        Divider()
          .color('#F0F0F0')
          .strokeWidth(1)
      }
    }
    .width('100%')
  }

  /**
   * Build empty category view
   */
  @Builder
  buildEmptyCategoryView() {
    Column() {
      Text('📊')
        .fontSize(48)
        .margin({ bottom: 8 })
      
      Text('暂无分类数据')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(32)
    .backgroundColor(Color.White)
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
          this.loadStatistics();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
