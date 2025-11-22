import { Budget, BudgetType, BudgetStatus } from '../models';
import { FormatUtils } from '../utils/FormatUtils';
import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeShadow } from '../utils/ThemeConstants';
import { BudgetProgressBar } from './BudgetProgressBar';

/**
 * BudgetCard Component
 * 预算卡片组件
 * 需求：12.4, 12.5, 12.6 - 显示预算进度、预警和超支
 */
@Component
export struct BudgetCard {
  @Prop budget: Budget;
  @Prop onEdit?: (budget: Budget) => void;
  @Prop onDelete?: (budget: Budget) => void;

  /**
   * Get budget type display name
   */
  private getBudgetTypeLabel(): string {
    switch (this.budget.type) {
      case BudgetType.MONTHLY:
        return '月度预算';
      case BudgetType.WEEKLY:
        return '周度预算';
      case BudgetType.CATEGORY:
        return `${this.budget.category || '分类'}预算`;
      default:
        return '预算';
    }
  }

  /**
   * Get budget period display
   */
  private getPeriodLabel(): string {
    if (this.budget.type === BudgetType.MONTHLY) {
      // Format: 2024-01 -> 2024年1月
      const parts = this.budget.period.split('-');
      const year = parts[0];
      const month = parts[1];
      return `${year}年${parseInt(month)}月`;
    } else if (this.budget.type === BudgetType.WEEKLY) {
      // Format: 2024-W01 -> 2024年第1周
      const match = this.budget.period.match(/(\d{4})-W(\d{2})/);
      if (match) {
        return `${match[1]}年第${parseInt(match[2])}周`;
      }
    }
    return this.budget.period;
  }

  /**
   * Get status badge color
   */
  private getStatusColor(): string {
    switch (this.budget.status) {
      case BudgetStatus.NORMAL:
        return ThemeColors.SUCCESS;
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR;
      default:
        return ThemeColors.TEXT_TERTIARY;
    }
  }

  /**
   * Get status badge background
   */
  private getStatusBackground(): string {
    switch (this.budget.status) {
      case BudgetStatus.NORMAL:
        return ThemeColors.SUCCESS_LIGHTEST;
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING_LIGHTEST;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR_LIGHTEST;
      default:
        return ThemeColors.BG_TERTIARY;
    }
  }

  /**
   * Get status label
   */
  private getStatusLabel(): string {
    switch (this.budget.status) {
      case BudgetStatus.NORMAL:
        return '正常';
      case BudgetStatus.WARNING:
        return '预警';
      case BudgetStatus.EXCEEDED:
        return '超支';
      default:
        return '';
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Column() {
          Text(this.getBudgetTypeLabel())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          
          Text(this.getPeriodLabel())
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        // Status badge
        Text(this.getStatusLabel())
          .fontSize(12)
          .fontColor(this.getStatusColor())
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getStatusBackground())
          .borderRadius(ThemeBorderRadius.SM)
      }
      .width('100%')
      .margin({ bottom: ThemeSpacing.MD })

      // Progress bar
      BudgetProgressBar({ budget: this.budget, showDetails: true })

      // Action buttons (if provided)
      if (this.onEdit || this.onDelete) {
        Row() {
          if (this.onEdit) {
            Button('编辑')
              .fontSize(14)
              .fontColor(ThemeColors.PRIMARY)
              .backgroundColor(ThemeColors.PRIMARY_LIGHTEST)
              .height(32)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                if (this.onEdit) {
                  this.onEdit(this.budget);
                }
              })
          }
          
          if (this.onDelete) {
            Button('删除')
              .fontSize(14)
              .fontColor(ThemeColors.ERROR)
              .backgroundColor(ThemeColors.ERROR_LIGHTEST)
              .height(32)
              .padding({ left: 16, right: 16 })
              .margin({ left: ThemeSpacing.SM })
              .onClick(() => {
                if (this.onDelete) {
                  this.onDelete(this.budget);
                }
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: ThemeSpacing.MD })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(Color.White)
    .borderRadius(ThemeBorderRadius.CARD)
    .shadow(ThemeShadow.SM)
  }
}
