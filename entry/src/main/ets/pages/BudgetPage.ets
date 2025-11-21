import { BudgetService } from '../services/BudgetService';
import { CategoryService } from '../services/CategoryService';
import { BudgetRepository, TransactionRepository, CategoryRepository } from '../repositories';
import { DatabaseManager } from '../utils/DatabaseManager';
import { Budget, Category } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { BudgetCard } from '../components/BudgetCard';
import { WarningAlert } from '../components/WarningAlert';
import { BottomNavigation } from '../components/BottomNavigation';
import { ErrorDisplay, Toast } from '../components';
import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeShadow } from '../utils/ThemeConstants';
import router from '@ohos.router';

/**
 * BudgetPage - 预算管理页面
 * 需求：12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.8
 */
@Entry
@Component
struct BudgetPage {
  @State monthlyBudget: Budget | null = null;
  @State weeklyBudget: Budget | null = null;
  @State categoryBudgets: Budget[] = [];
  @State warningBudgets: Budget[] = [];
  @State expenseCategories: Category[] = [];
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State showMonthlyForm: boolean = false;
  @State showWeeklyForm: boolean = false;
  @State showCategoryForm: boolean = false;
  @State monthlyAmount: string = '';
  @State weeklyAmount: string = '';
  @State categoryAmount: string = '';
  @State selectedCategory: string = '';
  @State currentPeriod: string = '';
  @State dismissedWarnings: Set<number> = new Set();
  
  private budgetService: BudgetService | null = null;
  private categoryService: CategoryService | null = null;

  async aboutToAppear() {
    await this.initializeServices();
    await this.loadData();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext(this));
      
      const budgetRepository = new BudgetRepository();
      budgetRepository.setStore(store);
      const transactionRepository = new TransactionRepository();
      transactionRepository.setStore(store);
      const categoryRepository = new CategoryRepository();
      categoryRepository.setStore(store);
      
      this.budgetService = new BudgetService(budgetRepository, transactionRepository);
      this.categoryService = new CategoryService(categoryRepository);
      
      // Set current period
      const now = DateUtils.now();
      const year = DateUtils.getYear(now);
      const month = DateUtils.getMonth(now);
      this.currentPeriod = `${year}-${String(month).padStart(2, '0')}`;
    } catch (error) {
      ErrorHandler.handle(error as Error);
      this.hasError = true;
      this.errorMessage = '初始化失败';
      Toast.error('初始化失败');
    }
  }

  /**
   * Load all budget data
   */
  private async loadData() {
    if (!this.budgetService || !this.categoryService) {
      return;
    }

    this.isLoading = true;
    this.hasError = false;

    try {
      // Load current budgets
      this.monthlyBudget = await this.budgetService.getCurrentMonthlyBudget();
      this.weeklyBudget = await this.budgetService.getCurrentWeeklyBudget();
      this.categoryBudgets = await this.budgetService.getCategoryBudgets(this.currentPeriod);
      
      // Load warning budgets
      this.warningBudgets = await this.budgetService.checkBudgetWarnings();
      
      // Load expense categories
      this.expenseCategories = await this.categoryService.getExpenseCategories();
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
   * Handle monthly budget submission
   * 需求：12.1
   */
  private async handleMonthlyBudgetSubmit() {
    if (!this.budgetService) {
      return;
    }

    const amount = parseFloat(this.monthlyAmount);
    if (isNaN(amount) || amount <= 0) {
      Toast.error('请输入有效的预算金额');
      return;
    }

    try {
      const now = DateUtils.now();
      const year = DateUtils.getYear(now);
      const month = DateUtils.getMonth(now);
      
      await this.budgetService.setMonthlyBudget(year, month, amount);
      
      Toast.success('月度预算设置成功');
      this.showMonthlyForm = false;
      this.monthlyAmount = '';
      await this.loadData();
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('设置失败，请重试');
    }
  }

  /**
   * Handle weekly budget submission
   * 需求：12.2
   */
  private async handleWeeklyBudgetSubmit() {
    if (!this.budgetService) {
      return;
    }

    const amount = parseFloat(this.weeklyAmount);
    if (isNaN(amount) || amount <= 0) {
      Toast.error('请输入有效的预算金额');
      return;
    }

    try {
      const now = DateUtils.now();
      const year = DateUtils.getYear(now);
      const week = DateUtils.getWeekNumber(now);
      
      await this.budgetService.setWeeklyBudget(year, week, amount);
      
      Toast.success('周度预算设置成功');
      this.showWeeklyForm = false;
      this.weeklyAmount = '';
      await this.loadData();
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('设置失败，请重试');
    }
  }

  /**
   * Handle category budget submission
   * 需求：12.3
   */
  private async handleCategoryBudgetSubmit() {
    if (!this.budgetService) {
      return;
    }

    if (!this.selectedCategory) {
      Toast.error('请选择分类');
      return;
    }

    const amount = parseFloat(this.categoryAmount);
    if (isNaN(amount) || amount <= 0) {
      Toast.error('请输入有效的预算金额');
      return;
    }

    try {
      await this.budgetService.setCategoryBudget(this.currentPeriod, this.selectedCategory, amount);
      
      Toast.success('分类预算设置成功');
      this.showCategoryForm = false;
      this.categoryAmount = '';
      this.selectedCategory = '';
      await this.loadData();
    } catch (error) {
      ErrorHandler.handle(error as Error);
      Toast.error('设置失败，请重试');
    }
  }

  /**
   * Navigate back
   */
  private navigateBack() {
    router.back();
  }

  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Content
      if (this.isLoading) {
        this.buildLoadingView();
      } else if (this.hasError) {
        this.buildErrorView();
      } else {
        Scroll() {
          Column() {
            // Warning alerts
            this.buildWarningAlerts();
            
            // Monthly budget section
            this.buildMonthlyBudgetSection();
            
            // Weekly budget section
            this.buildWeeklyBudgetSection();
            
            // Category budgets section
            this.buildCategoryBudgetsSection();
          }
          .width('100%')
          .padding(ThemeSpacing.MD)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      
      // Bottom navigation bar
      BottomNavigation({ currentPage: 'BudgetPage' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_SECONDARY)
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
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.navigateBack();
      })
      
      Text('预算管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ left: ThemeSpacing.SM })
      
      Blank()
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
  }

  /**
   * Build warning alerts
   * 需求：12.5, 12.6
   */
  @Builder
  buildWarningAlerts() {
    if (this.warningBudgets.length > 0) {
      Column() {
        ForEach(this.warningBudgets, (budget: Budget) => {
          if (!this.dismissedWarnings.has(budget.id)) {
            WarningAlert({
              budget: budget,
              onDismiss: () => {
                this.dismissedWarnings.add(budget.id);
              }
            })
              .margin({ bottom: ThemeSpacing.SM })
          }
        }, (budget: Budget) => budget.id.toString())
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })
    }
  }

  /**
   * Build monthly budget section
   * 需求：12.1, 12.4
   */
  @Builder
  buildMonthlyBudgetSection() {
    Column() {
      // Section header
      Row() {
        Text('月度预算')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        
        Blank()
        
        Button(this.monthlyBudget ? '修改' : '设置')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .backgroundColor(ThemeColors.PRIMARY_LIGHTEST)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showMonthlyForm = !this.showMonthlyForm;
            if (this.monthlyBudget) {
              this.monthlyAmount = this.monthlyBudget.amount.toString();
            }
          })
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })

      // Monthly budget card or form
      if (this.showMonthlyForm) {
        this.buildMonthlyBudgetForm();
      } else if (this.monthlyBudget) {
        BudgetCard({ budget: this.monthlyBudget })
      } else {
        this.buildEmptyBudgetCard('还未设置月度预算');
      }
    }
    .width('100%')
    .margin({ bottom: ThemeSpacing.XL })
  }

  /**
   * Build monthly budget form
   */
  @Builder
  buildMonthlyBudgetForm() {
    Column() {
      TextInput({ placeholder: '请输入月度预算金额', text: this.monthlyAmount })
        .type(InputType.Number)
        .fontSize(16)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(ThemeBorderRadius.INPUT)
        .onChange((value: string) => {
          this.monthlyAmount = value;
        })
        .margin({ bottom: ThemeSpacing.SM })
      
      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.showMonthlyForm = false;
            this.monthlyAmount = '';
          })
        
        Button('确定')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(ThemeColors.PRIMARY)
          .height(40)
          .layoutWeight(1)
          .margin({ left: ThemeSpacing.SM })
          .onClick(() => {
            this.handleMonthlyBudgetSubmit();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
  }

  /**
   * Build weekly budget section
   * 需求：12.2, 12.4
   */
  @Builder
  buildWeeklyBudgetSection() {
    Column() {
      // Section header
      Row() {
        Text('周度预算')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        
        Blank()
        
        Button(this.weeklyBudget ? '修改' : '设置')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .backgroundColor(ThemeColors.PRIMARY_LIGHTEST)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showWeeklyForm = !this.showWeeklyForm;
            if (this.weeklyBudget) {
              this.weeklyAmount = this.weeklyBudget.amount.toString();
            }
          })
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })

      // Weekly budget card or form
      if (this.showWeeklyForm) {
        this.buildWeeklyBudgetForm();
      } else if (this.weeklyBudget) {
        BudgetCard({ budget: this.weeklyBudget })
      } else {
        this.buildEmptyBudgetCard('还未设置周度预算');
      }
    }
    .width('100%')
    .margin({ bottom: ThemeSpacing.XL })
  }

  /**
   * Build weekly budget form
   */
  @Builder
  buildWeeklyBudgetForm() {
    Column() {
      TextInput({ placeholder: '请输入周度预算金额', text: this.weeklyAmount })
        .type(InputType.Number)
        .fontSize(16)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(ThemeBorderRadius.INPUT)
        .onChange((value: string) => {
          this.weeklyAmount = value;
        })
        .margin({ bottom: ThemeSpacing.SM })
      
      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.showWeeklyForm = false;
            this.weeklyAmount = '';
          })
        
        Button('确定')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(ThemeColors.PRIMARY)
          .height(40)
          .layoutWeight(1)
          .margin({ left: ThemeSpacing.SM })
          .onClick(() => {
            this.handleWeeklyBudgetSubmit();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
  }

  /**
   * Build category budgets section
   * 需求：12.3, 12.8
   */
  @Builder
  buildCategoryBudgetsSection() {
    Column() {
      // Section header
      Row() {
        Text('分类预算')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        
        Blank()
        
        Button('添加')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .backgroundColor(ThemeColors.PRIMARY_LIGHTEST)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showCategoryForm = !this.showCategoryForm;
          })
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })

      // Category budget form
      if (this.showCategoryForm) {
        this.buildCategoryBudgetForm();
      }

      // Category budget list
      if (this.categoryBudgets.length > 0) {
        ForEach(this.categoryBudgets, (budget: Budget) => {
          BudgetCard({ budget: budget })
            .margin({ bottom: ThemeSpacing.SM })
        }, (budget: Budget) => budget.id.toString())
      } else if (!this.showCategoryForm) {
        this.buildEmptyBudgetCard('还未设置分类预算');
      }
    }
    .width('100%')
  }

  /**
   * Build category budget form
   */
  @Builder
  buildCategoryBudgetForm() {
    Column() {
      // Category selector
      Column() {
        Text('选择分类')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: ThemeSpacing.XS })
        
        Scroll() {
          Row() {
            ForEach(this.expenseCategories, (category: Category) => {
              Text(category.name)
                .fontSize(14)
                .fontColor(this.selectedCategory === category.name ? Color.White : ThemeColors.TEXT_PRIMARY)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedCategory === category.name ? ThemeColors.PRIMARY : ThemeColors.BG_TERTIARY)
                .borderRadius(ThemeBorderRadius.TAG)
                .margin({ right: ThemeSpacing.XS })
                .onClick(() => {
                  this.selectedCategory = category.name;
                })
            }, (category: Category) => category.id.toString())
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })
      
      // Amount input
      TextInput({ placeholder: '请输入预算金额', text: this.categoryAmount })
        .type(InputType.Number)
        .fontSize(16)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(ThemeBorderRadius.INPUT)
        .onChange((value: string) => {
          this.categoryAmount = value;
        })
        .margin({ bottom: ThemeSpacing.SM })
      
      // Action buttons
      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.showCategoryForm = false;
            this.categoryAmount = '';
            this.selectedCategory = '';
          })
        
        Button('确定')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(ThemeColors.PRIMARY)
          .height(40)
          .layoutWeight(1)
          .margin({ left: ThemeSpacing.SM })
          .onClick(() => {
            this.handleCategoryBudgetSubmit();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.SM })
  }

  /**
   * Build empty budget card
   */
  @Builder
  buildEmptyBudgetCard(message: string) {
    Column() {
      Text('📊')
        .fontSize(48)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text(message)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(ThemeSpacing.XXL)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
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
        .color(ThemeColors.PRIMARY)
      
      Text('加载中...')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: ThemeSpacing.SM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build error view
   */
  @Builder
  buildErrorView() {
    ErrorDisplay({
      message: this.errorMessage,
      description: '请检查网络连接或稍后重试',
      showRetry: true,
      onRetry: () => {
        this.loadData();
      }
    })
  }
}
