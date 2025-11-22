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
  @Prop loadingSize?: number;
  @Prop color?: ResourceColor;

  build() {
    Column() {
      LoadingProgress()
        .width(this.loadingSize || 48)
        .height(this.loadingSize || 48)
        .color(this.color || ThemeColors.PRIMARY)

      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: ThemeSpacing.MD })
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
          .color(ThemeColors.PRIMARY)

        if (this.message) {
          Text(this.message)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: ThemeSpacing.MD })
        }
      }
      .padding(ThemeSpacing.XL)
      .backgroundColor(ThemeColors.BG_PRIMARY)
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
  @Prop loadingSize?: number;

  build() {
    Row() {
      LoadingProgress()
        .width(this.loadingSize || 24)
        .height(this.loadingSize || 24)
        .color(ThemeColors.PRIMARY)

      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ left: ThemeSpacing.SM })
      }
    }
    .width('100%')
    .padding(ThemeSpacing.MD)
    .justifyContent(FlexAlign.Center)
  }
}
