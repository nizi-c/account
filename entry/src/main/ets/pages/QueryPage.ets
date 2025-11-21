import { TransactionService } from '../services/TransactionService';
import { CategoryService } from '../services/CategoryService';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { CategoryRepository } from '../repositories/CategoryRepository';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Transaction, TransactionFilter, TransactionType, Category } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { SortUtils } from '../utils/SortUtils';
import { TransactionList } from '../components/TransactionList';
import { BottomNavigation } from '../components/BottomNavigation';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * QueryPage - 查询页面
 * 提供高级筛选功能：金额范围、用途关键词、日期范围、分类多选
 * 需求：5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 9.3
 */
@Entry
@Component
struct QueryPage {
  // Filter state
  @State minAmount: string = '';
  @State maxAmount: string = '';
  @State keyword: string = '';
  @State startDate: number | undefined = undefined;
  @State endDate: number | undefined = undefined;
  @State selectedCategories: string[] = [];
  @State selectedType: TransactionType | undefined = undefined;
  
  // UI state
  @State categories: Category[] = [];
  @State queryResults: Transaction[] = [];
  @State isLoading: boolean = false;
  @State isQuerying: boolean = false;
  @State hasQueried: boolean = false;
  @State showStartDatePicker: boolean = false;
  @State showEndDatePicker: boolean = false;
  @State showCategorySelector: boolean = false;
  
  // Validation errors
  @State amountError: string = '';
  @State dateError: string = '';
  
  private transactionService: TransactionService | null = null;
  private categoryService: CategoryService | null = null;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeServices();
    await this.loadCategories();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext());
      
      const transactionRepo = new TransactionRepository();
      transactionRepo.setStore(store);
      const categoryRepo = new CategoryRepository();
      categoryRepo.setStore(store);
      
      this.transactionService = new TransactionService(transactionRepo);
      this.categoryService = new CategoryService(categoryRepo);
    } catch (error) {
      console.error('Failed to initialize services:', error);
      promptAction.showToast({
        message: '初始化失败，请返回重试',
        duration: 2000
      });
    }
  }

  /**
   * Load all categories
   */
  private async loadCategories() {
    if (!this.categoryService) {
      return;
    }

    this.isLoading = true;
    try {
      this.categories = await this.categoryService.getAllCategories();
    } catch (error) {
      console.error('Failed to load categories:', error);
      promptAction.showToast({
        message: '加载分类失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Validate query parameters
   */
  private validateQuery(): boolean {
    this.amountError = '';
    this.dateError = '';
    
    // Validate amount range
    if (this.minAmount && this.maxAmount) {
      const min = parseFloat(this.minAmount);
      const max = parseFloat(this.maxAmount);
      
      if (isNaN(min) || isNaN(max)) {
        this.amountError = '金额格式不正确';
        return false;
      }
      
      if (min < 0 || max < 0) {
        this.amountError = '金额不能为负数';
        return false;
      }
      
      if (min > max) {
        this.amountError = '最小金额不能大于最大金额';
        return false;
      }
    }
    
    // Validate date range
    if (this.startDate !== undefined && this.endDate !== undefined) {
      if (this.startDate > this.endDate) {
        this.dateError = '开始日期不能晚于结束日期';
        return false;
      }
    }
    
    return true;
  }

  /**
   * Handle query action
   * 需求：5.1, 5.2, 5.3, 5.4, 5.5
   */
  private async handleQuery() {
    // Validate query parameters
    if (!this.validateQuery()) {
      return;
    }
    
    if (!this.transactionService) {
      promptAction.showToast({
        message: '服务未初始化，请返回重试',
        duration: 2000
      });
      return;
    }
    
    this.isQuerying = true;
    this.hasQueried = true;
    
    try {
      // Build filter
      const filter: TransactionFilter = {};
      
      // Amount range (需求 5.1)
      if (this.minAmount) {
        filter.minAmount = parseFloat(this.minAmount);
      }
      if (this.maxAmount) {
        filter.maxAmount = parseFloat(this.maxAmount);
      }
      
      // Keyword search (需求 5.2)
      if (this.keyword && this.keyword.trim()) {
        filter.description = this.keyword.trim();
      }
      
      // Date range (需求 5.3)
      if (this.startDate !== undefined) {
        filter.startDate = DateUtils.getStartOfDay(this.startDate);
      }
      if (this.endDate !== undefined) {
        filter.endDate = DateUtils.getEndOfDay(this.endDate);
      }
      
      // Category filter (需求 5.4)
      if (this.selectedCategories.length > 0) {
        filter.categories = this.selectedCategories;
      }
      
      // Type filter
      if (this.selectedType !== undefined) {
        filter.type = this.selectedType;
      }
      
      // Execute query (需求 5.5 - 复合查询)
      const results = await this.transactionService.searchTransactions(filter);
      
      // Sort results by date descending
      this.queryResults = SortUtils.sortByDateDesc(results);
      
      // Show result count
      promptAction.showToast({
        message: `找到 ${results.length} 条记录`,
        duration: 1500
      });
    } catch (error) {
      console.error('Failed to query transactions:', error);
      promptAction.showToast({
        message: '查询失败，请重试',
        duration: 2000
      });
    } finally {
      this.isQuerying = false;
    }
  }

  /**
   * Handle reset action
   */
  private handleReset() {
    this.minAmount = '';
    this.maxAmount = '';
    this.keyword = '';
    this.startDate = undefined;
    this.endDate = undefined;
    this.selectedCategories = [];
    this.selectedType = undefined;
    this.queryResults = [];
    this.hasQueried = false;
    this.amountError = '';
    this.dateError = '';
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
      
      // Re-query to update results
      await this.handleQuery();
    } catch (error) {
      console.error('Failed to delete transaction:', error);
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * Handle back navigation to home
   */
  private handleBack() {
    router.replaceUrl({
      url: 'pages/Index'
    }).catch((error: Error) => {
      console.error('Failed to navigate back:', error);
    });
  }

  /**
   * Toggle category selection
   */
  private toggleCategory(categoryName: string) {
    const index = this.selectedCategories.indexOf(categoryName);
    if (index > -1) {
      this.selectedCategories.splice(index, 1);
    } else {
      this.selectedCategories.push(categoryName);
    }
  }

  /**
   * Check if category is selected
   */
  private isCategorySelected(categoryName: string): boolean {
    return this.selectedCategories.indexOf(categoryName) > -1;
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Content
      Column() {
        // Query form
        Scroll() {
          Column({ space: 16 }) {
            // Amount range input
            this.buildAmountRangeInput();
            
            // Keyword search
            this.buildKeywordInput();
            
            // Date range picker
            this.buildDateRangePicker();
            
            // Type selector
            this.buildTypeSelector();
            
            // Category multi-select
            this.buildCategoryMultiSelect();
            
            // Action buttons
            this.buildActionButtons();
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        
        // Query results
        if (this.hasQueried) {
          this.buildQueryResults();
        }
      }
      .layoutWeight(1)
      
      // Bottom navigation bar
      BottomNavigation({ currentPage: 'QueryPage' })
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
      
      Text('高级查询')
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
   * Build amount range input
   * 需求：5.1 - 金额范围输入
   */
  @Builder
  buildAmountRangeInput() {
    Column({ space: 8 }) {
      Text('金额范围')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          TextInput({ placeholder: '最小金额', text: this.minAmount })
            .type(InputType.Number)
            .fontSize(16)
            .height(48)
            .borderRadius(4)
            .backgroundColor('#FAFAFA')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.minAmount = value;
              this.amountError = '';
            })
        }
        .layoutWeight(1)
        
        Text('至')
          .fontSize(14)
          .fontColor('#999999')
        
        Column({ space: 4 }) {
          TextInput({ placeholder: '最大金额', text: this.maxAmount })
            .type(InputType.Number)
            .fontSize(16)
            .height(48)
            .borderRadius(4)
            .backgroundColor('#FAFAFA')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.maxAmount = value;
              this.amountError = '';
            })
        }
        .layoutWeight(1)
      }
      .width('100%')
      
      if (this.amountError) {
        Text(this.amountError)
          .fontSize(12)
          .fontColor('#FF4D4F')
          .alignSelf(ItemAlign.Start)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build keyword input
   * 需求：5.2 - 用途关键词搜索
   */
  @Builder
  buildKeywordInput() {
    Column({ space: 8 }) {
      Text('用途关键词')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      TextInput({ placeholder: '输入关键词搜索', text: this.keyword })
        .fontSize(16)
        .height(48)
        .borderRadius(4)
        .backgroundColor('#FAFAFA')
        .onChange((value: string) => {
          this.keyword = value;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build date range picker
   * 需求：5.3 - 日期范围选择器
   */
  @Builder
  buildDateRangePicker() {
    Column({ space: 8 }) {
      Text('日期范围')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Row({ space: 12 }) {
        // Start date
        Button() {
          Row() {
            Text(this.startDate !== undefined ? 
              DateUtils.formatDate(this.startDate, 'YYYY-MM-DD') : 
              '开始日期')
              .fontSize(14)
              .fontColor(this.startDate !== undefined ? '#333333' : '#999999')
            
            Blank()
            
            Text('📅')
              .fontSize(16)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#FAFAFA')
        .borderRadius(4)
        .onClick(() => {
          this.showStartDatePicker = true;
        })
        
        Text('至')
          .fontSize(14)
          .fontColor('#999999')
        
        // End date
        Button() {
          Row() {
            Text(this.endDate !== undefined ? 
              DateUtils.formatDate(this.endDate, 'YYYY-MM-DD') : 
              '结束日期')
              .fontSize(14)
              .fontColor(this.endDate !== undefined ? '#333333' : '#999999')
            
            Blank()
            
            Text('📅')
              .fontSize(16)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#FAFAFA')
        .borderRadius(4)
        .onClick(() => {
          this.showEndDatePicker = true;
        })
      }
      .width('100%')
      
      if (this.dateError) {
        Text(this.dateError)
          .fontSize(12)
          .fontColor('#FF4D4F')
          .alignSelf(ItemAlign.Start)
      }
      
      // Date pickers
      if (this.showStartDatePicker) {
        DatePicker({
          start: new Date('1970-1-1'),
          end: new Date('2100-12-31'),
          selected: this.startDate !== undefined ? new Date(this.startDate) : new Date()
        })
          .onChange((value: DatePickerResult) => {
            const date = new Date(value.year!, value.month!, value.day!);
            this.startDate = date.getTime();
            this.showStartDatePicker = false;
            this.dateError = '';
          })
      }
      
      if (this.showEndDatePicker) {
        DatePicker({
          start: new Date('1970-1-1'),
          end: new Date('2100-12-31'),
          selected: this.endDate !== undefined ? new Date(this.endDate) : new Date()
        })
          .onChange((value: DatePickerResult) => {
            const date = new Date(value.year!, value.month!, value.day!);
            this.endDate = date.getTime();
            this.showEndDatePicker = false;
            this.dateError = '';
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build type selector
   */
  @Builder
  buildTypeSelector() {
    Column({ space: 8 }) {
      Text('交易类型')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Row({ space: 12 }) {
        Button('全部')
          .fontSize(14)
          .fontColor(this.selectedType === undefined ? Color.White : '#333333')
          .backgroundColor(this.selectedType === undefined ? '#1890FF' : '#F0F0F0')
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.selectedType = undefined;
          })
        
        Button('收入')
          .fontSize(14)
          .fontColor(this.selectedType === TransactionType.INCOME ? Color.White : '#333333')
          .backgroundColor(this.selectedType === TransactionType.INCOME ? '#52C41A' : '#F0F0F0')
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.selectedType = TransactionType.INCOME;
          })
        
        Button('支出')
          .fontSize(14)
          .fontColor(this.selectedType === TransactionType.EXPENSE ? Color.White : '#333333')
          .backgroundColor(this.selectedType === TransactionType.EXPENSE ? '#FF4D4F' : '#F0F0F0')
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.selectedType = TransactionType.EXPENSE;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build category multi-select
   * 需求：5.4 - 分类多选
   */
  @Builder
  buildCategoryMultiSelect() {
    Column({ space: 8 }) {
      Row() {
        Text('分类筛选')
          .fontSize(14)
          .fontColor('#666666')
        
        Blank()
        
        if (this.selectedCategories.length > 0) {
          Text(`已选 ${this.selectedCategories.length} 个`)
            .fontSize(12)
            .fontColor('#1890FF')
        }
      }
      .width('100%')
      
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#1890FF')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .height(48)
        .justifyContent(FlexAlign.Center)
      } else {
        Grid() {
          ForEach(this.categories, (category: Category) => {
            GridItem() {
              Button() {
                Column({ space: 4 }) {
                  Text(category.icon || '📁')
                    .fontSize(20)
                  
                  Text(category.name)
                    .fontSize(11)
                    .fontColor(this.isCategorySelected(category.name) ? Color.White : '#333333')
                }
              }
              .width('100%')
              .height(64)
              .backgroundColor(this.isCategorySelected(category.name) ? '#1890FF' : '#F0F0F0')
              .borderRadius(8)
              .onClick(() => {
                this.toggleCategory(category.name);
              })
            }
          }, (category: Category) => category.id)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build action buttons
   */
  @Builder
  buildActionButtons() {
    Row({ space: 12 }) {
      Button('重置')
        .fontSize(16)
        .fontColor('#666666')
        .backgroundColor('#F0F0F0')
        .layoutWeight(1)
        .height(48)
        .borderRadius(8)
        .onClick(() => {
          this.handleReset();
        })
      
      Button(this.isQuerying ? '查询中...' : '查询')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#1890FF')
        .layoutWeight(1)
        .height(48)
        .borderRadius(8)
        .enabled(!this.isQuerying)
        .onClick(() => {
          this.handleQuery();
        })
    }
    .width('100%')
  }

  /**
   * Build query results
   * 需求：5.6 - 查询结果列表显示和空结果提示
   */
  @Builder
  buildQueryResults() {
    Column() {
      // Results header
      Row() {
        Text('查询结果')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(`共 ${this.queryResults.length} 条`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .backgroundColor(Color.White)
      
      // Results list
      TransactionList({
        transactions: $queryResults,
        showDate: true,
        emptyMessage: '没有找到符合条件的记录\n请调整筛选条件后重试',
        emptyIcon: '🔍',
        onDelete: (transaction: Transaction) => {
          this.handleDeleteTransaction(transaction);
        }
      })
    }
    .layoutWeight(1)
  }
}
