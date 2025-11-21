/**
 * Loading Indicator Component
 * 加载指示器组件
 * 
 * 提供统一的加载状态显示
 */

import { ThemeColors, ThemeSpacing } from '../utils/ThemeConstants';

/**
 * 加载指示器组件
 */
@Component
export struct LoadingIndicator {
  @Prop message?: string;
  @Prop size?: number;
  @Prop color?: ResourceColor;

  build() {
    Column() {
      LoadingProgress()
        .width(this.size || 48)
        .height(this.size || 48)
        .color(this.color || ThemeColors.primary)

      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .margin({ top: ThemeSpacing.md })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 全屏加载指示器
 */
@Component
export struct FullScreenLoading {
  @Prop message?: string;

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')

      // 加载内容
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color(ThemeColors.primary)

        if (this.message) {
          Text(this.message)
            .fontSize(14)
            .fontColor(ThemeColors.textPrimary)
            .margin({ top: ThemeSpacing.md })
        }
      }
      .padding(ThemeSpacing.xl)
      .backgroundColor(ThemeColors.surface)
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 内联加载指示器（用于列表等）
 */
@Component
export struct InlineLoading {
  @Prop message?: string;
  @Prop size?: number;

  build() {
    Row() {
      LoadingProgress()
        .width(this.size || 24)
        .height(this.size || 24)
        .color(ThemeColors.primary)

      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .margin({ left: ThemeSpacing.sm })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.md)
    .justifyContent(FlexAlign.Center)
  }
}
