/**
 * ButtonStyles - 按钮样式工具类
 * 提供一致的按钮样式（主要、次要、危险）
 * 需求：9.4, 9.5, 9.6
 */

import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeSizes, ThemeAnimation } from './ThemeConstants';

/**
 * 按钮类型枚举
 */
export enum ButtonStyleType {
  PRIMARY = 'primary',       // 主要按钮
  SECONDARY = 'secondary',   // 次要按钮
  DANGER = 'danger',         // 危险按钮
  SUCCESS = 'success',       // 成功按钮
  WARNING = 'warning',       // 警告按钮
  TEXT = 'text',             // 文本按钮
  LINK = 'link'              // 链接按钮
}

/**
 * 按钮尺寸枚举
 */
export enum ButtonSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

/**
 * 按钮样式配置
 */
export interface ButtonStyleConfig {
  backgroundColor: string | Color;
  fontColor: string | Color;
  borderColor?: string | Color;
  borderWidth?: number;
  height: number;
  paddingH: number;
  fontSize: number;
  borderRadius: number;
  pressedBackgroundColor?: string | Color;
  pressedFontColor?: string | Color;
  disabledBackgroundColor?: string | Color;
  disabledFontColor?: string | Color;
}

/**
 * 按钮样式工具类
 */
export class ButtonStyles {
  /**
   * 获取按钮样式配置
   * 需求：9.4 - 按钮样式（主要、次要、危险）
   */
  static getButtonStyle(type: ButtonStyleType, size: ButtonSize = ButtonSize.MEDIUM): ButtonStyleConfig {
    const baseConfig = this.getBaseStyleByType(type);
    const sizeConfig = this.getSizeConfig(size);
    
    return {
      ...baseConfig,
      ...sizeConfig
    };
  }
  
  /**
   * 获取基础样式（按类型）
   */
  private static getBaseStyleByType(type: ButtonStyleType): Partial<ButtonStyleConfig> {
    switch (type) {
      case ButtonStyleType.PRIMARY:
        return {
          backgroundColor: ThemeColors.PRIMARY,
          fontColor: Color.White,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: ThemeColors.PRIMARY_DARK,
          pressedFontColor: Color.White,
          disabledBackgroundColor: ThemeColors.BG_DISABLED,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.SECONDARY:
        return {
          backgroundColor: Color.White,
          fontColor: ThemeColors.TEXT_PRIMARY,
          borderColor: ThemeColors.BORDER_PRIMARY,
          borderWidth: 1,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: ThemeColors.BG_TERTIARY,
          pressedFontColor: ThemeColors.TEXT_PRIMARY,
          disabledBackgroundColor: ThemeColors.BG_DISABLED,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.DANGER:
        return {
          backgroundColor: ThemeColors.DANGER,
          fontColor: Color.White,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: '#D9363E',
          pressedFontColor: Color.White,
          disabledBackgroundColor: ThemeColors.BG_DISABLED,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.SUCCESS:
        return {
          backgroundColor: ThemeColors.SUCCESS,
          fontColor: Color.White,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: '#389E0D',
          pressedFontColor: Color.White,
          disabledBackgroundColor: ThemeColors.BG_DISABLED,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.WARNING:
        return {
          backgroundColor: ThemeColors.WARNING,
          fontColor: Color.White,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: '#D48806',
          pressedFontColor: Color.White,
          disabledBackgroundColor: ThemeColors.BG_DISABLED,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.TEXT:
        return {
          backgroundColor: Color.Transparent,
          fontColor: ThemeColors.PRIMARY,
          borderRadius: ThemeBorderRadius.BUTTON,
          pressedBackgroundColor: ThemeColors.PRIMARY_LIGHTEST,
          pressedFontColor: ThemeColors.PRIMARY_DARK,
          disabledBackgroundColor: Color.Transparent,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      case ButtonStyleType.LINK:
        return {
          backgroundColor: Color.Transparent,
          fontColor: ThemeColors.PRIMARY,
          borderRadius: 0,
          pressedBackgroundColor: Color.Transparent,
          pressedFontColor: ThemeColors.PRIMARY_DARK,
          disabledBackgroundColor: Color.Transparent,
          disabledFontColor: ThemeColors.TEXT_DISABLED
        };
      
      default:
        return this.getBaseStyleByType(ButtonStyleType.PRIMARY);
    }
  }
  
  /**
   * 获取尺寸配置
   */
  private static getSizeConfig(size: ButtonSize): Partial<ButtonStyleConfig> {
    switch (size) {
      case ButtonSize.SMALL:
        return {
          height: ThemeSizes.BUTTON_HEIGHT_SM,
          paddingH: ThemeSpacing.SM,
          fontSize: 14
        };
      
      case ButtonSize.MEDIUM:
        return {
          height: ThemeSizes.BUTTON_HEIGHT_MD,
          paddingH: ThemeSpacing.MD,
          fontSize: 16
        };
      
      case ButtonSize.LARGE:
        return {
          height: ThemeSizes.BUTTON_HEIGHT_LG,
          paddingH: ThemeSpacing.LG,
          fontSize: 18
        };
      
      default:
        return this.getSizeConfig(ButtonSize.MEDIUM);
    }
  }
  
  /**
   * 应用按钮样式到 Button 组件
   * 需求：9.5 - 视觉反馈（按压效果）
   * 
   * 使用示例：
   * Button('确定')
   *   .width(120)
   *   .height(config.height)
   *   .backgroundColor(config.backgroundColor)
   *   .fontColor(config.fontColor)
   *   .fontSize(config.fontSize)
   *   .borderRadius(config.borderRadius)
   *   .stateEffect(true)
   */
  static applyButtonStyle(button: any, config: ButtonStyleConfig): any {
    return button
      .height(config.height)
      .padding({ left: config.paddingH, right: config.paddingH })
      .backgroundColor(config.backgroundColor)
      .fontColor(config.fontColor)
      .fontSize(config.fontSize)
      .borderRadius(config.borderRadius)
      .stateEffect(true);
  }
}

/**
 * 图标按钮样式
 */
export class IconButtonStyles {
  /**
   * 获取圆形图标按钮样式
   */
  static getCircleIconButton(size: number = 48, backgroundColor: string = ThemeColors.BG_SECONDARY): any {
    return {
      width: size,
      height: size,
      backgroundColor: backgroundColor,
      borderRadius: size / 2
    };
  }
  
  /**
   * 获取方形图标按钮样式
   */
  static getSquareIconButton(size: number = 48, backgroundColor: string = ThemeColors.BG_SECONDARY): any {
    return {
      width: size,
      height: size,
      backgroundColor: backgroundColor,
      borderRadius: ThemeBorderRadius.BUTTON
    };
  }
}
