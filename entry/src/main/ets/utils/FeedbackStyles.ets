/**
 * FeedbackStyles - 视觉反馈样式工具类
 * 提供加载状态、空状态、错误状态等视觉反馈样式
 * 需求：9.5 - 视觉反馈（加载状态）
 */

import { ThemeColors, ThemeSpacing, ThemeTypography, ThemeBorderRadius } from './ThemeConstants';

/**
 * 加载样式配置
 */
export interface LoadingStyleConfig {
  size: number;
  color: string | Color;
  backgroundColor?: string | Color;
}

/**
 * 空状态样式配置
 */
export interface EmptyStateConfig {
  iconSize: number;
  iconColor: string | Color;
  titleFontSize: number;
  titleColor: string | Color;
  descriptionFontSize: number;
  descriptionColor: string | Color;
}

/**
 * Toast 样式配置
 */
export interface ToastStyleConfig {
  backgroundColor: string | Color;
  fontColor: string | Color;
  fontSize: number;
  borderRadius: number;
  padding: number;
  minWidth: number;
  maxWidth: number;
}

/**
 * 骨架屏样式配置
 */
export interface SkeletonStyleConfig {
  backgroundColor: string | Color;
  borderRadius: number;
}

/**
 * 进度条样式配置
 */
export interface ProgressBarStyleConfig {
  color: string | Color;
  backgroundColor: string | Color;
  borderRadius: number;
}

/**
 * 徽章样式配置
 */
export interface BadgeStyleConfig {
  backgroundColor: string | Color;
  fontColor: string | Color;
  fontSize: number;
  borderRadius: number;
  padding: number;
  paddingH?: number;
}

/**
 * 点徽章样式配置
 */
export interface DotBadgeStyleConfig {
  width: number;
  height: number;
  backgroundColor: string | Color;
  borderRadius: number;
}

/**
 * 计数徽章样式配置
 */
export interface CountBadgeStyleConfig {
  minWidth: number;
  height: number;
  backgroundColor: string | Color;
  fontColor: string | Color;
  fontSize: number;
  borderRadius: number;
  padding: number;
}

/**
 * 标签样式配置
 */
export interface TagStyleConfig {
  backgroundColor: string | Color;
  fontColor: string | Color;
  borderColor: string | Color;
  borderWidth: number;
  fontSize: number;
  borderRadius: number;
  padding: number;
  paddingH: number;
}

/**
 * 视觉反馈样式工具类
 */
export class FeedbackStyles {
  /**
   * 获取加载指示器样式
   * 需求：9.5 - 加载状态
   */
  static getLoadingStyle(size: 'small' | 'medium' | 'large' = 'medium'): LoadingStyleConfig {
    let loadingSize: number;
    
    switch (size) {
      case 'small':
        loadingSize = 24;
        break;
      case 'medium':
        loadingSize = 48;
        break;
      case 'large':
        loadingSize = 64;
        break;
      default:
        loadingSize = 48;
    }
    
    return {
      size: loadingSize,
      color: ThemeColors.PRIMARY
    };
  }
  
  /**
   * 获取全屏加载样式
   */
  static getFullScreenLoadingStyle(): LoadingStyleConfig {
    return {
      size: 64,
      color: ThemeColors.PRIMARY,
      backgroundColor: ThemeColors.OVERLAY_LIGHT
    };
  }
  
  /**
   * 获取空状态样式
   */
  static getEmptyStateStyle(): EmptyStateConfig {
    return {
      iconSize: 64,
      iconColor: ThemeColors.TEXT_TERTIARY,
      titleFontSize: ThemeTypography.FONT_SIZE_BODY,
      titleColor: ThemeColors.TEXT_SECONDARY,
      descriptionFontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      descriptionColor: ThemeColors.TEXT_TERTIARY
    };
  }
  
  /**
   * 获取错误状态样式
   */
  static getErrorStateStyle(): EmptyStateConfig {
    return {
      iconSize: 64,
      iconColor: ThemeColors.ERROR,
      titleFontSize: ThemeTypography.FONT_SIZE_BODY,
      titleColor: ThemeColors.TEXT_PRIMARY,
      descriptionFontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      descriptionColor: ThemeColors.TEXT_SECONDARY
    };
  }
  
  /**
   * 获取 Toast 样式
   */
  static getToastStyle(type: 'success' | 'error' | 'warning' | 'info' = 'info'): ToastStyleConfig {
    let backgroundColor: string;
    
    switch (type) {
      case 'success':
        backgroundColor = ThemeColors.SUCCESS;
        break;
      case 'error':
        backgroundColor = ThemeColors.ERROR;
        break;
      case 'warning':
        backgroundColor = ThemeColors.WARNING;
        break;
      case 'info':
        backgroundColor = ThemeColors.PRIMARY;
        break;
      default:
        backgroundColor = ThemeColors.PRIMARY;
    }
    
    return {
      backgroundColor: backgroundColor,
      fontColor: Color.White,
      fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      borderRadius: ThemeBorderRadius.MD,
      padding: ThemeSpacing.MD,
      minWidth: 200,
      maxWidth: 300
    };
  }
  
  /**
   * 获取骨架屏样式
   */
  static getSkeletonStyle(): SkeletonStyleConfig {
    return {
      backgroundColor: ThemeColors.BG_SECONDARY,
      borderRadius: ThemeBorderRadius.SM
    };
  }
  
  /**
   * 获取进度条样式
   */
  static getProgressBarStyle(type: 'normal' | 'success' | 'warning' | 'error' = 'normal'): ProgressBarStyleConfig {
    let color: string;
    
    switch (type) {
      case 'success':
        color = ThemeColors.SUCCESS;
        break;
      case 'warning':
        color = ThemeColors.WARNING;
        break;
      case 'error':
        color = ThemeColors.ERROR;
        break;
      case 'normal':
      default:
        color = ThemeColors.PRIMARY;
    }
    
    return {
      color: color,
      backgroundColor: ThemeColors.BG_SECONDARY,
      borderRadius: ThemeBorderRadius.XL
    };
  }
}

/**
 * 按压效果样式
 * 需求：9.5 - 按压效果
 */
export class PressEffectStyles {
  /**
   * 获取按压透明度效果
   */
  static getPressOpacity(): number {
    return 0.6;
  }
  
  /**
   * 获取按压缩放效果
   */
  static getPressScale(): number {
    return 0.95;
  }
  
  /**
   * 获取按压背景色变化
   */
  static getPressBackgroundColor(originalColor: string): string {
    // 简单的颜色加深效果
    // 实际应用中可能需要更复杂的颜色处理
    return originalColor;
  }
}

/**
 * 徽章样式
 */
export class BadgeStyles {
  /**
   * 获取徽章样式
   */
  static getBadgeStyle(type: 'primary' | 'success' | 'warning' | 'error' | 'default' = 'default'): BadgeStyleConfig {
    let backgroundColor: string;
    let fontColor: string | Color;
    
    switch (type) {
      case 'primary':
        backgroundColor = ThemeColors.PRIMARY;
        fontColor = Color.White;
        break;
      case 'success':
        backgroundColor = ThemeColors.SUCCESS;
        fontColor = Color.White;
        break;
      case 'warning':
        backgroundColor = ThemeColors.WARNING;
        fontColor = Color.White;
        break;
      case 'error':
        backgroundColor = ThemeColors.ERROR;
        fontColor = Color.White;
        break;
      case 'default':
      default:
        backgroundColor = ThemeColors.BG_SECONDARY;
        fontColor = ThemeColors.TEXT_PRIMARY;
    }
    
    return {
      backgroundColor: backgroundColor,
      fontColor: fontColor,
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      borderRadius: ThemeBorderRadius.BADGE,
      padding: ThemeSpacing.XXS,
      paddingH: ThemeSpacing.XS
    };
  }
  
  /**
   * 获取数字徽章样式（小红点）
   */
  static getDotBadgeStyle(): DotBadgeStyleConfig {
    return {
      width: 8,
      height: 8,
      backgroundColor: ThemeColors.ERROR,
      borderRadius: ThemeBorderRadius.CIRCLE
    };
  }
  
  /**
   * 获取计数徽章样式
   */
  static getCountBadgeStyle(): CountBadgeStyleConfig {
    return {
      minWidth: 20,
      height: 20,
      backgroundColor: ThemeColors.ERROR,
      fontColor: Color.White,
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      borderRadius: ThemeBorderRadius.CIRCLE,
      padding: ThemeSpacing.XXS
    };
  }
}

/**
 * 标签样式
 */
export class TagStyles {
  /**
   * 获取标签样式
   */
  static getTagStyle(type: 'primary' | 'success' | 'warning' | 'error' | 'default' = 'default'): TagStyleConfig {
    let backgroundColor: string;
    let fontColor: string;
    let borderColor: string;
    
    switch (type) {
      case 'primary':
        backgroundColor = ThemeColors.PRIMARY_LIGHTEST;
        fontColor = ThemeColors.PRIMARY;
        borderColor = ThemeColors.PRIMARY_LIGHT;
        break;
      case 'success':
        backgroundColor = ThemeColors.SUCCESS_LIGHTEST;
        fontColor = ThemeColors.SUCCESS;
        borderColor = ThemeColors.SUCCESS_LIGHT;
        break;
      case 'warning':
        backgroundColor = ThemeColors.WARNING_LIGHTEST;
        fontColor = ThemeColors.WARNING;
        borderColor = ThemeColors.WARNING_LIGHT;
        break;
      case 'error':
        backgroundColor = ThemeColors.ERROR_LIGHTEST;
        fontColor = ThemeColors.ERROR;
        borderColor = ThemeColors.ERROR_LIGHT;
        break;
      case 'default':
      default:
        backgroundColor = ThemeColors.BG_SECONDARY;
        fontColor = ThemeColors.TEXT_PRIMARY;
        borderColor = ThemeColors.BORDER_SECONDARY;
    }
    
    return {
      backgroundColor: backgroundColor,
      fontColor: fontColor,
      borderColor: borderColor,
      borderWidth: 1,
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      borderRadius: ThemeBorderRadius.TAG,
      padding: ThemeSpacing.XXS,
      paddingH: ThemeSpacing.XS
    };
  }
}
