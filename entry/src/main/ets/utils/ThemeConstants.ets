/**
 * ThemeConstants - 全局主题常量
 * 定义应用的颜色方案、字体、间距等设计规范
 * 需求：9.4, 9.5, 9.6
 */

/**
 * 颜色方案
 * 需求：9.6 - 一致的配色方案
 */
export class ThemeColors {
  // Primary colors - 主色调
  static readonly PRIMARY = '#1890FF';           // 主色 - 蓝色
  static readonly PRIMARY_LIGHT = '#40A9FF';     // 主色浅色
  static readonly PRIMARY_LIGHTER = '#69C0FF';   // 主色更浅
  static readonly PRIMARY_LIGHTEST = '#E6F7FF';  // 主色最浅（背景）
  static readonly PRIMARY_DARK = '#096DD9';      // 主色深色
  
  // Success colors - 成功/收入
  static readonly SUCCESS = '#52C41A';           // 成功色 - 绿色
  static readonly SUCCESS_LIGHT = '#73D13D';     // 成功色浅色
  static readonly SUCCESS_LIGHTEST = '#F6FFED';  // 成功色最浅（背景）
  
  // Error/Danger colors - 错误/支出
  static readonly ERROR = '#FF4D4F';             // 错误色 - 红色
  static readonly DANGER = '#FF4D4F';            // 危险色（同错误色）
  static readonly ERROR_LIGHT = '#FF7875';       // 错误色浅色
  static readonly ERROR_LIGHTEST = '#FFF1F0';    // 错误色最浅（背景）
  
  // Warning colors - 警告
  static readonly WARNING = '#FAAD14';           // 警告色 - 橙色
  static readonly WARNING_LIGHT = '#FFC53D';     // 警告色浅色
  static readonly WARNING_LIGHTEST = '#FFFBE6';  // 警告色最浅（背景）
  
  // Info colors - 信息
  static readonly INFO = '#1890FF';              // 信息色（同主色）
  static readonly INFO_LIGHT = '#40A9FF';        // 信息色浅色
  static readonly INFO_LIGHTEST = '#E6F7FF';     // 信息色最浅（背景）
  
  // Neutral colors - 中性色
  static readonly TEXT_PRIMARY = '#262626';      // 主要文本
  static readonly TEXT_SECONDARY = '#595959';    // 次要文本
  static readonly TEXT_TERTIARY = '#8C8C8C';     // 三级文本
  static readonly TEXT_DISABLED = '#BFBFBF';     // 禁用文本
  static readonly TEXT_PLACEHOLDER = '#BFBFBF';  // 占位符文本
  
  // Background colors - 背景色
  static readonly BG_PRIMARY = '#FFFFFF';        // 主背景（白色）
  static readonly BG_SECONDARY = '#FAFAFA';      // 次背景（浅灰）
  static readonly BG_TERTIARY = '#F5F5F5';       // 三级背景（灰色）
  static readonly BG_DISABLED = '#F5F5F5';       // 禁用背景
  
  // Border colors - 边框色
  static readonly BORDER_PRIMARY = '#D9D9D9';    // 主边框
  static readonly BORDER_SECONDARY = '#E8E8E8';  // 次边框
  static readonly BORDER_LIGHT = '#F0F0F0';      // 浅边框
  
  // Divider colors - 分割线
  static readonly DIVIDER = '#E8E8E8';           // 分割线
  static readonly DIVIDER_LIGHT = '#F0F0F0';     // 浅分割线
  
  // Shadow colors - 阴影色
  static readonly SHADOW_LIGHT = '#00000010';    // 浅阴影（10% 透明度）
  static readonly SHADOW_MEDIUM = '#00000020';   // 中阴影（20% 透明度）
  static readonly SHADOW_DARK = '#00000030';     // 深阴影（30% 透明度）
  
  // Overlay colors - 遮罩色
  static readonly OVERLAY_LIGHT = '#00000040';   // 浅遮罩（40% 透明度）
  static readonly OVERLAY_MEDIUM = '#00000060';  // 中遮罩（60% 透明度）
  static readonly OVERLAY_DARK = '#00000080';    // 深遮罩（80% 透明度）
  
  // Mood colors - 情绪颜色
  static readonly MOOD_SATISFIED = '#52C41A';    // 满意 😊
  static readonly MOOD_REGRET = '#FF4D4F';       // 后悔 😟
  static readonly MOOD_SURPRISE = '#FAAD14';     // 惊喜 🎉
  
  // Chart colors - 图表颜色
  static readonly CHART_COLORS = [
    '#1890FF', '#52C41A', '#FAAD14', '#FF4D4F',
    '#722ED1', '#13C2C2', '#EB2F96', '#FA8C16',
    '#2F54EB', '#A0D911', '#F5222D', '#FA541C'
  ];
}

/**
 * 字体和排版规范
 * 需求：9.6 - 一致的字体
 */
export class ThemeTypography {
  // Font sizes - 字体大小
  static readonly FONT_SIZE_HUGE = 32;           // 超大标题
  static readonly FONT_SIZE_XLARGE = 28;         // 特大标题
  static readonly FONT_SIZE_LARGE = 24;          // 大标题
  static readonly FONT_SIZE_TITLE = 20;          // 标题
  static readonly FONT_SIZE_SUBTITLE = 18;       // 副标题
  static readonly FONT_SIZE_BODY = 16;           // 正文
  static readonly FONT_SIZE_BODY_SMALL = 14;     // 小正文
  static readonly FONT_SIZE_CAPTION = 12;        // 说明文字
  static readonly FONT_SIZE_TINY = 10;           // 极小文字
  
  // Font weights - 字重
  static readonly FONT_WEIGHT_LIGHT = FontWeight.Lighter;    // 细体
  static readonly FONT_WEIGHT_REGULAR = FontWeight.Normal;   // 常规
  static readonly FONT_WEIGHT_MEDIUM = FontWeight.Medium;    // 中等
  static readonly FONT_WEIGHT_BOLD = FontWeight.Bold;        // 粗体
  static readonly FONT_WEIGHT_BOLDER = FontWeight.Bolder;    // 更粗
  
  // Line heights - 行高
  static readonly LINE_HEIGHT_TIGHT = 1.2;       // 紧凑
  static readonly LINE_HEIGHT_NORMAL = 1.5;      // 正常
  static readonly LINE_HEIGHT_RELAXED = 1.8;     // 宽松
}

/**
 * 间距规范
 * 需求：9.6 - 一致的间距
 */
export class ThemeSpacing {
  // Base spacing unit (4px)
  static readonly UNIT = 4;
  
  // Spacing scale
  static readonly XXXS = 2;    // 2px
  static readonly XXS = 4;     // 4px
  static readonly XS = 8;      // 8px
  static readonly SM = 12;     // 12px
  static readonly MD = 16;     // 16px (default)
  static readonly LG = 20;     // 20px
  static readonly XL = 24;     // 24px
  static readonly XXL = 32;    // 32px
  static readonly XXXL = 40;   // 40px
  static readonly HUGE = 48;   // 48px
  
  // Component specific spacing
  static readonly CARD_PADDING = 16;
  static readonly PAGE_PADDING = 16;
  static readonly BUTTON_PADDING_H = 16;
  static readonly BUTTON_PADDING_V = 12;
  static readonly INPUT_PADDING = 12;
  static readonly LIST_ITEM_PADDING = 16;
}

/**
 * 圆角规范
 * 需求：9.6 - 一致的圆角
 */
export class ThemeBorderRadius {
  static readonly NONE = 0;
  static readonly XS = 2;
  static readonly SM = 4;
  static readonly MD = 8;      // 默认圆角
  static readonly LG = 12;
  static readonly XL = 16;
  static readonly XXL = 24;
  static readonly CIRCLE = 999; // 圆形
  
  // Component specific
  static readonly BUTTON = 8;
  static readonly CARD = 8;
  static readonly INPUT = 8;
  static readonly TAG = 4;
  static readonly BADGE = 12;
}

/**
 * Shadow configuration interface
 */
interface ShadowConfig {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

/**
 * 阴影规范
 */
export class ThemeShadow {
  // Shadow configurations
  static readonly NONE: ShadowConfig = { radius: 0, color: ThemeColors.SHADOW_LIGHT, offsetX: 0, offsetY: 0 };
  
  static readonly SM: ShadowConfig = {
    radius: 4,
    color: ThemeColors.SHADOW_LIGHT,
    offsetX: 0,
    offsetY: 2
  };
  
  static readonly MD: ShadowConfig = {
    radius: 8,
    color: ThemeColors.SHADOW_LIGHT,
    offsetX: 0,
    offsetY: 4
  };
  
  static readonly LG: ShadowConfig = {
    radius: 12,
    color: ThemeColors.SHADOW_MEDIUM,
    offsetX: 0,
    offsetY: 6
  };
  
  static readonly XL: ShadowConfig = {
    radius: 16,
    color: ThemeColors.SHADOW_MEDIUM,
    offsetX: 0,
    offsetY: 8
  };
}

/**
 * 动画和过渡
 * 需求：9.5 - 视觉反馈
 */
export class ThemeAnimation {
  // Duration (milliseconds)
  static readonly DURATION_FAST = 150;
  static readonly DURATION_NORMAL = 300;
  static readonly DURATION_SLOW = 500;
  
  // Curves
  static readonly CURVE_EASE = Curve.Ease;
  static readonly CURVE_LINEAR = Curve.Linear;
  static readonly CURVE_EASE_IN = Curve.EaseIn;
  static readonly CURVE_EASE_OUT = Curve.EaseOut;
  static readonly CURVE_EASE_IN_OUT = Curve.EaseInOut;
  // 注释掉不存在的 Curve.Spring
  // static readonly CURVE_SPRING = Curve.Spring;
}

/**
 * 尺寸规范
 */
export class ThemeSizes {
  // Button heights
  static readonly BUTTON_HEIGHT_SM = 32;
  static readonly BUTTON_HEIGHT_MD = 40;
  static readonly BUTTON_HEIGHT_LG = 48;
  
  // Input heights
  static readonly INPUT_HEIGHT_SM = 32;
  static readonly INPUT_HEIGHT_MD = 40;
  static readonly INPUT_HEIGHT_LG = 48;
  
  // Icon sizes
  static readonly ICON_XS = 16;
  static readonly ICON_SM = 20;
  static readonly ICON_MD = 24;
  static readonly ICON_LG = 32;
  static readonly ICON_XL = 40;
  
  // Avatar sizes
  static readonly AVATAR_SM = 32;
  static readonly AVATAR_MD = 40;
  static readonly AVATAR_LG = 48;
  static readonly AVATAR_XL = 64;
  
  // Touch target minimum size (accessibility)
  static readonly TOUCH_TARGET_MIN = 48;
}

/**
 * Z-Index 层级
 */
export class ThemeZIndex {
  static readonly BASE = 0;
  static readonly DROPDOWN = 1000;
  static readonly STICKY = 1020;
  static readonly FIXED = 1030;
  static readonly MODAL_BACKDROP = 1040;
  static readonly MODAL = 1050;
  static readonly POPOVER = 1060;
  static readonly TOOLTIP = 1070;
  static readonly NOTIFICATION = 1080;
}
