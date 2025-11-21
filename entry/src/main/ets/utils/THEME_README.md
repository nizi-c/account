# 主题系统使用指南

## 概述

本主题系统为收支记账APP提供了一套完整的设计规范和样式工具，确保整个应用的视觉一致性。

## 文件结构

```
utils/
├── ThemeConstants.ets      # 主题常量（颜色、字体、间距等）
├── ButtonStyles.ets         # 按钮样式工具
├── CardStyles.ets           # 卡片样式工具
├── InputStyles.ets          # 输入框样式工具
├── TextStyles.ets           # 文本样式工具
├── FeedbackStyles.ets       # 视觉反馈样式工具
└── index.ets                # 统一导出
```

## 快速开始

### 1. 导入主题工具

```typescript
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
  TextStyles
} from '../utils';
```

### 2. 使用颜色常量

```typescript
// ✅ 推荐：使用主题常量
Text('标题')
  .fontColor(ThemeColors.TEXT_PRIMARY)
  .backgroundColor(ThemeColors.BG_PRIMARY)

// ❌ 不推荐：硬编码颜色
Text('标题')
  .fontColor('#262626')
  .backgroundColor('#FFFFFF')
```

### 3. 使用按钮样式

```typescript
// 方式一：使用样式配置
const primaryConfig = ButtonStyles.getButtonStyle(ButtonStyleType.PRIMARY, ButtonSize.MEDIUM);

Button('提交')
  .height(primaryConfig.height)
  .backgroundColor(primaryConfig.backgroundColor)
  .fontColor(primaryConfig.fontColor)
  .fontSize(primaryConfig.fontSize)
  .borderRadius(primaryConfig.borderRadius)
  .stateEffect(true)

// 方式二：直接使用常量
Button('取消')
  .height(40)
  .backgroundColor(ThemeColors.BG_PRIMARY)
  .fontColor(ThemeColors.TEXT_PRIMARY)
  .border({ width: 1, color: ThemeColors.BORDER_PRIMARY })
  .borderRadius(ThemeBorderRadius.BUTTON)
  .stateEffect(true)
```

### 4. 使用卡片样式

```typescript
const cardConfig = CardStyles.getCardStyle(CardType.ELEVATED);

Column() {
  Text('卡片标题')
    .fontSize(ThemeTypography.FONT_SIZE_TITLE)
    .fontColor(ThemeColors.TEXT_PRIMARY)
  
  Text('卡片内容')
    .fontSize(ThemeTypography.FONT_SIZE_BODY)
    .fontColor(ThemeColors.TEXT_SECONDARY)
}
.width('100%')
.backgroundColor(cardConfig.backgroundColor)
.borderRadius(cardConfig.borderRadius)
.padding(cardConfig.padding)
.shadow(cardConfig.shadow)
```

### 5. 使用输入框样式

```typescript
const inputConfig = InputStyles.getInputStyle(InputSize.MEDIUM);

TextInput({ placeholder: '请输入金额' })
  .height(inputConfig.height)
  .backgroundColor(inputConfig.backgroundColor)
  .border({
    width: inputConfig.borderWidth,
    color: inputConfig.borderColor
  })
  .borderRadius(inputConfig.borderRadius)
  .fontSize(inputConfig.fontSize)
  .placeholderColor(inputConfig.placeholderColor)
```

### 6. 使用文本样式

```typescript
// 标题
Text('页面标题')
  .fontSize(TextStyles.getH3Style().fontSize)
  .fontColor(TextStyles.getH3Style().fontColor)
  .fontWeight(TextStyles.getH3Style().fontWeight)

// 正文
Text('这是正文内容')
  .fontSize(TextStyles.getBodyStyle().fontSize)
  .fontColor(TextStyles.getBodyStyle().fontColor)

// 金额（收入）
Text(FormatUtils.formatCurrency(1000))
  .fontSize(TextStyles.getIncomeStyle('large').fontSize)
  .fontColor(TextStyles.getIncomeStyle('large').fontColor)
  .fontWeight(TextStyles.getIncomeStyle('large').fontWeight)

// 金额（支出）
Text(FormatUtils.formatCurrency(500))
  .fontSize(TextStyles.getExpenseStyle('large').fontSize)
  .fontColor(TextStyles.getExpenseStyle('large').fontColor)
  .fontWeight(TextStyles.getExpenseStyle('large').fontWeight)
```

## 主题常量详解

### ThemeColors - 颜色常量

```typescript
// 主色调
ThemeColors.PRIMARY              // #1890FF
ThemeColors.PRIMARY_LIGHT        // #40A9FF
ThemeColors.PRIMARY_DARK         // #096DD9

// 语义颜色
ThemeColors.SUCCESS              // #52C41A (收入)
ThemeColors.ERROR                // #FF4D4F (支出)
ThemeColors.WARNING              // #FAAD14
ThemeColors.INFO                 // #1890FF

// 文本颜色
ThemeColors.TEXT_PRIMARY         // #262626
ThemeColors.TEXT_SECONDARY       // #595959
ThemeColors.TEXT_TERTIARY        // #8C8C8C
ThemeColors.TEXT_DISABLED        // #BFBFBF

// 背景颜色
ThemeColors.BG_PRIMARY           // #FFFFFF
ThemeColors.BG_SECONDARY         // #FAFAFA
ThemeColors.BG_TERTIARY          // #F5F5F5

// 边框和分割线
ThemeColors.BORDER_PRIMARY       // #D9D9D9
ThemeColors.BORDER_SECONDARY     // #E8E8E8
ThemeColors.DIVIDER              // #E8E8E8
```

### ThemeTypography - 字体常量

```typescript
// 字体大小
ThemeTypography.FONT_SIZE_HUGE        // 32
ThemeTypography.FONT_SIZE_XLARGE      // 28
ThemeTypography.FONT_SIZE_LARGE       // 24
ThemeTypography.FONT_SIZE_TITLE       // 20
ThemeTypography.FONT_SIZE_SUBTITLE    // 18
ThemeTypography.FONT_SIZE_BODY        // 16
ThemeTypography.FONT_SIZE_BODY_SMALL  // 14
ThemeTypography.FONT_SIZE_CAPTION     // 12

// 字重
ThemeTypography.FONT_WEIGHT_LIGHT     // FontWeight.Lighter
ThemeTypography.FONT_WEIGHT_REGULAR   // FontWeight.Normal
ThemeTypography.FONT_WEIGHT_MEDIUM    // FontWeight.Medium
ThemeTypography.FONT_WEIGHT_BOLD      // FontWeight.Bold
```

### ThemeSpacing - 间距常量

```typescript
ThemeSpacing.XXXS    // 2px
ThemeSpacing.XXS     // 4px
ThemeSpacing.XS      // 8px
ThemeSpacing.SM      // 12px
ThemeSpacing.MD      // 16px (默认)
ThemeSpacing.LG      // 20px
ThemeSpacing.XL      // 24px
ThemeSpacing.XXL     // 32px
ThemeSpacing.XXXL    // 40px
ThemeSpacing.HUGE    // 48px
```

### ThemeBorderRadius - 圆角常量

```typescript
ThemeBorderRadius.NONE     // 0
ThemeBorderRadius.XS       // 2
ThemeBorderRadius.SM       // 4
ThemeBorderRadius.MD       // 8 (默认)
ThemeBorderRadius.LG       // 12
ThemeBorderRadius.XL       // 16
ThemeBorderRadius.XXL      // 24
ThemeBorderRadius.CIRCLE   // 999 (圆形)
```

## 样式工具类详解

### ButtonStyles - 按钮样式

```typescript
// 按钮类型
ButtonStyleType.PRIMARY      // 主要按钮
ButtonStyleType.SECONDARY    // 次要按钮
ButtonStyleType.DANGER       // 危险按钮
ButtonStyleType.SUCCESS      // 成功按钮
ButtonStyleType.WARNING      // 警告按钮
ButtonStyleType.TEXT         // 文本按钮
ButtonStyleType.LINK         // 链接按钮

// 按钮尺寸
ButtonSize.SMALL    // 小 (32px)
ButtonSize.MEDIUM   // 中 (40px)
ButtonSize.LARGE    // 大 (48px)

// 使用示例
const config = ButtonStyles.getButtonStyle(ButtonStyleType.PRIMARY, ButtonSize.MEDIUM);
```

### CardStyles - 卡片样式

```typescript
// 卡片类型
CardType.DEFAULT    // 默认卡片（带浅阴影）
CardType.ELEVATED   // 带阴影的卡片
CardType.OUTLINED   // 带边框的卡片
CardType.FLAT       // 扁平卡片（无阴影无边框）

// 使用示例
const config = CardStyles.getCardStyle(CardType.ELEVATED);
const summaryConfig = CardStyles.getSummaryCardStyle();
const listItemConfig = CardStyles.getListItemCardStyle();
```

### InputStyles - 输入框样式

```typescript
// 输入框尺寸
InputSize.SMALL     // 小 (32px)
InputSize.MEDIUM    // 中 (40px)
InputSize.LARGE     // 大 (48px)

// 输入框状态
InputState.NORMAL    // 正常
InputState.FOCUS     // 聚焦
InputState.ERROR     // 错误
InputState.DISABLED  // 禁用

// 使用示例
const config = InputStyles.getInputStyle(InputSize.MEDIUM, InputState.NORMAL);
const searchConfig = InputStyles.getSearchInputStyle();
```

### TextStyles - 文本样式

```typescript
// 标题样式
TextStyles.getH1Style()    // H1 标题
TextStyles.getH2Style()    // H2 标题
TextStyles.getH3Style()    // H3 标题
TextStyles.getH4Style()    // H4 标题
TextStyles.getH5Style()    // H5 标题

// 正文样式
TextStyles.getBodyStyle()           // 正文
TextStyles.getBodySmallStyle()      // 小正文
TextStyles.getSecondaryStyle()      // 次要文本
TextStyles.getCaptionStyle()        // 说明文字

// 特殊样式
TextStyles.getLinkStyle()           // 链接
TextStyles.getEmphasisStyle()       // 强调
TextStyles.getDisabledStyle()       // 禁用

// 金额样式
TextStyles.getIncomeStyle('large')   // 收入金额
TextStyles.getExpenseStyle('large')  // 支出金额
```

### FeedbackStyles - 视觉反馈样式

```typescript
// 加载样式
FeedbackStyles.getLoadingStyle('medium')
FeedbackStyles.getFullScreenLoadingStyle()

// 空状态样式
FeedbackStyles.getEmptyStateStyle()
FeedbackStyles.getErrorStateStyle()

// Toast 样式
FeedbackStyles.getToastStyle('success')
FeedbackStyles.getToastStyle('error')
FeedbackStyles.getToastStyle('warning')
FeedbackStyles.getToastStyle('info')

// 进度条样式
FeedbackStyles.getProgressBarStyle('normal')
FeedbackStyles.getProgressBarStyle('success')
FeedbackStyles.getProgressBarStyle('warning')
FeedbackStyles.getProgressBarStyle('error')
```

### BadgeStyles - 徽章样式

```typescript
// 徽章样式
BadgeStyles.getBadgeStyle('primary')
BadgeStyles.getBadgeStyle('success')
BadgeStyles.getBadgeStyle('warning')
BadgeStyles.getBadgeStyle('error')

// 特殊徽章
BadgeStyles.getDotBadgeStyle()      // 小红点
BadgeStyles.getCountBadgeStyle()    // 计数徽章
```

### TagStyles - 标签样式

```typescript
TagStyles.getTagStyle('primary')
TagStyles.getTagStyle('success')
TagStyles.getTagStyle('warning')
TagStyles.getTagStyle('error')
TagStyles.getTagStyle('default')
```

## 最佳实践

### 1. 始终使用主题常量

```typescript
// ✅ 好的做法
.fontColor(ThemeColors.TEXT_PRIMARY)
.padding(ThemeSpacing.MD)
.borderRadius(ThemeBorderRadius.MD)

// ❌ 不好的做法
.fontColor('#262626')
.padding(16)
.borderRadius(8)
```

### 2. 使用语义化颜色

```typescript
// ✅ 好的做法 - 使用语义化颜色
Text('收入')
  .fontColor(ThemeColors.SUCCESS)

Text('支出')
  .fontColor(ThemeColors.ERROR)

// ❌ 不好的做法 - 直接使用颜色值
Text('收入')
  .fontColor('#52C41A')
```

### 3. 保持间距一致

```typescript
// ✅ 好的做法 - 使用标准间距
Column({ space: ThemeSpacing.MD }) {
  // 内容
}
.padding(ThemeSpacing.MD)
.margin({ top: ThemeSpacing.XS, bottom: ThemeSpacing.XS })

// ❌ 不好的做法 - 随意的间距值
Column({ space: 15 }) {
  // 内容
}
.padding(17)
.margin({ top: 7, bottom: 9 })
```

### 4. 使用样式工具类

```typescript
// ✅ 好的做法 - 使用样式工具类
const buttonConfig = ButtonStyles.getButtonStyle(ButtonStyleType.PRIMARY);
Button('确定')
  .height(buttonConfig.height)
  .backgroundColor(buttonConfig.backgroundColor)
  // ...

// ❌ 不好的做法 - 每次都手动设置
Button('确定')
  .height(40)
  .backgroundColor('#1890FF')
  .fontColor('#FFFFFF')
  // ...
```

### 5. 启用状态效果

```typescript
// ✅ 好的做法 - 为可点击元素启用状态效果
Button('点击')
  .stateEffect(true)

Row()
  .onClick(() => {})
  .stateEffect(true)

// ❌ 不好的做法 - 没有视觉反馈
Button('点击')
  // 缺少 stateEffect
```

## 响应式设计

### 根据设备类型调整样式

```typescript
import { ResponsiveUtils, DeviceType } from '../utils';

@State deviceType: DeviceType = DeviceType.PHONE;

// 根据设备类型调整字体大小
const fontSize = this.deviceType === DeviceType.TABLET 
  ? ThemeTypography.FONT_SIZE_LARGE 
  : ThemeTypography.FONT_SIZE_BODY;

// 根据设备类型调整间距
const padding = this.deviceType === DeviceType.TABLET 
  ? ThemeSpacing.XL 
  : ThemeSpacing.MD;
```

## 调试和预览

使用 `ThemeShowcase` 组件预览所有样式：

```typescript
import { ThemeShowcase } from '../components';

// 在开发页面中使用
ThemeShowcase()
```

## 扩展主题

如果需要添加新的颜色或样式：

1. 在 `ThemeConstants.ets` 中添加新常量
2. 更新 `color.json` 和 `float.json` 资源文件
3. 如果需要，创建新的样式工具类
4. 更新 `index.ets` 导出新的工具
5. 更新本文档

## 常见问题

### Q: 如何自定义主题颜色？
A: 修改 `ThemeConstants.ets` 中的 `ThemeColors` 类，并更新资源文件。

### Q: 如何添加新的按钮样式？
A: 在 `ButtonStyles.ets` 的 `ButtonStyleType` 枚举中添加新类型，并在 `getBaseStyleByType` 方法中添加对应的样式配置。

### Q: 深色模式如何支持？
A: 资源文件中已包含 `dark` 目录，可以在其中定义深色主题的颜色。系统会根据设备设置自动切换。

### Q: 如何确保无障碍性？
A: 使用 `ThemeSizes.TOUCH_TARGET_MIN` (48dp) 作为可点击元素的最小尺寸，确保颜色对比度符合标准。

## 参考资源

- [主题指南](../THEME_GUIDE.md)
- [HarmonyOS ArkUI 文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-ui-development-overview-0000001438467628-V3)
- [设计规范](../../../docs/design-spec.md)
