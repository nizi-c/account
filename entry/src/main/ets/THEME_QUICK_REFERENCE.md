# 主题系统快速参考

## 快速导入

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
  InputSize,
  TextStyles
} from '../utils';
```

## 常用颜色

```typescript
// 主色
ThemeColors.PRIMARY              // #1890FF 蓝色
ThemeColors.SUCCESS              // #52C41A 绿色（收入）
ThemeColors.ERROR                // #FF4D4F 红色（支出）
ThemeColors.WARNING              // #FAAD14 橙色

// 文本
ThemeColors.TEXT_PRIMARY         // #262626 主要文本
ThemeColors.TEXT_SECONDARY       // #595959 次要文本
ThemeColors.TEXT_TERTIARY        // #8C8C8C 三级文本

// 背景
ThemeColors.BG_PRIMARY           // #FFFFFF 白色
ThemeColors.BG_SECONDARY         // #FAFAFA 浅灰
ThemeColors.BG_TERTIARY          // #F5F5F5 灰色

// 边框
ThemeColors.BORDER_PRIMARY       // #D9D9D9
ThemeColors.DIVIDER              // #E8E8E8
```

## 常用字体

```typescript
// 字体大小
ThemeTypography.FONT_SIZE_LARGE       // 24 大标题
ThemeTypography.FONT_SIZE_TITLE       // 20 标题
ThemeTypography.FONT_SIZE_BODY        // 16 正文
ThemeTypography.FONT_SIZE_BODY_SMALL  // 14 小正文
ThemeTypography.FONT_SIZE_CAPTION     // 12 说明

// 字重
ThemeTypography.FONT_WEIGHT_REGULAR   // 常规
ThemeTypography.FONT_WEIGHT_MEDIUM    // 中等
ThemeTypography.FONT_WEIGHT_BOLD      // 粗体
```

## 常用间距

```typescript
ThemeSpacing.XS      // 8px
ThemeSpacing.SM      // 12px
ThemeSpacing.MD      // 16px (默认)
ThemeSpacing.LG      // 20px
ThemeSpacing.XL      // 24px
ThemeSpacing.XXL     // 32px
```

## 常用圆角

```typescript
ThemeBorderRadius.SM       // 4px
ThemeBorderRadius.MD       // 8px (默认)
ThemeBorderRadius.LG       // 12px
ThemeBorderRadius.CIRCLE   // 999px (圆形)
```

## 按钮快速使用

```typescript
// 主要按钮
const primary = ButtonStyles.getButtonStyle(ButtonStyleType.PRIMARY);
Button('确定')
  .height(primary.height)
  .backgroundColor(primary.backgroundColor)
  .fontColor(primary.fontColor)
  .borderRadius(primary.borderRadius)
  .stateEffect(true)

// 次要按钮
const secondary = ButtonStyles.getButtonStyle(ButtonStyleType.SECONDARY);
Button('取消')
  .height(secondary.height)
  .backgroundColor(secondary.backgroundColor)
  .fontColor(secondary.fontColor)
  .border({ width: 1, color: ThemeColors.BORDER_PRIMARY })
  .borderRadius(secondary.borderRadius)
  .stateEffect(true)

// 危险按钮
const danger = ButtonStyles.getButtonStyle(ButtonStyleType.DANGER);
Button('删除')
  .height(danger.height)
  .backgroundColor(danger.backgroundColor)
  .fontColor(danger.fontColor)
  .borderRadius(danger.borderRadius)
  .stateEffect(true)
```

## 卡片快速使用

```typescript
// 默认卡片
const card = CardStyles.getCardStyle(CardType.DEFAULT);
Column() {
  // 内容
}
.backgroundColor(card.backgroundColor)
.borderRadius(card.borderRadius)
.padding(card.padding)
.shadow(card.shadow)

// 列表项卡片
const listItem = CardStyles.getListItemCardStyle();
Row() {
  // 内容
}
.backgroundColor(listItem.backgroundColor)
.borderRadius(listItem.borderRadius)
.padding(listItem.padding)
.margin(listItem.margin)
```

## 输入框快速使用

```typescript
// 标准输入框
const input = InputStyles.getInputStyle(InputSize.MEDIUM);
TextInput({ placeholder: '请输入' })
  .height(input.height)
  .backgroundColor(input.backgroundColor)
  .border({ width: input.borderWidth, color: input.borderColor })
  .borderRadius(input.borderRadius)
  .fontSize(input.fontSize)
  .placeholderColor(input.placeholderColor)
```

## 文本快速使用

```typescript
// 标题
Text('标题')
  .fontSize(TextStyles.getH3Style().fontSize)
  .fontColor(TextStyles.getH3Style().fontColor)
  .fontWeight(TextStyles.getH3Style().fontWeight)

// 正文
Text('内容')
  .fontSize(TextStyles.getBodyStyle().fontSize)
  .fontColor(TextStyles.getBodyStyle().fontColor)

// 次要文本
Text('说明')
  .fontSize(TextStyles.getSecondarySmallStyle().fontSize)
  .fontColor(TextStyles.getSecondarySmallStyle().fontColor)

// 收入金额
Text('+1000.00')
  .fontSize(TextStyles.getIncomeStyle('large').fontSize)
  .fontColor(TextStyles.getIncomeStyle('large').fontColor)
  .fontWeight(TextStyles.getIncomeStyle('large').fontWeight)

// 支出金额
Text('-500.00')
  .fontSize(TextStyles.getExpenseStyle('large').fontSize)
  .fontColor(TextStyles.getExpenseStyle('large').fontColor)
  .fontWeight(TextStyles.getExpenseStyle('large').fontWeight)
```

## 加载状态快速使用

```typescript
// 加载指示器
const loading = FeedbackStyles.getLoadingStyle('medium');
LoadingProgress()
  .width(loading.size)
  .height(loading.size)
  .color(loading.color)

// 空状态
Column() {
  Text('📝')
    .fontSize(64)
  Text('暂无数据')
    .fontSize(16)
    .fontColor(ThemeColors.TEXT_SECONDARY)
    .margin({ top: 12 })
}
```

## 常用组合

### 页面容器
```typescript
Column() {
  // 页面内容
}
.width('100%')
.height('100%')
.backgroundColor(ThemeColors.BG_TERTIARY)
.padding(ThemeSpacing.MD)
```

### 内容卡片
```typescript
Column() {
  Text('标题')
    .fontSize(ThemeTypography.FONT_SIZE_TITLE)
    .fontColor(ThemeColors.TEXT_PRIMARY)
    .fontWeight(ThemeTypography.FONT_WEIGHT_BOLD)
    .margin({ bottom: ThemeSpacing.SM })
  
  Text('内容')
    .fontSize(ThemeTypography.FONT_SIZE_BODY)
    .fontColor(ThemeColors.TEXT_SECONDARY)
}
.width('100%')
.backgroundColor(ThemeColors.BG_PRIMARY)
.borderRadius(ThemeBorderRadius.MD)
.padding(ThemeSpacing.MD)
.shadow({ radius: 4, color: ThemeColors.SHADOW_LIGHT })
```

### 列表项
```typescript
Row() {
  Column() {
    Text('标题')
      .fontSize(ThemeTypography.FONT_SIZE_BODY)
      .fontColor(ThemeColors.TEXT_PRIMARY)
    Text('副标题')
      .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
      .fontColor(ThemeColors.TEXT_SECONDARY)
  }
  .alignItems(HorizontalAlign.Start)
  .layoutWeight(1)
  
  Text('详情')
    .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
    .fontColor(ThemeColors.PRIMARY)
}
.width('100%')
.padding(ThemeSpacing.MD)
.backgroundColor(ThemeColors.BG_PRIMARY)
.borderRadius(ThemeBorderRadius.MD)
.margin({ left: ThemeSpacing.MD, right: ThemeSpacing.MD, top: ThemeSpacing.XS })
```

### 表单项
```typescript
Column() {
  Text('标签')
    .fontSize(ThemeTypography.FONT_SIZE_BODY_SMALL)
    .fontColor(ThemeColors.TEXT_SECONDARY)
    .margin({ bottom: ThemeSpacing.XS })
  
  TextInput({ placeholder: '请输入' })
    .height(40)
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .border({ width: 1, color: ThemeColors.BORDER_PRIMARY })
    .borderRadius(ThemeBorderRadius.MD)
    .fontSize(ThemeTypography.FONT_SIZE_BODY)
}
.width('100%')
.alignItems(HorizontalAlign.Start)
.margin({ bottom: ThemeSpacing.MD })
```

## 记住这些原则

1. ✅ **始终使用主题常量**，不要硬编码颜色和尺寸
2. ✅ **使用语义化颜色**（SUCCESS表示收入，ERROR表示支出）
3. ✅ **保持间距一致**，使用标准间距值
4. ✅ **为可点击元素添加** `.stateEffect(true)`
5. ✅ **确保触摸目标至少 48dp**

## 更多信息

- 详细文档: [THEME_README.md](./utils/THEME_README.md)
- 使用指南: [THEME_GUIDE.md](./THEME_GUIDE.md)
- 实现总结: [THEME_IMPLEMENTATION_SUMMARY.md](./THEME_IMPLEMENTATION_SUMMARY.md)
