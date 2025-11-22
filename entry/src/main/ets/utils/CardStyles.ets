/**
 * CardStyles - 卡片样式工具类
 * 提供一致的卡片样式
 * 需求：9.4, 9.6
 */

import { ThemeColors, ThemeSpacing, ThemeBorderRadius, ThemeShadow } from './ThemeConstants';

/**
 * 阴影样式配置
 */
export class ShadowStyle {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;

  constructor(radius: number, color: string, offsetX: number, offsetY: number) {
    this.radius = radius;
    this.color = color;
    this.offsetX = offsetX;
    this.offsetY = offsetY;
  }
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
 * 卡片样式配置类
 */
export class CardStyleConfig {
  backgroundColor: string | Color = ThemeColors.BG_PRIMARY;
  borderRadius: number = ThemeBorderRadius.CARD;
  padding: number = ThemeSpacing.CARD_PADDING;
  margin: number = 0;
  shadow: ShadowStyle | null = null;
  borderColor: string | null = null;
  borderWidth: number = 0;
}

/**
 * 容器样式配置类
 */
export class ContainerStyleConfig {
  width: string = '100%';
  height: string = '100%';
  padding: number = 0;
  backgroundColor: string | Color = ThemeColors.BG_TERTIARY;
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
    const config = new CardStyleConfig();

    switch (type) {
      case CardType.DEFAULT:
        config.shadow = ThemeShadow.SM;
        break;

      case CardType.ELEVATED:
        config.shadow = ThemeShadow.MD;
        break;

      case CardType.OUTLINED:
        config.borderColor = ThemeColors.BORDER_SECONDARY;
        config.borderWidth = 1;
        break;

      case CardType.FLAT:
        // 使用默认值
        break;

      default:
        return CardStyles.getCardStyle(CardType.DEFAULT);
    }

    return config;
  }

  /**
   * 获取汇总卡片样式（用于显示统计数据）
   */
  static getSummaryCardStyle(): CardStyleConfig {
    const config = new CardStyleConfig();
    config.padding = ThemeSpacing.MD;
    config.shadow = ThemeShadow.SM;
    return config;
  }

  /**
   * 获取列表项卡片样式
   */
  static getListItemCardStyle(): CardStyleConfig {
    const config = new CardStyleConfig();
    config.borderRadius = ThemeBorderRadius.MD;
    config.padding = ThemeSpacing.MD;
    config.margin = ThemeSpacing.XS;
    return config;
  }

  /**
   * 获取信息卡片样式（带颜色背景）
   */
  static getInfoCardStyle(type: 'info' | 'success' | 'warning' | 'error' = 'info'): CardStyleConfig {
    const config = new CardStyleConfig();

    switch (type) {
      case 'info':
        config.backgroundColor = ThemeColors.INFO_LIGHTEST;
        break;
      case 'success':
        config.backgroundColor = ThemeColors.SUCCESS_LIGHTEST;
        break;
      case 'warning':
        config.backgroundColor = ThemeColors.WARNING_LIGHTEST;
        break;
      case 'error':
        config.backgroundColor = ThemeColors.ERROR_LIGHTEST;
        break;
      default:
        config.backgroundColor = ThemeColors.INFO_LIGHTEST;
    }

    config.padding = ThemeSpacing.MD;
    return config;
  }
}

/**
 * 容器样式工具类
 */
export class ContainerStyles {
  /**
   * 获取页面容器样式
   */
  static getPageContainer(): ContainerStyleConfig {
    return new ContainerStyleConfig();
  }

  /**
   * 获取内容容器样式
   */
  static getContentContainer(): ContainerStyleConfig {
    const config = new ContainerStyleConfig();
    config.padding = ThemeSpacing.PAGE_PADDING;
    return config;
  }

  /**
   * 获取白色背景容器样式
   */
  static getWhiteContainer(): ContainerStyleConfig {
    const config = new ContainerStyleConfig();
    config.backgroundColor = ThemeColors.BG_PRIMARY;
    return config;
  }
}