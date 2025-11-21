/**
 * InputStyles - 输入框样式工具类
 * 提供一致的输入框样式
 * 需求：9.4, 9.5, 9.6
 */

import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeSizes, ThemeTypography } from './ThemeConstants';

/**
 * 输入框样式配置
 */
export interface InputStyleConfig {
  backgroundColor: string | Color;
  borderColor: string | Color;
  borderWidth: number;
  borderRadius: number;
  height: number;
  padding: number;
  fontSize: number;
  fontColor: string | Color;
  placeholderColor: string | Color;
  focusBorderColor?: string | Color;
  errorBorderColor?: string | Color;
  disabledBackgroundColor?: string | Color;
  disabledFontColor?: string | Color;
}

/**
 * 输入框尺寸枚举
 */
export enum InputSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

/**
 * 输入框状态枚举
 */
export enum InputState {
  NORMAL = 'normal',
  FOCUS = 'focus',
  ERROR = 'error',
  DISABLED = 'disabled'
}

/**
 * 输入框样式工具类
 */
export class InputStyles {
  /**
   * 获取输入框样式配置
   * 需求：9.4 - 输入框样式
   */
  static getInputStyle(size: InputSize = InputSize.MEDIUM, state: InputState = InputState.NORMAL): InputStyleConfig {
    const baseConfig = this.getBaseStyle();
    const sizeConfig = this.getSizeConfig(size);
    const stateConfig = this.getStateConfig(state);
    
    return {
      ...baseConfig,
      ...sizeConfig,
      ...stateConfig
    };
  }
  
  /**
   * 获取基础样式
   */
  private static getBaseStyle(): InputStyleConfig {
    return {
      backgroundColor: ThemeColors.BG_PRIMARY,
      borderColor: ThemeColors.BORDER_PRIMARY,
      borderWidth: 1,
      borderRadius: ThemeBorderRadius.INPUT,
      height: ThemeSizes.INPUT_HEIGHT_MD,
      padding: ThemeSpacing.INPUT_PADDING,
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_PRIMARY,
      placeholderColor: ThemeColors.TEXT_PLACEHOLDER,
      focusBorderColor: ThemeColors.PRIMARY,
      errorBorderColor: ThemeColors.ERROR,
      disabledBackgroundColor: ThemeColors.BG_DISABLED,
      disabledFontColor: ThemeColors.TEXT_DISABLED
    };
  }
  
  /**
   * 获取尺寸配置
   */
  private static getSizeConfig(size: InputSize): Partial<InputStyleConfig> {
    switch (size) {
      case InputSize.SMALL:
        return {
          height: ThemeSizes.INPUT_HEIGHT_SM,
          padding: ThemeSpacing.XS,
          fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL
        };
      
      case InputSize.MEDIUM:
        return {
          height: ThemeSizes.INPUT_HEIGHT_MD,
          padding: ThemeSpacing.INPUT_PADDING,
          fontSize: ThemeTypography.FONT_SIZE_BODY
        };
      
      case InputSize.LARGE:
        return {
          height: ThemeSizes.INPUT_HEIGHT_LG,
          padding: ThemeSpacing.MD,
          fontSize: ThemeTypography.FONT_SIZE_SUBTITLE
        };
      
      default:
        return this.getSizeConfig(InputSize.MEDIUM);
    }
  }
  
  /**
   * 获取状态配置
   */
  private static getStateConfig(state: InputState): Partial<InputStyleConfig> {
    switch (state) {
      case InputState.NORMAL:
        return {
          borderColor: ThemeColors.BORDER_PRIMARY
        };
      
      case InputState.FOCUS:
        return {
          borderColor: ThemeColors.PRIMARY
        };
      
      case InputState.ERROR:
        return {
          borderColor: ThemeColors.ERROR
        };
      
      case InputState.DISABLED:
        return {
          backgroundColor: ThemeColors.BG_DISABLED,
          fontColor: ThemeColors.TEXT_DISABLED,
          borderColor: ThemeColors.BORDER_SECONDARY
        };
      
      default:
        return this.getStateConfig(InputState.NORMAL);
    }
  }
  
  /**
   * 获取文本域样式
   */
  static getTextAreaStyle(minHeight: number = 100): Partial<InputStyleConfig> {
    return {
      ...this.getBaseStyle(),
      height: minHeight
    };
  }
  
  /**
   * 获取搜索框样式
   */
  static getSearchInputStyle(): InputStyleConfig {
    return {
      ...this.getBaseStyle(),
      borderRadius: ThemeBorderRadius.XXL,
      backgroundColor: ThemeColors.BG_SECONDARY
    };
  }
}

/**
 * 表单标签样式
 */
export class FormLabelStyles {
  /**
   * 获取表单标签样式
   */
  static getLabelStyle(required: boolean = false): any {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      fontColor: ThemeColors.TEXT_SECONDARY,
      marginBottom: ThemeSpacing.XS
    };
  }
  
  /**
   * 获取必填标记样式
   */
  static getRequiredMarkStyle(): any {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      fontColor: ThemeColors.ERROR
    };
  }
  
  /**
   * 获取错误提示样式
   */
  static getErrorMessageStyle(): any {
    return {
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      fontColor: ThemeColors.ERROR,
      marginTop: ThemeSpacing.XXS
    };
  }
  
  /**
   * 获取帮助文本样式
   */
  static getHelpTextStyle(): any {
    return {
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      fontColor: ThemeColors.TEXT_TERTIARY,
      marginTop: ThemeSpacing.XXS
    };
  }
}
