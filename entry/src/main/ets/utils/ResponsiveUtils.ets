/**
 * ResponsiveUtils - 响应式布局工具
 * 提供屏幕尺寸检测和响应式布局辅助功能
 * 需求：10.1, 10.2, 10.4, 10.5
 */

/**
 * 设备类型枚举
 */
export enum DeviceType {
  PHONE = 'phone',      // 手机
  TABLET = 'tablet',    // 平板
  DESKTOP = 'desktop'   // 桌面（未来扩展）
}

/**
 * 屏幕方向枚举
 */
export enum ScreenOrientation {
  PORTRAIT = 'portrait',    // 竖屏
  LANDSCAPE = 'landscape'   // 横屏
}

/**
 * 断点定义（单位：vp）
 */
export class Breakpoints {
  static readonly PHONE_MAX = 600;      // 手机最大宽度
  static readonly TABLET_MIN = 600;     // 平板最小宽度
  static readonly TABLET_MAX = 840;     // 平板最大宽度
  static readonly DESKTOP_MIN = 840;    // 桌面最小宽度
}

/**
 * 响应式布局配置
 */
export interface ResponsiveConfig {
  deviceType: DeviceType;
  orientation: ScreenOrientation;
  screenWidth: number;
  screenHeight: number;
  columns: number;           // 列数
  gutter: number;            // 间距
  margin: number;            // 边距
  useSidebar: boolean;       // 是否使用侧边栏
}

/**
 * 响应式工具类
 */
export class ResponsiveUtils {
  /**
   * 获取设备类型
   * 需求：10.1, 10.2
   */
  static getDeviceType(screenWidth: number): DeviceType {
    if (screenWidth < Breakpoints.TABLET_MIN) {
      return DeviceType.PHONE;
    } else if (screenWidth < Breakpoints.DESKTOP_MIN) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.DESKTOP;
    }
  }

  /**
   * 获取屏幕方向
   */
  static getOrientation(screenWidth: number, screenHeight: number): ScreenOrientation {
    return screenWidth > screenHeight ? ScreenOrientation.LANDSCAPE : ScreenOrientation.PORTRAIT;
  }

  /**
   * 判断是否为手机
   */
  static isPhone(screenWidth: number): boolean {
    return screenWidth < Breakpoints.TABLET_MIN;
  }

  /**
   * 判断是否为平板
   */
  static isTablet(screenWidth: number): boolean {
    return screenWidth >= Breakpoints.TABLET_MIN && screenWidth < Breakpoints.DESKTOP_MIN;
  }

  /**
   * 判断是否为横屏
   */
  static isLandscape(screenWidth: number, screenHeight: number): boolean {
    return screenWidth > screenHeight;
  }

  /**
   * 判断是否为竖屏
   */
  static isPortrait(screenWidth: number, screenHeight: number): boolean {
    return screenWidth <= screenHeight;
  }

  /**
   * 获取响应式配置
   * 需求：10.1, 10.2, 10.4, 10.5
   */
  static getResponsiveConfig(screenWidth: number, screenHeight: number): ResponsiveConfig {
    const deviceType = this.getDeviceType(screenWidth);
    const orientation = this.getOrientation(screenWidth, screenHeight);
    
    let columns: number;
    let gutter: number;
    let margin: number;
    let useSidebar: boolean;

    // 根据设备类型和方向配置布局参数
    if (deviceType === DeviceType.PHONE) {
      // 手机：单列布局
      columns = 1;
      gutter = 8;
      margin = 16;
      useSidebar = false;
    } else if (deviceType === DeviceType.TABLET) {
      // 平板：多列布局
      if (orientation === ScreenOrientation.PORTRAIT) {
        // 竖屏平板：2列
        columns = 2;
        gutter = 12;
        margin = 24;
        useSidebar = false;
      } else {
        // 横屏平板：3列或使用侧边栏
        columns = 3;
        gutter = 16;
        margin = 32;
        useSidebar = true;
      }
    } else {
      // 桌面：多列布局 + 侧边栏
      columns = 4;
      gutter = 16;
      margin = 32;
      useSidebar = true;
    }

    return {
      deviceType,
      orientation,
      screenWidth,
      screenHeight,
      columns,
      gutter,
      margin,
      useSidebar
    };
  }

  /**
   * 获取列宽度
   * 需求：10.1, 10.2
   */
  static getColumnWidth(screenWidth: number, columns: number, gutter: number, margin: number): number {
    const totalGutter = gutter * (columns - 1);
    const totalMargin = margin * 2;
    const availableWidth = screenWidth - totalGutter - totalMargin;
    return availableWidth / columns;
  }

  /**
   * 获取图表尺寸
   * 需求：10.4
   */
  static getChartSize(screenWidth: number, screenHeight: number): { width: number, height: number } {
    const deviceType = this.getDeviceType(screenWidth);
    const orientation = this.getOrientation(screenWidth, screenHeight);
    
    let width: number;
    let height: number;

    if (deviceType === DeviceType.PHONE) {
      // 手机：占满宽度，固定高度比例
      width = screenWidth - 32; // 减去边距
      height = Math.min(width * 0.8, 300);
    } else if (deviceType === DeviceType.TABLET) {
      // 平板：根据方向调整
      if (orientation === ScreenOrientation.PORTRAIT) {
        width = screenWidth - 48;
        height = Math.min(width * 0.7, 400);
      } else {
        width = (screenWidth - 64) * 0.6; // 横屏时占60%宽度
        height = Math.min(width * 0.75, 450);
      }
    } else {
      // 桌面：固定较大尺寸
      width = 500;
      height = 400;
    }

    return { width, height };
  }

  /**
   * 获取卡片宽度
   * 用于网格布局中的卡片
   */
  static getCardWidth(screenWidth: number, config: ResponsiveConfig): string {
    if (config.columns === 1) {
      return '100%';
    }
    
    const columnWidth = this.getColumnWidth(
      screenWidth,
      config.columns,
      config.gutter,
      config.margin
    );
    
    return `${columnWidth}vp`;
  }

  /**
   * 获取侧边栏宽度
   * 需求：10.5
   */
  static getSidebarWidth(screenWidth: number): number {
    const deviceType = this.getDeviceType(screenWidth);
    
    if (deviceType === DeviceType.PHONE) {
      return 0; // 手机不显示侧边栏
    } else if (deviceType === DeviceType.TABLET) {
      return 240; // 平板侧边栏
    } else {
      return 280; // 桌面侧边栏
    }
  }

  /**
   * 获取字体大小缩放比例
   * 根据屏幕尺寸调整字体
   */
  static getFontScale(screenWidth: number): number {
    const deviceType = this.getDeviceType(screenWidth);
    
    if (deviceType === DeviceType.PHONE) {
      return 1.0;
    } else if (deviceType === DeviceType.TABLET) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /**
   * 获取间距缩放比例
   */
  static getSpacingScale(screenWidth: number): number {
    const deviceType = this.getDeviceType(screenWidth);
    
    if (deviceType === DeviceType.PHONE) {
      return 1.0;
    } else if (deviceType === DeviceType.TABLET) {
      return 1.25;
    } else {
      return 1.5;
    }
  }

  /**
   * 计算响应式值
   * 根据设备类型返回不同的值
   */
  static responsive<T>(screenWidth: number, values: {
    phone: T,
    tablet?: T,
    desktop?: T
  }): T {
    const deviceType = this.getDeviceType(screenWidth);
    
    if (deviceType === DeviceType.PHONE) {
      return values.phone;
    } else if (deviceType === DeviceType.TABLET) {
      return values.tablet ?? values.phone;
    } else {
      return values.desktop ?? values.tablet ?? values.phone;
    }
  }

  /**
   * 获取网格列数
   * 用于列表和网格布局
   */
  static getGridColumns(screenWidth: number, screenHeight: number): number {
    const config = this.getResponsiveConfig(screenWidth, screenHeight);
    return config.columns;
  }

  /**
   * 判断是否应该使用紧凑布局
   */
  static shouldUseCompactLayout(screenWidth: number): boolean {
    return screenWidth < Breakpoints.TABLET_MIN;
  }

  /**
   * 获取列表项高度
   */
  static getListItemHeight(screenWidth: number): number {
    return this.responsive(screenWidth, {
      phone: 80,
      tablet: 90,
      desktop: 100
    });
  }

  /**
   * 获取按钮尺寸
   */
  static getButtonSize(screenWidth: number): { width: number, height: number } {
    const scale = this.getSpacingScale(screenWidth);
    return {
      width: 48 * scale,
      height: 48 * scale
    };
  }
}
