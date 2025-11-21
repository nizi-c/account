/**
 * ThemeShowcase - 主题展示组件
 * 展示如何使用主题系统的各种样式
 * 仅用于开发参考，不在生产环境中使用
 */

import {
  ThemeColors,
  ThemeTypography,
  ThemeSpacing,
  ThemeBorderRadius,
  ButtonStyles,
  ButtonStyleType,
  ButtonSize,
  CardStyles,
  CardType,
  InputStyles,
  InputSize,
  TextStyles,
  FeedbackStyles,
  BadgeStyles,
  TagStyles
} from '../utils';

/**
 * 主题展示组件
 * 展示所有可用的样式和组件
 */
@Component
export struct ThemeShowcase {
  @State selectedTab: number = 0;

  build() {
    Column() {
      // Tab 切换
      Row() {
        this.buildTab('颜色', 0);
        this.buildTab('按钮', 1);
        this.buildTab('卡片', 2);
        this.buildTab('输入框', 3);
        this.buildTab('文本', 4);
      }
      .width('100%')
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .padding(ThemeSpacing.SM)

      // 内容区域
      Scroll() {
        Column() {
          if (this.selectedTab === 0) {
            this.buildColorSection();
          } else if (this.selectedTab === 1) {
            this.buildButtonSection();
          } else if (this.selectedTab === 2) {
            this.buildCardSection();
          } else if (this.selectedTab === 3) {
            this.buildInputSection();
          } else if (this.selectedTab === 4) {
            this.buildTextSection();
          }
        }
        .width('100%')
        .padding(ThemeSpacing.MD)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_TERTIARY)
  }

  @Builder
  buildTab(label: string, index: number) {
    Text(label)
      .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
      .fontColor(this.selectedTab === index ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
      .padding({ left: ThemeSpacing.SM, right: ThemeSpacing.SM, top: ThemeSpacing.XS, bottom: ThemeSpacing.XS })
      .backgroundColor(this.selectedTab === index ? ThemeColors.PRIMARY_LIGHTEST : Color.Transparent)
      .borderRadius(ThemeBorderRadius.SM)
      .onClick(() => {
        this.selectedTab = index;
      })
  }

  @Builder
  buildColorSection() {
    Column({ space: ThemeSpacing.MD }) {
      Text('颜色方案')
        .fontSize(ThemeTypography.FONT_SIZE_LARGE)
        .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 主色调
      this.buildColorGroup('主色调', [
        { name: '主色', color: ThemeColors.PRIMARY },
        { name: '主色浅', color: ThemeColors.PRIMARY_LIGHT },
        { name: '主色深', color: ThemeColors.PRIMARY_DARK }
      ]);

      // 语义颜色
      this.buildColorGroup('语义颜色', [
        { name: '成功', color: ThemeColors.SUCCESS },
        { name: '错误', color: ThemeColors.ERROR },
        { name: '警告', color: ThemeColors.WARNING }
      ]);

      // 文本颜色
      this.buildColorGroup('文本颜色', [
        { name: '主要', color: ThemeColors.TEXT_PRIMARY },
        { name: '次要', color: ThemeColors.TEXT_SECONDARY },
        { name: '三级', color: ThemeColors.TEXT_TERTIARY }
      ]);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildColorGroup(title: string, colors: Array<{ name: string, color: string }>) {
    Column({ space: ThemeSpacing.XS }) {
      Text(title)
        .fontSize(ThemeTypography.FONT_SIZE_BODY)
        .fontWeight(ThemeTypography.FONT_WEIGHT_MEDIUM)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      Row({ space: ThemeSpacing.SM }) {
        ForEach(colors, (item: { name: string, color: string }) => {
          Column() {
            Row()
              .width(60)
              .height(60)
              .backgroundColor(item.color)
              .borderRadius(ThemeBorderRadius.MD)

            Text(item.name)
              .fontSize(ThemeTypography.FONT_SIZE_CAPTION)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ top: ThemeSpacing.XXS })
          }
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildButtonSection() {
    Column({ space: ThemeSpacing.MD }) {
      Text('按钮样式')
        .fontSize(ThemeTypography.FONT_SIZE_LARGE)
        .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 主要按钮
      this.buildButtonExample('主要按钮', ButtonStyleType.PRIMARY);

      // 次要按钮
      this.buildButtonExample('次要按钮', ButtonStyleType.SECONDARY);

      // 危险按钮
      this.buildButtonExample('危险按钮', ButtonStyleType.DANGER);

      // 成功按钮
      this.buildButtonExample('成功按钮', ButtonStyleType.SUCCESS);

      // 文本按钮
      this.buildButtonExample('文本按钮', ButtonStyleType.TEXT);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildButtonExample(label: string, type: ButtonStyleType) {
    Column({ space: ThemeSpacing.XS }) {
      Text(label)
        .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      Row({ space: ThemeSpacing.SM }) {
        // Small
        Button('小')
          .height(ButtonStyles.getButtonStyle(type, ButtonSize.SMALL).height)
          .backgroundColor(ButtonStyles.getButtonStyle(type, ButtonSize.SMALL).backgroundColor)
          .fontColor(ButtonStyles.getButtonStyle(type, ButtonSize.SMALL).fontColor)
          .fontSize(ButtonStyles.getButtonStyle(type, ButtonSize.SMALL).fontSize)
          .borderRadius(ButtonStyles.getButtonStyle(type, ButtonSize.SMALL).borderRadius)

        // Medium
        Button('中')
          .height(ButtonStyles.getButtonStyle(type, ButtonSize.MEDIUM).height)
          .backgroundColor(ButtonStyles.getButtonStyle(type, ButtonSize.MEDIUM).backgroundColor)
          .fontColor(ButtonStyles.getButtonStyle(type, ButtonSize.MEDIUM).fontColor)
          .fontSize(ButtonStyles.getButtonStyle(type, ButtonSize.MEDIUM).fontSize)
          .borderRadius(ButtonStyles.getButtonStyle(type, ButtonSize.MEDIUM).borderRadius)

        // Large
        Button('大')
          .height(ButtonStyles.getButtonStyle(type, ButtonSize.LARGE).height)
          .backgroundColor(ButtonStyles.getButtonStyle(type, ButtonSize.LARGE).backgroundColor)
          .fontColor(ButtonStyles.getButtonStyle(type, ButtonSize.LARGE).fontColor)
          .fontSize(ButtonStyles.getButtonStyle(type, ButtonSize.LARGE).fontSize)
          .borderRadius(ButtonStyles.getButtonStyle(type, ButtonSize.LARGE).borderRadius)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildCardSection() {
    Column({ space: ThemeSpacing.MD }) {
      Text('卡片样式')
        .fontSize(ThemeTypography.FONT_SIZE_LARGE)
        .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 默认卡片
      this.buildCardExample('默认卡片', CardType.DEFAULT);

      // 带阴影卡片
      this.buildCardExample('带阴影卡片', CardType.ELEVATED);

      // 带边框卡片
      this.buildCardExample('带边框卡片', CardType.OUTLINED);

      // 扁平卡片
      this.buildCardExample('扁平卡片', CardType.FLAT);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildCardExample(label: string, type: CardType) {
    const config = CardStyles.getCardStyle(type);

    Column() {
      Text(label)
        .fontSize(ThemeTypography.FONT_SIZE_BODY)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ bottom: ThemeSpacing.XS })

      Text('这是一个卡片示例，展示了不同的卡片样式效果。')
        .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .width('100%')
    .backgroundColor(config.backgroundColor)
    .borderRadius(config.borderRadius)
    .padding(config.padding)
    .shadow(config.shadow)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildInputSection() {
    Column({ space: ThemeSpacing.MD }) {
      Text('输入框样式')
        .fontSize(ThemeTypography.FONT_SIZE_LARGE)
        .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 标准输入框
      Column({ space: ThemeSpacing.XS }) {
        Text('标准输入框')
          .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        TextInput({ placeholder: '请输入内容' })
          .height(InputStyles.getInputStyle(InputSize.MEDIUM).height)
          .backgroundColor(InputStyles.getInputStyle(InputSize.MEDIUM).backgroundColor)
          .border({
            width: InputStyles.getInputStyle(InputSize.MEDIUM).borderWidth,
            color: InputStyles.getInputStyle(InputSize.MEDIUM).borderColor
          })
          .borderRadius(InputStyles.getInputStyle(InputSize.MEDIUM).borderRadius)
          .fontSize(InputStyles.getInputStyle(InputSize.MEDIUM).fontSize)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 小尺寸输入框
      Column({ space: ThemeSpacing.XS }) {
        Text('小尺寸输入框')
          .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        TextInput({ placeholder: '小尺寸' })
          .height(InputStyles.getInputStyle(InputSize.SMALL).height)
          .backgroundColor(InputStyles.getInputStyle(InputSize.SMALL).backgroundColor)
          .border({
            width: InputStyles.getInputStyle(InputSize.SMALL).borderWidth,
            color: InputStyles.getInputStyle(InputSize.SMALL).borderColor
          })
          .borderRadius(InputStyles.getInputStyle(InputSize.SMALL).borderRadius)
          .fontSize(InputStyles.getInputStyle(InputSize.SMALL).fontSize)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 大尺寸输入框
      Column({ space: ThemeSpacing.XS }) {
        Text('大尺寸输入框')
          .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        TextInput({ placeholder: '大尺寸' })
          .height(InputStyles.getInputStyle(InputSize.LARGE).height)
          .backgroundColor(InputStyles.getInputStyle(InputSize.LARGE).backgroundColor)
          .border({
            width: InputStyles.getInputStyle(InputSize.LARGE).borderWidth,
            color: InputStyles.getInputStyle(InputSize.LARGE).borderColor
          })
          .borderRadius(InputStyles.getInputStyle(InputSize.LARGE).borderRadius)
          .fontSize(InputStyles.getInputStyle(InputSize.LARGE).fontSize)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTextSection() {
    Column({ space: ThemeSpacing.MD }) {
      Text('文本样式')
        .fontSize(ThemeTypography.FONT_SIZE_LARGE)
        .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 标题样式
      Column({ space: ThemeSpacing.XS }) {
        Text('H1 标题')
          .fontSize(TextStyles.getH1Style().fontSize)
          .fontColor(TextStyles.getH1Style().fontColor)
          .fontWeight(TextStyles.getH1Style().fontWeight)

        Text('H2 标题')
          .fontSize(TextStyles.getH2Style().fontSize)
          .fontColor(TextStyles.getH2Style().fontColor)
          .fontWeight(TextStyles.getH2Style().fontWeight)

        Text('H3 标题')
          .fontSize(TextStyles.getH3Style().fontSize)
          .fontColor(TextStyles.getH3Style().fontColor)
          .fontWeight(TextStyles.getH3Style().fontWeight)

        Text('H4 标题')
          .fontSize(TextStyles.getH4Style().fontSize)
          .fontColor(TextStyles.getH4Style().fontColor)
          .fontWeight(TextStyles.getH4Style().fontWeight)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 正文样式
      Column({ space: ThemeSpacing.XS }) {
        Text('正文 - 这是正文样式的示例文本')
          .fontSize(TextStyles.getBodyStyle().fontSize)
          .fontColor(TextStyles.getBodyStyle().fontColor)
          .fontWeight(TextStyles.getBodyStyle().fontWeight)

        Text('小正文 - 这是小正文样式的示例文本')
          .fontSize(TextStyles.getBodySmallStyle().fontSize)
          .fontColor(TextStyles.getBodySmallStyle().fontColor)
          .fontWeight(TextStyles.getBodySmallStyle().fontWeight)

        Text('次要文本 - 这是次要文本样式的示例')
          .fontSize(TextStyles.getSecondaryStyle().fontSize)
          .fontColor(TextStyles.getSecondaryStyle().fontColor)
          .fontWeight(TextStyles.getSecondaryStyle().fontWeight)

        Text('说明文字 - 这是说明文字样式的示例')
          .fontSize(TextStyles.getCaptionStyle().fontSize)
          .fontColor(TextStyles.getCaptionStyle().fontColor)
          .fontWeight(TextStyles.getCaptionStyle().fontWeight)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 金额样式
      Column({ space: ThemeSpacing.XS }) {
        Text('收入金额')
          .fontSize(TextStyles.getIncomeStyle('large').fontSize)
          .fontColor(TextStyles.getIncomeStyle('large').fontColor)
          .fontWeight(TextStyles.getIncomeStyle('large').fontWeight)

        Text('支出金额')
          .fontSize(TextStyles.getExpenseStyle('large').fontSize)
          .fontColor(TextStyles.getExpenseStyle('large').fontColor)
          .fontWeight(TextStyles.getExpenseStyle('large').fontWeight)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
