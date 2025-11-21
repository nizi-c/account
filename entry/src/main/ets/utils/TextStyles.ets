/**
 * TextStyles - 文本样式工具类
 * 提供一致的文本样式和排版规范
 * 需求：9.6 - 一致的字体和排版
 */

import { ThemeColors, ThemeTypography } from './ThemeConstants';

/**
 * 文本样式配置
 */
export interface TextStyleConfig {
  fontSize: number;
  fontColor: string | Color;
  fontWeight?: FontWeight;
  lineHeight?: number;
}

/**
 * 文本样式工具类
 */
export class TextStyles {
  /**
   * 标题样式
   */
  static getH1Style(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_HUGE,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_BOLD
    };
  }
  
  static getH2Style(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_XLARGE,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_BOLD
    };
  }
  
  static getH3Style(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_LARGE,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_BOLD
    };
  }
  
  static getH4Style(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_TITLE,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_MEDIUM
    };
  }
  
  static getH5Style(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_SUBTITLE,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_MEDIUM
    };
  }
  
  /**
   * 正文样式
   */
  static getBodyStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR,
      lineHeight: ThemeTypography.LINE_HEIGHT_NORMAL
    };
  }
  
  static getBodySmallStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR,
      lineHeight: ThemeTypography.LINE_HEIGHT_NORMAL
    };
  }
  
  /**
   * 次要文本样式
   */
  static getSecondaryStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_SECONDARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  static getSecondarySmallStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY_SMALL,
      fontColor: ThemeColors.TEXT_SECONDARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 说明文字样式
   */
  static getCaptionStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      fontColor: ThemeColors.TEXT_TERTIARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 链接样式
   */
  static getLinkStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 强调文本样式
   */
  static getEmphasisStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_BOLD
    };
  }
  
  /**
   * 禁用文本样式
   */
  static getDisabledStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_DISABLED,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 占位符文本样式
   */
  static getPlaceholderStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_BODY,
      fontColor: ThemeColors.TEXT_PLACEHOLDER,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 金额文本样式
   */
  static getAmountStyle(isPositive: boolean = true, size: 'small' | 'medium' | 'large' = 'medium'): TextStyleConfig {
    let fontSize: number;
    
    switch (size) {
      case 'small':
        fontSize = ThemeTypography.FONT_SIZE_BODY_SMALL;
        break;
      case 'medium':
        fontSize = ThemeTypography.FONT_SIZE_TITLE;
        break;
      case 'large':
        fontSize = ThemeTypography.FONT_SIZE_XLARGE;
        break;
      default:
        fontSize = ThemeTypography.FONT_SIZE_TITLE;
    }
    
    return {
      fontSize: fontSize,
      fontColor: isPositive ? ThemeColors.SUCCESS : ThemeColors.ERROR,
      fontWeight: ThemeTypography.FONT_WEIGHT_BOLD
    };
  }
  
  /**
   * 收入文本样式
   */
  static getIncomeStyle(size: 'small' | 'medium' | 'large' = 'medium'): TextStyleConfig {
    return this.getAmountStyle(true, size);
  }
  
  /**
   * 支出文本样式
   */
  static getExpenseStyle(size: 'small' | 'medium' | 'large' = 'medium'): TextStyleConfig {
    return this.getAmountStyle(false, size);
  }
  
  /**
   * 标签文本样式
   */
  static getTagStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      fontColor: ThemeColors.TEXT_PRIMARY,
      fontWeight: ThemeTypography.FONT_WEIGHT_REGULAR
    };
  }
  
  /**
   * 徽章文本样式
   */
  static getBadgeStyle(): TextStyleConfig {
    return {
      fontSize: ThemeTypography.FONT_SIZE_CAPTION,
      fontColor: Color.White,
      fontWeight: ThemeTypography.FONT_WEIGHT_MEDIUM
    };
  }
}

/**
 * 应用文本样式的辅助函数
 */
export class TextStyleHelper {
  /**
   * 应用样式到 Text 组件
   */
  static applyStyle(text: any, config: TextStyleConfig): any {
    let styledText = text
      .fontSize(config.fontSize)
      .fontColor(config.fontColor);
    
    if (config.fontWeight) {
      styledText = styledText.fontWeight(config.fontWeight);
    }
    
    if (config.lineHeight) {
      styledText = styledText.lineHeight(config.lineHeight);
    }
    
    return styledText;
  }
}
