import { TransactionService } from '../services/TransactionService';
import { CategoryService } from '../services/CategoryService';
import { BudgetService } from '../services/BudgetService';
import { TransactionRepository } from '../repositories/TransactionRepository';
import { CategoryRepository } from '../repositories/CategoryRepository';
import { BudgetRepository } from '../repositories/BudgetRepository';
import { DatabaseManager } from '../utils/DatabaseManager';
import { TransactionType, MoodType, TransactionInput, Category } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { FormatUtils } from '../utils/FormatUtils';
import { ErrorHandler, AppError } from '../utils/ErrorHandler';
import { Toast } from '../components/Toast';
import { LoadingIndicator } from '../components/LoadingIndicator';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * AddTransactionPage - 添加交易页面
 * 创建交易输入表单（金额、用途、日期、分类、情绪）
 * 需求：1.1, 1.4, 2.1, 2.2, 2.3, 7.1, 7.2, 9.2
 */
@Entry
@Component
struct AddTransactionPage {
  // Form state
  @State transactionType: TransactionType = TransactionType.EXPENSE;
  @State amount: string = '';
  @State description: string = '';
  @State selectedCategory: string = '';
  @State selectedMood: MoodType | undefined = undefined;
  @State selectedDate: number = DateUtils.now();
  
  // UI state
  @State categories: Category[] = [];
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;
  @State showDatePicker: boolean = false;
  
  // Validation errors
  @State amountError: string = '';
  @State descriptionError: string = '';
  @State categoryError: string = '';
  
  private transactionService: TransactionService | null = null;
  private categoryService: CategoryService | null = null;
  private budgetService: BudgetService | null = null;

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
      const store = await dbManager.initialize(getContext(this));
      
      const transactionRepo = new TransactionRepository();
      transactionRepo.setStore(store);
      const categoryRepo = new CategoryRepository();
      categoryRepo.setStore(store);
      const budgetRepo = new BudgetRepository();
      budgetRepo.setStore(store);
      
      this.transactionService = new TransactionService(transactionRepo);
      this.categoryService = new CategoryService(categoryRepo);
      this.budgetService = new BudgetService(budgetRepo, transactionRepo);
      
      // Link budget service to transaction service for automatic updates
      this.transactionService.setBudgetService(this.budgetService);
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('初始化失败，请返回重试');
    }
  }

  /**
   * Load categories based on transaction type
   */
  private async loadCategories() {
    if (!this.categoryService) {
      return;
    }

    this.isLoading = true;
    try {
      if (this.transactionType === TransactionType.INCOME) {
        this.categories = await this.categoryService.getIncomeCategories();
      } else {
        this.categories = await this.categoryService.getExpenseCategories();
      }
      
      // Auto-select first category if available
      if (this.categories.length > 0 && !this.selectedCategory) {
        this.selectedCategory = this.categories[0].name;
      }
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('加载分类失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Handle transaction type change
   */
  private async handleTypeChange(type: TransactionType) {
    this.transactionType = type;
    this.selectedCategory = ''; // Reset category selection
    await this.loadCategories();
  }

  /**
   * Validate form
   */
  private validateForm(): boolean {
    let isValid = true;
    
    // Reset errors
    this.amountError = '';
    this.descriptionError = '';
    this.categoryError = '';
    
    // Validate amount
    const amountNum = parseFloat(this.amount);
    if (!this.amount || this.amount.trim() === '') {
      this.amountError = '请输入金额';
      isValid = false;
    } else if (isNaN(amountNum)) {
      this.amountError = '金额格式不正确';
      isValid = false;
    } else if (amountNum <= 0) {
      this.amountError = '金额必须大于0';
      isValid = false;
    }
    
    // Validate description
    if (!this.description || this.description.trim() === '') {
      this.descriptionError = '请输入用途说明';
      isValid = false;
    }
    
    // Validate category
    if (!this.selectedCategory) {
      this.categoryError = '请选择分类';
      isValid = false;
    }
    
    return isValid;
  }

  /**
   * Handle form submission
   */
  private async handleSubmit() {
    // Validate form
    if (!this.validateForm()) {
      return;
    }
    
    if (!this.transactionService) {
      Toast.error('服务未初始化，请返回重试');
      return;
    }
    
    this.isSaving = true;
    
    try {
      const transactionInput: TransactionInput = {
        type: this.transactionType,
        amount: parseFloat(this.amount),
        category: this.selectedCategory,
        description: this.description.trim(),
        date: this.selectedDate,
        mood: this.selectedMood
      };
      
      await this.transactionService.addTransaction(transactionInput);
      
      // Show success message
      Toast.success('保存成功');
      
      // Navigate back
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (error) {
      // Error is already handled by ErrorHandler in the service
      // Just show a user-friendly message
      if (error instanceof AppError) {
        // AppError already shown by ErrorHandler
      } else {
        ErrorHandler.handle(error as Error);
        Toast.error('保存失败，请重试');
      }
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * Handle back navigation
   */
  private handleBack() {
    router.back();
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
        return '';
    }
  }

  /**
   * Get mood label
   */
  private getMoodLabel(mood: MoodType): string {
    switch (mood) {
      case MoodType.SATISFIED:
        return '满意';
      case MoodType.REGRET:
        return '后悔';
      case MoodType.SURPRISE:
        return '惊喜';
      default:
        return '';
    }
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Form content
      Scroll() {
        Column({ space: 16 }) {
          // Transaction type selector
          this.buildTypeSelector();
          
          // Amount input
          this.buildAmountInput();
          
          // Description input
          this.buildDescriptionInput();
          
          // Date picker
          this.buildDatePicker();
          
          // Category selector
          this.buildCategorySelector();
          
          // Mood selector
          this.buildMoodSelector();
          
          // Submit button
          this.buildSubmitButton();
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
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
      
      Text('添加账单')
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
   * Build transaction type selector
   */
  @Builder
  buildTypeSelector() {
    Column({ space: 8 }) {
      Text('类型')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Row({ space: 12 }) {
        Button('支出')
          .fontSize(16)
          .fontColor(this.transactionType === TransactionType.EXPENSE ? Color.White : '#333333')
          .backgroundColor(this.transactionType === TransactionType.EXPENSE ? '#FF4D4F' : '#F0F0F0')
          .layoutWeight(1)
          .height(48)
          .onClick(() => {
            this.handleTypeChange(TransactionType.EXPENSE);
          })
        
        Button('收入')
          .fontSize(16)
          .fontColor(this.transactionType === TransactionType.INCOME ? Color.White : '#333333')
          .backgroundColor(this.transactionType === TransactionType.INCOME ? '#52C41A' : '#F0F0F0')
          .layoutWeight(1)
          .height(48)
          .onClick(() => {
            this.handleTypeChange(TransactionType.INCOME);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  /**
   * Build amount input
   */
  @Builder
  buildAmountInput() {
    Column({ space: 8 }) {
      Text('金额 *')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      TextInput({ placeholder: '请输入金额', text: this.amount })
        .type(InputType.Number)
        .fontSize(16)
        .height(48)
        .borderRadius(4)
        .backgroundColor('#FAFAFA')
        .onChange((value: string) => {
          this.amount = value;
          this.amountError = ''; // Clear error on change
        })
      
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
   * Build description input
   */
  @Builder
  buildDescriptionInput() {
    Column({ space: 8 }) {
      Text('用途说明 *')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      TextInput({ placeholder: '请输入用途说明', text: this.description })
        .fontSize(16)
        .height(48)
        .borderRadius(4)
        .backgroundColor('#FAFAFA')
        .maxLength(100)
        .onChange((value: string) => {
          this.description = value;
          this.descriptionError = ''; // Clear error on change
        })
      
      if (this.descriptionError) {
        Text(this.descriptionError)
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
   * Build date picker
   */
  @Builder
  buildDatePicker() {
    Column({ space: 8 }) {
      Text('日期')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Button() {
        Row() {
          Text(DateUtils.formatDate(this.selectedDate, 'YYYY-MM-DD'))
            .fontSize(16)
            .fontColor('#333333')
          
          Blank()
          
          Text('📅')
            .fontSize(18)
        }
        .width('100%')
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FAFAFA')
      .borderRadius(4)
      .onClick(() => {
        this.showDatePicker = true;
      })
      
      if (this.showDatePicker) {
        DatePicker({
          start: new Date('1970-1-1'),
          end: new Date('2100-12-31'),
          selected: new Date(this.selectedDate)
        })
          .onChange((value: DatePickerResult) => {
            const year = value.year ?? new Date(this.selectedDate).getFullYear();
            const month = value.month ?? new Date(this.selectedDate).getMonth();
            const day = value.day ?? new Date(this.selectedDate).getDate();
            const date = new Date(year, month, day);
            this.selectedDate = date.getTime();
            this.showDatePicker = false;
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
   * Build category selector
   */
  @Builder
  buildCategorySelector() {
    Column({ space: 8 }) {
      Text('分类 *')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
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
                    .fontSize(24)
                  
                  Text(category.name)
                    .fontSize(12)
                    .fontColor(this.selectedCategory === category.name ? Color.White : '#333333')
                }
              }
              .width('100%')
              .height(72)
              .backgroundColor(this.selectedCategory === category.name ? '#1890FF' : '#F0F0F0')
              .borderRadius(8)
              .onClick(() => {
                this.selectedCategory = category.name;
                this.categoryError = ''; // Clear error on selection
              })
            }
          }, (category: Category) => category.id)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      }
      
      if (this.categoryError) {
        Text(this.categoryError)
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
   * Build mood selector
   */
  @Builder
  buildMoodSelector() {
    Column({ space: 8 }) {
      Text('心情（可选）')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
      
      Row({ space: 12 }) {
        // Satisfied
        Button() {
          Column({ space: 4 }) {
            Text(this.getMoodEmoji(MoodType.SATISFIED))
              .fontSize(32)
            
            Text(this.getMoodLabel(MoodType.SATISFIED))
              .fontSize(12)
              .fontColor(this.selectedMood === MoodType.SATISFIED ? Color.White : '#333333')
          }
        }
        .layoutWeight(1)
        .height(80)
        .backgroundColor(this.selectedMood === MoodType.SATISFIED ? '#52C41A' : '#F0F0F0')
        .borderRadius(8)
        .onClick(() => {
          this.selectedMood = this.selectedMood === MoodType.SATISFIED ? undefined : MoodType.SATISFIED;
        })
        
        // Regret
        Button() {
          Column({ space: 4 }) {
            Text(this.getMoodEmoji(MoodType.REGRET))
              .fontSize(32)
            
            Text(this.getMoodLabel(MoodType.REGRET))
              .fontSize(12)
              .fontColor(this.selectedMood === MoodType.REGRET ? Color.White : '#333333')
          }
        }
        .layoutWeight(1)
        .height(80)
        .backgroundColor(this.selectedMood === MoodType.REGRET ? '#FAAD14' : '#F0F0F0')
        .borderRadius(8)
        .onClick(() => {
          this.selectedMood = this.selectedMood === MoodType.REGRET ? undefined : MoodType.REGRET;
        })
        
        // Surprise
        Button() {
          Column({ space: 4 }) {
            Text(this.getMoodEmoji(MoodType.SURPRISE))
              .fontSize(32)
            
            Text(this.getMoodLabel(MoodType.SURPRISE))
              .fontSize(12)
              .fontColor(this.selectedMood === MoodType.SURPRISE ? Color.White : '#333333')
          }
        }
        .layoutWeight(1)
        .height(80)
        .backgroundColor(this.selectedMood === MoodType.SURPRISE ? '#722ED1' : '#F0F0F0')
        .borderRadius(8)
        .onClick(() => {
          this.selectedMood = this.selectedMood === MoodType.SURPRISE ? undefined : MoodType.SURPRISE;
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
   * Build submit button
   */
  @Builder
  buildSubmitButton() {
    Button(this.isSaving ? '保存中...' : '保存')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor(Color.White)
      .backgroundColor('#1890FF')
      .borderRadius(8)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.handleSubmit();
      })
  }
}
