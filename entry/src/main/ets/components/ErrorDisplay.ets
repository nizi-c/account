/**
 * Error Display Components
 * 错误显示组件
 * 
 * 提供统一的错误状态显示和重试功能
 */

import { ThemeColors, ThemeSpacing, ThemeBorderRadius } from '../utils/ThemeConstants';
import { ButtonStyles } from '../utils/ButtonStyles';

/**
 * 错误显示组件
 */
@Component
export struct ErrorDisplay {
  @Prop message: string = '加载失败';
  @Prop description?: string;
  @Prop showRetry?: boolean = true;
  onRetry?: () => void;

  build() {
    Column() {
      // 错误图标
      Text('⚠️')
        .fontSize(48)
        .margin({ bottom: ThemeSpacing.md })

      // 错误消息
      Text(this.message)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .textAlign(TextAlign.Center)

      // 错误描述
      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .textAlign(TextAlign.Center)
          .margin({ top: ThemeSpacing.sm })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      // 重试按钮
      if (this.showRetry && this.onRetry) {
        Button('重试')
          .fontSize(14)
          .fontColor(ThemeColors.onPrimary)
          .backgroundColor(ThemeColors.primary)
          .borderRadius(ThemeBorderRadius.full)
          .padding({ left: ThemeSpacing.xl, right: ThemeSpacing.xl, top: ThemeSpacing.sm, bottom: ThemeSpacing.sm })
          .margin({ top: ThemeSpacing.lg })
          .onClick(() => {
            if (this.onRetry) {
              this.onRetry();
            }
          })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.xl)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 空状态显示组件
 */
@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';
  @Prop description?: string;
  @Prop icon?: string = '📭';
  @Prop actionText?: string;
  onAction?: () => void;

  build() {
    Column() {
      // 图标
      Text(this.icon)
        .fontSize(64)
        .margin({ bottom: ThemeSpacing.md })

      // 消息
      Text(this.message)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .textAlign(TextAlign.Center)

      // 描述
      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .textAlign(TextAlign.Center)
          .margin({ top: ThemeSpacing.sm })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      // 操作按钮
      if (this.actionText && this.onAction) {
        Button(this.actionText)
          .fontSize(14)
          .fontColor(ThemeColors.onPrimary)
          .backgroundColor(ThemeColors.primary)
          .borderRadius(ThemeBorderRadius.full)
          .padding({ left: ThemeSpacing.xl, right: ThemeSpacing.xl, top: ThemeSpacing.sm, bottom: ThemeSpacing.sm })
          .margin({ top: ThemeSpacing.lg })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.xl)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 内联错误提示组件
 */
@Component
export struct InlineError {
  @Prop message: string;
  @Prop showIcon?: boolean = true;

  build() {
    Row() {
      if (this.showIcon) {
        Text('⚠️')
          .fontSize(16)
          .margin({ right: ThemeSpacing.xs })
      }

      Text(this.message)
        .fontSize(14)
        .fontColor(ThemeColors.error)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(ThemeSpacing.sm)
    .backgroundColor(ThemeColors.errorContainer)
    .borderRadius(ThemeBorderRadius.sm)
  }
}

/**
 * 错误页面组件
 */
@Component
export struct ErrorPage {
  @Prop title: string = '出错了';
  @Prop message: string = '页面加载失败';
  @Prop errorCode?: string;
  @Prop showRetry?: boolean = true;
  @Prop showBack?: boolean = true;
  onRetry?: () => void;
  onBack?: () => void;

  build() {
    Column() {
      // 错误图标
      Text('😕')
        .fontSize(80)
        .margin({ bottom: ThemeSpacing.lg })

      // 标题
      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .textAlign(TextAlign.Center)
        .margin({ bottom: ThemeSpacing.sm })

      // 错误消息
      Text(this.message)
        .fontSize(16)
        .fontColor(ThemeColors.textSecondary)
        .textAlign(TextAlign.Center)
        .margin({ bottom: ThemeSpacing.md })
        .maxLines(5)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 错误代码
      if (this.errorCode) {
        Text(`错误代码: ${this.errorCode}`)
          .fontSize(12)
          .fontColor(ThemeColors.textTertiary)
          .textAlign(TextAlign.Center)
          .margin({ bottom: ThemeSpacing.lg })
      }

      // 操作按钮
      Row() {
        if (this.showBack && this.onBack) {
          Button('返回')
            .fontSize(14)
            .fontColor(ThemeColors.primary)
            .backgroundColor(ThemeColors.surface)
            .borderRadius(ThemeBorderRadius.full)
            .border({ width: 1, color: ThemeColors.outline })
            .padding({ left: ThemeSpacing.xl, right: ThemeSpacing.xl, top: ThemeSpacing.sm, bottom: ThemeSpacing.sm })
            .margin({ right: ThemeSpacing.md })
            .onClick(() => {
              if (this.onBack) {
                this.onBack();
              }
            })
        }

        if (this.showRetry && this.onRetry) {
          Button('重试')
            .fontSize(14)
            .fontColor(ThemeColors.onPrimary)
            .backgroundColor(ThemeColors.primary)
            .borderRadius(ThemeBorderRadius.full)
            .padding({ left: ThemeSpacing.xl, right: ThemeSpacing.xl, top: ThemeSpacing.sm, bottom: ThemeSpacing.sm })
            .onClick(() => {
              if (this.onRetry) {
                this.onRetry();
              }
            })
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(ThemeSpacing.xl)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(ThemeColors.background)
  }
}
