import { Budget, BudgetStatus } from '../models';
import { FormatUtils } from '../utils/FormatUtils';
import { ThemeColors, ThemeSpacing, ThemeBorderRadius } from '../utils/ThemeConstants';

/**
 * WarningAlert Component
 * 预警提示组件
 * 需求：12.5, 12.6 - 预警提醒和超支警告
 */
@Component
export struct WarningAlert {
  @Prop budget: Budget;
  @Prop onDismiss?: () => void;

  /**
   * Get alert icon
   */
  private getIcon(): string {
    switch (this.budget.status) {
      case BudgetStatus.WARNING:
        return '⚠️';
      case BudgetStatus.EXCEEDED:
        return '🚨';
      default:
        return 'ℹ️';
    }
  }

  /**
   * Get alert title
   */
  private getTitle(): string {
    switch (this.budget.status) {
      case BudgetStatus.WARNING:
        return '预算预警';
      case BudgetStatus.EXCEEDED:
        return '预算超支';
      default:
        return '提示';
    }
  }

  /**
   * Get alert message
   */
  private getMessage(): string {
    const budgetName = this.getBudgetName();
    
    if (this.budget.status === BudgetStatus.WARNING) {
      return `${budgetName}已使用 ${this.budget.percentage.toFixed(1)}%，接近预算上限`;
    } else if (this.budget.status === BudgetStatus.EXCEEDED) {
      const exceeded = this.budget.spent - this.budget.amount;
      return `${budgetName}已超支 ${FormatUtils.formatCurrency(exceeded)}`;
    }
    return '';
  }

  /**
   * Get budget name for display
   */
  private getBudgetName(): string {
    if (this.budget.category) {
      return `${this.budget.category}分类预算`;
    }
    
    if (this.budget.period.includes('W')) {
      return '周度预算';
    }
    
    return '月度预算';
  }

  /**
   * Get alert background color
   */
  private getBackgroundColor(): string {
    switch (this.budget.status) {
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING_LIGHTEST;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR_LIGHTEST;
      default:
        return ThemeColors.INFO_LIGHTEST;
    }
  }

  /**
   * Get alert border color
   */
  private getBorderColor(): string {
    switch (this.budget.status) {
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR;
      default:
        return ThemeColors.INFO;
    }
  }

  /**
   * Get title color
   */
  private getTitleColor(): string {
    switch (this.budget.status) {
      case BudgetStatus.WARNING:
        return ThemeColors.WARNING;
      case BudgetStatus.EXCEEDED:
        return ThemeColors.ERROR;
      default:
        return ThemeColors.INFO;
    }
  }

  build() {
    Row() {
      // Icon
      Text(this.getIcon())
        .fontSize(24)
        .margin({ right: ThemeSpacing.SM })
      
      // Content
      Column() {
        Text(this.getTitle())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTitleColor())
          .margin({ bottom: 4 })
        
        Text(this.getMessage())
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // Dismiss button
      if (this.onDismiss) {
        Button({ type: ButtonType.Circle }) {
          Text('×')
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.onDismiss) {
            this.onDismiss();
          }
        })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(ThemeBorderRadius.MD)
    .border({
      width: 1,
      color: this.getBorderColor()
    })
  }
}
