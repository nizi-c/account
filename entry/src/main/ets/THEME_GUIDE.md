# UI 主题和样式指南

本文档描述了收支记账APP的UI主题系统和样式规范。

## 概述

应用采用统一的设计系统，确保所有界面元素保持一致的视觉风格。主题系统包括：

- 颜色方案
- 字体和排版
- 间距和布局
- 圆角和阴影
- 按钮样式
- 卡片样式
- 输入框样式
- 视觉反馈

## 颜色方案

### 主色调
- **主色**: `#1890FF` (蓝色) - 用于主要操作按钮、链接、强调元素
- **主色浅色**: `#40A9FF` - 用于悬停状态
- **主色深色**: `#096DD9` - 用于按压状态

### 语义颜色
- **成功/收入**: `#52C41A` (绿色)
- **错误/支出**: `#FF4D4F` (红色)
- **警告**: `#FAAD14` (橙色)
- **信息**: `#1890FF` (蓝色)

### 文本颜色
- **主要文本**: `#262626`
- **次要文本**: `#595959`
- **三级文本**: `#8C8C8C`
- **禁用文本**: `#BFBFBF`

### 背景颜色
- **主背景**: `#FFFFFF` (白色)
- **次背景**: `#FAFAFA` (浅灰)
- **三级背景**: `#F5F5F5` (灰色)

### 边框和分割线
- **主边框**: `#D9D9D9`
- **次边框**: `#E8E8E8`
- **分割线**: `#E8E8E8`

## 字体和排版

### 字体大小
- **超大标题**: 32fp
- **特大标题**: 28fp
- **大标题**: 24fp
- **标题**: 20fp
- **副标题**: 18fp
- **正文**: 16fp
- **小正文**: 14fp
- **说明文字**: 12fp

### 字重
- **细体**: FontWeight.Lighter
- **常规**: FontWeight.Normal
- **中等**: FontWeight.Medium
- **粗体**: FontWeight.Bold

### 行高
- **紧凑**: 1.2
- **正常**: 1.5
- **宽松**: 1.8

## 间距规范

基础间距单位：4px

- **XXXS**: 2px
- **XXS**: 4px
- **XS**: 8px
- **SM**: 12px
- **MD**: 16px (默认)
- **LG**: 20px
- **XL**: 24px
- **XXL**: 32px
- **XXXL**: 40px
- **HUGE**: 48px

## 圆角规范

- **NONE**: 0
- **XS**: 2px
- **SM**: 4px
- **MD**: 8px (默认)
- **LG**: 12px
- **XL**: 16px
- **XXL**: 24px
- **CIRCLE**: 999px (圆形)

## 按钮样式

### 主要按钮 (Primary)
```typescript
Button('确定')
  .backgroundColor(ThemeColors.PRIMARY)
  .fontColor(Color.White)
  .height(40)
  .borderRadius(8)
```

### 次要按钮 (Secondary)
```typescript
Button('取消')
  .backgroundColor(Color.White)
  .fontColor(ThemeColors.TEXT_PRIMARY)
  .border({ width: 1, color: ThemeColors.BORDER_PRIMARY })
  .height(40)
  .borderRadius(8)
```

### 危险按钮 (Danger)
```typescript
Button('删除')
  .backgroundColor(ThemeColors.DANGER)
  .fontColor(Color.White)
  .height(40)
  .borderRadius(8)
```

### 文本按钮 (Text)
```typescript
Button('了解更多')
  .backgroundColor(Color.Transparent)
  .fontColor(ThemeColors.PRIMARY)
```

## 卡片样式

### 默认卡片
```typescript
Column() {
  // 内容
}
.backgroundColor(ThemeColors.BG_PRIMARY)
.borderRadius(8)
.padding(16)
.shadow({ radius: 4, color: ThemeColors.SHADOW_LIGHT })
```

### 列表项卡片
```typescript
Row() {
  // 内容
}
.backgroundColor(ThemeColors.BG_PRIMARY)
.borderRadius(8)
.padding(16)
.margin({ left: 16, right: 16, top: 8, bottom: 8 })
```

## 输入框样式

### 标准输入框
```typescript
TextInput({ placeholder: '请输入' })
  .backgroundColor(ThemeColors.BG_PRIMARY)
  .border({ width: 1, color: ThemeColors.BORDER_PRIMARY })
  .borderRadius(8)
  .height(40)
  .padding(12)
  .fontSize(16)
```

### 聚焦状态
```typescript
.border({ width: 1, color: ThemeColors.PRIMARY })
```

### 错误状态
```typescript
.border({ width: 1, color: ThemeColors.ERROR })
```

## 视觉反馈

### 加载状态
```typescript
LoadingProgress()
  .width(48)
  .height(48)
  .color(ThemeColors.PRIMARY)
```

### 空状态
```typescript
Column() {
  Text('📝')
    .fontSize(64)
  Text('暂无数据')
    .fontSize(16)
    .fontColor(ThemeColors.TEXT_SECONDARY)
    .margin({ top: 12 })
}
```

### 按压效果
所有可点击元素应该启用状态效果：
```typescript
.stateEffect(true)
```

## 使用示例

### 导入主题常量
```typescript
import { 
  ThemeColors, 
  ThemeTypography, 
  ThemeSpacing, 
  ThemeBorderRadius 
} from '../utils/ThemeConstants';
```

### 使用按钮样式
```typescript
import { ButtonStyles, ButtonStyleType, ButtonSize } from '../utils/ButtonStyles';

const config = ButtonStyles.getButtonStyle(ButtonStyleType.PRIMARY, ButtonSize.MEDIUM);

Button('提交')
  .height(config.height)
  .backgroundColor(config.backgroundColor)
  .fontColor(config.fontColor)
  .fontSize(config.fontSize)
  .borderRadius(config.borderRadius)
```

### 使用卡片样式
```typescript
import { CardStyles, CardType } from '../utils/CardStyles';

const cardConfig = CardStyles.getCardStyle(CardType.ELEVATED);

Column() {
  // 内容
}
.backgroundColor(cardConfig.backgroundColor)
.borderRadius(cardConfig.borderRadius)
.padding(cardConfig.padding)
.shadow(cardConfig.shadow)
```

### 使用文本样式
```typescript
import { TextStyles } from '../utils/TextStyles';

const titleStyle = TextStyles.getH3Style();

Text('标题')
  .fontSize(titleStyle.fontSize)
  .fontColor(titleStyle.fontColor)
  .fontWeight(titleStyle.fontWeight)
```

## 响应式设计

### 手机布局
- 单列布局
- 全宽卡片
- 底部导航栏

### 平板布局
- 多列布局（横屏时）
- 侧边栏导航
- 更大的间距和字体

### 适配代码示例
```typescript
if (this.deviceType === DeviceType.TABLET && ResponsiveUtils.isLandscape(width, height)) {
  // 平板横屏布局
  this.buildTabletLayout();
} else {
  // 手机或平板竖屏布局
  this.buildPhoneLayout();
}
```

## 无障碍性

### 触摸目标
所有可点击元素的最小尺寸应为 48dp × 48dp

### 颜色对比度
- 文本与背景的对比度应至少为 4.5:1
- 大文本（18fp以上）的对比度应至少为 3:1

### 屏幕阅读器
为重要元素添加描述：
```typescript
.accessibilityText('添加交易按钮')
```

## 动画和过渡

### 持续时间
- **快速**: 150ms - 用于简单的状态变化
- **正常**: 300ms - 用于大多数过渡
- **慢速**: 500ms - 用于复杂的动画

### 缓动曲线
- **Ease**: 默认缓动
- **EaseIn**: 加速进入
- **EaseOut**: 减速退出
- **EaseInOut**: 先加速后减速
- **Spring**: 弹性效果

## 最佳实践

1. **保持一致性**: 始终使用主题常量，避免硬编码颜色和尺寸
2. **语义化**: 使用语义化的颜色（如 SUCCESS 表示成功，ERROR 表示错误）
3. **可访问性**: 确保足够的颜色对比度和触摸目标尺寸
4. **响应式**: 根据设备类型和屏幕尺寸调整布局
5. **视觉反馈**: 为所有交互提供即时的视觉反馈
6. **性能**: 避免过度使用阴影和复杂动画

## 维护和更新

当需要更新主题时：

1. 修改 `ThemeConstants.ets` 中的常量
2. 更新资源文件 `color.json` 和 `float.json`
3. 测试所有页面确保一致性
4. 更新本文档

## 参考资源

- [HarmonyOS ArkUI 文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-ui-development-overview-0000001438467628-V3)
- [Material Design 指南](https://material.io/design)
- [Ant Design 设计规范](https://ant.design/docs/spec/introduce-cn)
