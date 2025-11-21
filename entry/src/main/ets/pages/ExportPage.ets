import { ExportService } from '../services/ExportService';
import { TransactionRepository, CategoryRepository, AchievementRepository, BudgetRepository } from '../repositories';
import { DatabaseManager } from '../utils/DatabaseManager';
import { DateUtils } from '../utils/DateUtils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { Toast } from '../components';
import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeShadow } from '../utils/ThemeConstants';
import router from '@ohos.router';
import { common } from '@kit.AbilityKit';

/**
 * ExportPage - 数据导出页面
 * 需求：13.1, 13.4, 13.5, 13.7
 */
@Entry
@Component
struct ExportPage {
  @State selectedFormat: 'csv' | 'json' = 'csv';
  @State useDateRange: boolean = false;
  @State startDate: number = (() => {
    const now = DateUtils.now();
    return DateUtils.getStartOfMonth(DateUtils.getYear(now), DateUtils.getMonth(now));
  })();
  @State endDate: number = DateUtils.now();
  @State isExporting: boolean = false;
  @State exportProgress: number = 0;
  @State exportSuccess: boolean = false;
  @State exportFilePath: string = '';
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State showDatePicker: boolean = false;
  @State datePickerType: 'start' | 'end' = 'start';
  
  private exportService: ExportService | null = null;

  async aboutToAppear() {
    await this.initializeServices();
  }

  /**
   * Initialize services
   */
  private async initializeServices() {
    try {
      const dbManager = DatabaseManager.getInstance();
      const store = await dbManager.initialize(getContext(this));
      const context = getContext(this) as common.UIAbilityContext;
      
      const transactionRepository = new TransactionRepository();
      transactionRepository.setStore(store);
      const categoryRepository = new CategoryRepository();
      categoryRepository.setStore(store);
      const achievementRepository = new AchievementRepository();
      achievementRepository.setStore(store);
      const budgetRepository = new BudgetRepository();
      budgetRepository.setStore(store);
      
      this.exportService = new ExportService(
        transactionRepository,
        categoryRepository,
        achievementRepository,
        budgetRepository,
        context
      );
    } catch (error) {
      ErrorHandler.handle(error as Error);
      this.hasError = true;
      this.errorMessage = '初始化失败';
      Toast.error('初始化失败');
    }
  }

  /**
   * Handle export button click
   * 需求：13.1, 13.4, 13.5
   */
  private async handleExport() {
    if (!this.exportService) {
      Toast.error('服务未初始化');
      return;
    }

    this.isExporting = true;
    this.exportProgress = 0;
    this.exportSuccess = false;
    this.hasError = false;
    this.errorMessage = '';

    try {
      // Simulate progress
      this.exportProgress = 20;

      // Prepare date range parameters
      const startDate = this.useDateRange ? this.startDate : undefined;
      const endDate = this.useDateRange ? this.endDate : undefined;

      // Export data based on format
      let content: string;
      let filename: string;

      this.exportProgress = 40;

      if (this.selectedFormat === 'csv') {
        // Export to CSV
        content = await this.exportService.exportToCSV(startDate, endDate);
        filename = `expense_tracker_${DateUtils.formatDateTime(DateUtils.now(), 'YYYYMMDD_HHmmss')}.csv`;
      } else {
        // Export to JSON
        const exportData = await this.exportService.exportToJSON(startDate, endDate);
        content = JSON.stringify(exportData, null, 2);
        filename = `expense_tracker_${DateUtils.formatDateTime(DateUtils.now(), 'YYYYMMDD_HHmmss')}.json`;
      }

      this.exportProgress = 70;

      // Save file
      const filePath = await this.exportService.saveExportFile(content, filename, this.selectedFormat);

      this.exportProgress = 100;
      this.exportSuccess = true;
      this.exportFilePath = filePath;

      Toast.success('导出成功');
    } catch (error) {
      ErrorHandler.handle(error as Error);
      this.hasError = true;
      this.errorMessage = error.message || '导出失败';
      Toast.error(this.errorMessage);
    } finally {
      this.isExporting = false;
    }
  }

  /**
   * Handle retry after export failure
   * 需求：13.7
   */
  private handleRetry() {
    this.hasError = false;
    this.errorMessage = '';
    this.exportSuccess = false;
    this.exportFilePath = '';
    this.handleExport();
  }

  /**
   * Navigate back
   */
  private navigateBack() {
    router.back();
  }

  /**
   * Open date picker
   */
  private openDatePicker(type: 'start' | 'end') {
    this.datePickerType = type;
    this.showDatePicker = true;
  }

  build() {
    Column() {
      // Header
      this.buildHeader();
      
      // Content
      Scroll() {
        Column() {
          // Format selection section
          this.buildFormatSection();
          
          // Date range section
          this.buildDateRangeSection();
          
          // Export button
          this.buildExportButton();
          
          // Export progress indicator
          if (this.isExporting) {
            this.buildProgressIndicator();
          }
          
          // Export success message
          if (this.exportSuccess) {
            this.buildSuccessMessage();
          }
          
          // Export error message
          if (this.hasError) {
            this.buildErrorMessage();
          }
        }
        .width('100%')
        .padding(ThemeSpacing.MD)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
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
      
      Text('数据导出')
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
   * Build format selection section
   * 需求：13.1
   */
  @Builder
  buildFormatSection() {
    Column() {
      Text('导出格式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: ThemeSpacing.SM })
      
      Row() {
        // CSV option
        Row() {
          Radio({ value: 'csv', group: 'format' })
            .checked(this.selectedFormat === 'csv')
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.selectedFormat = 'csv';
              }
            })
          
          Column() {
            Text('CSV格式')
              .fontSize(15)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
            
            Text('适合在Excel中打开')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: ThemeSpacing.XS })
        }
        .layoutWeight(1)
        .padding(ThemeSpacing.MD)
        .backgroundColor(this.selectedFormat === 'csv' ? ThemeColors.PRIMARY_LIGHTEST : Color.White)
        .borderRadius(ThemeBorderRadius.CARD)
        .border({
          width: 2,
          color: this.selectedFormat === 'csv' ? ThemeColors.PRIMARY : ThemeColors.BORDER_PRIMARY
        })
        .onClick(() => {
          this.selectedFormat = 'csv';
        })
        
        // JSON option
        Row() {
          Radio({ value: 'json', group: 'format' })
            .checked(this.selectedFormat === 'json')
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.selectedFormat = 'json';
              }
            })
          
          Column() {
            Text('JSON格式')
              .fontSize(15)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
            
            Text('包含完整数据结构')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: ThemeSpacing.XS })
        }
        .layoutWeight(1)
        .padding(ThemeSpacing.MD)
        .backgroundColor(this.selectedFormat === 'json' ? ThemeColors.PRIMARY_LIGHTEST : Color.White)
        .borderRadius(ThemeBorderRadius.CARD)
        .border({
          width: 2,
          color: this.selectedFormat === 'json' ? ThemeColors.PRIMARY : ThemeColors.BORDER_PRIMARY
        })
        .margin({ left: ThemeSpacing.SM })
        .onClick(() => {
          this.selectedFormat = 'json';
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.MD })
  }

  /**
   * Build date range section
   * 需求：13.5
   */
  @Builder
  buildDateRangeSection() {
    Column() {
      Row() {
        Text('日期范围')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        
        Blank()
        
        Toggle({ type: ToggleType.Switch, isOn: this.useDateRange })
          .onChange((isOn: boolean) => {
            this.useDateRange = isOn;
          })
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.SM })
      
      if (this.useDateRange) {
        Column() {
          // Start date
          Row() {
            Text('开始日期')
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .layoutWeight(1)
            
            Text(DateUtils.formatDate(this.startDate, 'YYYY-MM-DD'))
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
            
            Text('>')
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ left: ThemeSpacing.XS })
          }
          .width('100%')
          .padding(ThemeSpacing.MD)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .borderRadius(ThemeBorderRadius.INPUT)
          .onClick(() => {
            this.openDatePicker('start');
          })
          .margin({ bottom: ThemeSpacing.SM })
          
          // End date
          Row() {
            Text('结束日期')
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .layoutWeight(1)
            
            Text(DateUtils.formatDate(this.endDate, 'YYYY-MM-DD'))
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
            
            Text('>')
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ left: ThemeSpacing.XS })
          }
          .width('100%')
          .padding(ThemeSpacing.MD)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .borderRadius(ThemeBorderRadius.INPUT)
          .onClick(() => {
            this.openDatePicker('end');
          })
          
          Text('仅导出指定日期范围内的交易记录')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: ThemeSpacing.SM })
        }
        .width('100%')
      } else {
        Text('导出所有交易记录')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.MD })
  }

  /**
   * Build export button
   * 需求：13.4
   */
  @Builder
  buildExportButton() {
    Button('开始导出')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .backgroundColor(this.isExporting ? ThemeColors.TEXT_TERTIARY : ThemeColors.PRIMARY)
      .borderRadius(ThemeBorderRadius.BUTTON)
      .enabled(!this.isExporting)
      .onClick(() => {
        this.handleExport();
      })
      .margin({ bottom: ThemeSpacing.MD })
  }

  /**
   * Build progress indicator
   * 需求：13.4
   */
  @Builder
  buildProgressIndicator() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.PRIMARY)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text('正在导出...')
        .fontSize(16)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: ThemeSpacing.XS })
      
      Progress({ value: this.exportProgress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(8)
        .color(ThemeColors.PRIMARY)
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(4)
        .margin({ bottom: ThemeSpacing.XS })
      
      Text(`${this.exportProgress}%`)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .width('100%')
    .padding(ThemeSpacing.XL)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.MD })
  }

  /**
   * Build success message
   * 需求：13.4
   */
  @Builder
  buildSuccessMessage() {
    Column() {
      Text('✅')
        .fontSize(48)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text('导出成功')
        .fontSize(18)
        .fontColor(ThemeColors.SUCCESS)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text('文件已保存至：')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ bottom: ThemeSpacing.XS })
      
      Text(this.exportFilePath)
        .fontSize(12)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ left: ThemeSpacing.SM, right: ThemeSpacing.SM })
    }
    .width('100%')
    .padding(ThemeSpacing.XL)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.MD })
  }

  /**
   * Build error message
   * 需求：13.7
   */
  @Builder
  buildErrorMessage() {
    Column() {
      Text('❌')
        .fontSize(48)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text('导出失败')
        .fontSize(18)
        .fontColor(ThemeColors.ERROR)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: ThemeSpacing.SM })
      
      Text(this.errorMessage)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .margin({ bottom: ThemeSpacing.MD })
      
      Button('重试')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor(Color.White)
        .backgroundColor(ThemeColors.PRIMARY)
        .borderRadius(ThemeBorderRadius.BUTTON)
        .onClick(() => {
          this.handleRetry();
        })
    }
    .width('100%')
    .padding(ThemeSpacing.XL)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
    .margin({ bottom: ThemeSpacing.MD })
  }
}
