/**
 * Global Error Handler
 * 全局错误处理器
 * 
 * 处理应用中的各种错误类型并提供统一的错误处理机制
 */

import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';

/**
 * 错误类型枚举
 */
export enum ErrorType {
  VALIDATION = 'validation',           // 输入验证错误
  DATABASE = 'database',               // 数据库操作错误
  NETWORK = 'network',                 // 网络错误
  DATA_INCONSISTENCY = 'data_inconsistency', // 数据不一致错误
  UNKNOWN = 'unknown'                  // 未知错误
}

/**
 * 应用错误类
 */
export class AppError extends Error {
  type: ErrorType;
  code?: string;
  details?: any;
  recoverable: boolean;

  constructor(
    message: string,
    type: ErrorType = ErrorType.UNKNOWN,
    code?: string,
    details?: any,
    recoverable: boolean = true
  ) {
    super(message);
    this.name = 'AppError';
    this.type = type;
    this.code = code;
    this.details = details;
    this.recoverable = recoverable;
  }
}

/**
 * 错误处理器类
 */
export class ErrorHandler {
  private static readonly DOMAIN = 0x0001;
  private static readonly TAG = 'ErrorHandler';

  /**
   * 处理错误
   */
  static handle(error: Error | AppError, showToUser: boolean = true): void {
    // 记录错误日志
    this.logError(error);

    // 如果需要显示给用户
    if (showToUser) {
      const userMessage = this.getUserMessage(error);
      this.showErrorToast(userMessage);
    }
  }

  /**
   * 处理数据库错误
   */
  static handleDatabaseError(error: Error, operation: string): AppError {
    const appError = new AppError(
      `数据库操作失败: ${operation}`,
      ErrorType.DATABASE,
      'DB_ERROR',
      { originalError: error.message, operation },
      true
    );
    
    this.handle(appError);
    return appError;
  }

  /**
   * 处理验证错误
   */
  static handleValidationError(message: string, field?: string): AppError {
    const appError = new AppError(
      message,
      ErrorType.VALIDATION,
      'VALIDATION_ERROR',
      { field },
      true
    );
    
    this.handle(appError);
    return appError;
  }

  /**
   * 处理数据不一致错误
   */
  static handleDataInconsistencyError(message: string, details?: any): AppError {
    const appError = new AppError(
      message,
      ErrorType.DATA_INCONSISTENCY,
      'DATA_INCONSISTENCY',
      details,
      false
    );
    
    this.handle(appError);
    return appError;
  }

  /**
   * 记录错误日志
   */
  private static logError(error: Error | AppError): void {
    if (error instanceof AppError) {
      hilog.error(this.DOMAIN, this.TAG, 
        `[${error.type}] ${error.message} | Code: ${error.code} | Details: ${JSON.stringify(error.details)}`
      );
    } else {
      hilog.error(this.DOMAIN, this.TAG, 
        `[UNKNOWN] ${error.message} | Stack: ${error.stack}`
      );
    }
  }

  /**
   * 获取用户友好的错误消息
   */
  private static getUserMessage(error: Error | AppError): string {
    if (error instanceof AppError) {
      switch (error.type) {
        case ErrorType.VALIDATION:
          return error.message;
        case ErrorType.DATABASE:
          return '数据保存失败，请稍后重试';
        case ErrorType.NETWORK:
          return '网络连接失败，请检查网络设置';
        case ErrorType.DATA_INCONSISTENCY:
          return '数据异常，请联系技术支持';
        default:
          return '操作失败，请稍后重试';
      }
    }
    return '发生未知错误，请稍后重试';
  }

  /**
   * 显示错误提示
   */
  private static showErrorToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: 100
    });
  }

  /**
   * 包装异步操作，自动处理错误
   */
  static async wrapAsync<T>(
    operation: () => Promise<T>,
    errorMessage?: string,
    showToUser: boolean = true
  ): Promise<T | null> {
    try {
      return await operation();
    } catch (error) {
      const appError = new AppError(
        errorMessage || '操作失败',
        ErrorType.UNKNOWN,
        undefined,
        { originalError: error },
        true
      );
      this.handle(appError, showToUser);
      return null;
    }
  }

  /**
   * 包装同步操作，自动处理错误
   */
  static wrapSync<T>(
    operation: () => T,
    errorMessage?: string,
    showToUser: boolean = true
  ): T | null {
    try {
      return operation();
    } catch (error) {
      const appError = new AppError(
        errorMessage || '操作失败',
        ErrorType.UNKNOWN,
        undefined,
        { originalError: error },
        true
      );
      this.handle(appError, showToUser);
      return null;
    }
  }
}
