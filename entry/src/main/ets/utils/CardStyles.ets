/**
 * CardStyles - 卡片样式工具类
 * 提供一致的卡片样式
 * 需求：9.4, 9.6
 */

import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeShadow } from './ThemeConstants';

/**
 * 卡片样式配置
 */
export interface CardStyleConfig {
  backgroundColor: string | Color;
  borderRadius: number;
  padding: number;
  margin?: number;
  shadow?: any;
  borderColor?: string;
  borderWidth?: number;
}

/**
 * 卡片类型枚举
 */
export enum CardType {
  DEFAULT = 'default',       // 默认卡片
  ELEVATED = 'elevated',     // 带阴影的卡片
  OUTLINED = 'outlined',     // 带边框的卡片
  FLAT = 'flat'              // 扁平卡片（无阴影无边框）
}

/**
 * 卡片样式工具类
 */
export class CardStyles {
  /**
   * 获取卡片样式配置
   * 需求：9.4 - 卡片样式
   */
  static getCardStyle(type: CardType = CardType.DEFAULT): CardStyleConfig {
    switch (type) {
      case CardType.DEFAULT:
        return {
          backgroundColor: ThemeColors.BG_PRIMARY,
          borderRadius: ThemeBorderRadius.CARD,
          padding: ThemeSpacing.CARD_PADDING,
          shadow: ThemeShadow.SM
        };
      
      case CardType.ELEVATED:
        return {
          backgroundColor: ThemeColors.BG_PRIMARY,
          borderRadius: ThemeBorderRadius.CARD,
          padding: ThemeSpacing.CARD_PADDING,
          shadow: ThemeShadow.MD
        };
      
      case CardType.OUTLINED:
        return {
          backgroundColor: ThemeColors.BG_PRIMARY,
          borderRadius: ThemeBorderRadius.CARD,
          padding: ThemeSpacing.CARD_PADDING,
          borderColor: ThemeColors.BORDER_SECONDARY,
          borderWidth: 1
        };
      
      case CardType.FLAT:
        return {
          backgroundColor: ThemeColors.BG_PRIMARY,
          borderRadius: ThemeBorderRadius.CARD,
          padding: ThemeSpacing.CARD_PADDING
        };
      
      default:
        return this.getCardStyle(CardType.DEFAULT);
    }
  }
  
  /**
   * 获取汇总卡片样式（用于显示统计数据）
   */
  static getSummaryCardStyle(): CardStyleConfig {
    return {
      backgroundColor: ThemeColors.BG_PRIMARY,
      borderRadius: ThemeBorderRadius.CARD,
      padding: ThemeSpacing.MD,
      shadow: ThemeShadow.SM
    };
  }
  
  /**
   * 获取列表项卡片样式
   */
  static getListItemCardStyle(): CardStyleConfig {
    return {
      backgroundColor: ThemeColors.BG_PRIMARY,
      borderRadius: ThemeBorderRadius.MD,
      padding: ThemeSpacing.MD,
      margin: ThemeSpacing.XS
    };
  }
  
  /**
   * 获取信息卡片样式（带颜色背景）
   */
  static getInfoCardStyle(type: 'info' | 'success' | 'warning' | 'error' = 'info'): CardStyleConfig {
    let backgroundColor: string;
    
    switch (type) {
      case 'info':
        backgroundColor = ThemeColors.INFO_LIGHTEST;
        break;
      case 'success':
        backgroundColor = ThemeColors.SUCCESS_LIGHTEST;
        break;
      case 'warning':
        backgroundColor = ThemeColors.WARNING_LIGHTEST;
        break;
      case 'error':
        backgroundColor = ThemeColors.ERROR_LIGHTEST;
        break;
      default:
        backgroundColor = ThemeColors.INFO_LIGHTEST;
    }
    
    return {
      backgroundColor: backgroundColor,
      borderRadius: ThemeBorderRadius.CARD,
      padding: ThemeSpacing.MD
    };
  }
}

/**
 * 容器样式工具类
 */
export class ContainerStyles {
  /**
   * 获取页面容器样式
   */
  static getPageContainer(): any {
    return {
      width: '100%',
      height: '100%',
      backgroundColor: ThemeColors.BG_TERTIARY
    };
  }
  
  /**
   * 获取内容容器样式
   */
  static getContentContainer(): any {
    return {
      width: '100%',
      padding: ThemeSpacing.PAGE_PADDING,
      backgroundColor: ThemeColors.BG_TERTIARY
    };
  }
  
  /**
   * 获取白色背景容器样式
   */
  static getWhiteContainer(): any {
    return {
      width: '100%',
      backgroundColor: ThemeColors.BG_PRIMARY
    };
  }
}
