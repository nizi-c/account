/**
 * Toast Component
 * Toast提示组件
 * 
 * 提供统一的消息提示功能
 */

import promptAction from '@ohos.promptAction';

/**
 * Toast类型
 */
export enum ToastType {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info'
}

/**
 * Toast配置
 */
export interface ToastConfig {
  message: string;
  type?: ToastType;
  duration?: number;  // 毫秒
  bottom?: number;    // 距离底部的距离
}

/**
 * Toast工具类
 */
export class Toast {
  private static readonly DEFAULT_DURATION = 2000;
  private static readonly DEFAULT_BOTTOM = 100;

  /**
   * 显示成功提示
   */
  static success(message: string, duration?: number): void {
    this.show({
      message: `✓ ${message}`,
      type: ToastType.SUCCESS,
      duration
    });
  }

  /**
   * 显示错误提示
   */
  static error(message: string, duration?: number): void {
    this.show({
      message: `✗ ${message}`,
      type: ToastType.ERROR,
      duration
    });
  }

  /**
   * 显示警告提示
   */
  static warning(message: string, duration?: number): void {
    this.show({
      message: `⚠ ${message}`,
      type: ToastType.WARNING,
      duration
    });
  }

  /**
   * 显示信息提示
   */
  static info(message: string, duration?: number): void {
    this.show({
      message: `ℹ ${message}`,
      type: ToastType.INFO,
      duration
    });
  }

  /**
   * 显示Toast
   */
  static show(config: ToastConfig): void {
    promptAction.showToast({
      message: config.message,
      duration: config.duration || this.DEFAULT_DURATION,
      bottom: config.bottom || this.DEFAULT_BOTTOM
    });
  }
}
