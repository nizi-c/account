import { Budget, BudgetStatus } from '../models';
import { FormatUtils } from '../utils/FormatUtils';
import { ThemeColors, ThemeSpacing, ThemeBorderRadius } from '../utils/ThemeConstants';

/**
 * BudgetProgressBar Component
 * 预算进度条组件
 * 需求：12.4 - 实时预算进度显示
 */
@Component
export struct BudgetProgressBar {
  @Prop budget: Budget;
  @Prop showDetails: boolean = true;

  /**
   * Get progress bar color based on budget status
   */
  private getProgressColor(): string {
    switch (this.budget.status) {
      case BudgetStatus.NORMAL:
        return ThemeColors.SUCCESS;
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR;
      default:
        return ThemeColors.PRIMARY;
    }
  }

  /**
   * Get background color based on budget status
   */
  private getBackgroundColor(): string {
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

  build() {
    Column() {
      // Progress details
      if (this.showDetails) {
        Row() {
          Text(`已用 ${FormatUtils.formatCurrency(this.budget.spent)}`)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          
          Blank()
          
          Text(`剩余 ${FormatUtils.formatCurrency(this.budget.remaining)}`)
            .fontSize(14)
            .fontColor(this.budget.remaining >= 0 ? ThemeColors.SUCCESS : ThemeColors.ERROR)
        }
        .width('100%')
        .margin({ bottom: ThemeSpacing.XS })
      }

      // Progress bar
      Stack({ alignContent: Alignment.Start }) {
        // Background
        Row()
          .width('100%')
          .height(8)
          .backgroundColor(this.getBackgroundColor())
          .borderRadius(ThemeBorderRadius.SM)
        
        // Progress fill
        Row()
          .width(`${Math.min(this.budget.percentage, 100)}%`)
          .height(8)
          .backgroundColor(this.getProgressColor())
          .borderRadius(ThemeBorderRadius.SM)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }
      .width('100%')
      .height(8)

      // Percentage text
      if (this.showDetails) {
        Row() {
          Text(`${this.budget.percentage.toFixed(1)}%`)
            .fontSize(12)
            .fontColor(this.getProgressColor())
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(`预算 ${FormatUtils.formatCurrency(this.budget.amount)}`)
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .width('100%')
        .margin({ top: ThemeSpacing.XS })
      }
    }
    .width('100%')
  }
}
