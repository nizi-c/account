/**
 * Error Handling Demo Page
 * 错误处理演示页面
 * 
 * 展示所有错误处理和用户反馈组件的使用方法
 */

import { 
  ErrorDisplay, 
  EmptyState, 
  InlineError, 
  ErrorPage,
  LoadingIndicator,
  FullScreenLoading,
  InlineLoading,
  Toast
} from '../components';
import { ErrorHandler } from '../utils/ErrorHandler';
import { ThemeColors, ThemeSpacing } from '../utils/ThemeConstants';
import router from '@ohos.router';

@Entry
@Component
struct ErrorHandlingDemo {
  @State showErrorDisplay: boolean = false;
  @State showEmptyState: boolean = false;
  @State showInlineError: boolean = false;
  @State showErrorPage: boolean = false;
  @State showLoading: boolean = false;
  @State showFullScreenLoading: boolean = false;
  @State showInlineLoading: boolean = false;

  build() {
    Column() {
      // Header
      Row() {
        Button('返回')
          .fontSize(14)
          .onClick(() => {
            router.back();
          })
        
        Text('错误处理演示')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // Placeholder for alignment
        Button()
          .width(60)
          .visibility(Visibility.Hidden)
      }
      .width('100%')
      .padding(ThemeSpacing.MD)
      .backgroundColor(ThemeColors.BG_PRIMARY)

      Scroll() {
        Column({ space: ThemeSpacing.MD }) {
          // Toast Examples
          this.buildSection('Toast 提示')
          Column({ space: ThemeSpacing.SM }) {
            Button('成功提示')
              .width('100%')
              .onClick(() => {
                Toast.success('操作成功！');
              })

            Button('错误提示')
              .width('100%')
              .onClick(() => {
                Toast.error('操作失败！');
              })

            Button('警告提示')
              .width('100%')
              .onClick(() => {
                Toast.warning('请注意！');
              })

            Button('信息提示')
              .width('100%')
              .onClick(() => {
                Toast.info('这是一条信息');
              })
          }
          this.buildSectionEnd()

          // Error Handler Examples
          this.buildSection('错误处理器')
          Column({ space: ThemeSpacing.SM }) {
            Button('验证错误')
              .width('100%')
              .onClick(() => {
                ErrorHandler.handleValidationError('金额必须大于0', 'amount');
              })

            Button('数据库错误')
              .width('100%')
              .onClick(() => {
                const error = new Error('Connection failed');
                ErrorHandler.handleDatabaseError(error, 'save data');
              })

            Button('数据不一致错误')
              .width('100%')
              .onClick(() => {
                ErrorHandler.handleDataInconsistencyError('数据格式异常');
              })
          }
          this.buildSectionEnd()

          // Loading Indicators
          this.buildSection('加载指示器')
          Column({ space: ThemeSpacing.SM }) {
            Button(this.showLoading ? '隐藏加载' : '显示加载')
              .width('100%')
              .onClick(() => {
                this.showLoading = !this.showLoading;
              })

            if (this.showLoading) {
              LoadingIndicator({ message: '加载中...' })
                .height(100)
            }

            Button(this.showInlineLoading ? '隐藏内联加载' : '显示内联加载')
              .width('100%')
              .onClick(() => {
                this.showInlineLoading = !this.showInlineLoading;
              })

            if (this.showInlineLoading) {
              InlineLoading({ message: '正在处理...' })
            }

            Button('显示全屏加载')
              .width('100%')
              .onClick(() => {
                this.showFullScreenLoading = true;
                setTimeout(() => {
                  this.showFullScreenLoading = false;
                }, 2000);
              })
          }
          this.buildSectionEnd()

          // Error Display Components
          this.buildSection('错误显示组件')
          Column({ space: ThemeSpacing.SM }) {
            Button(this.showErrorDisplay ? '隐藏错误显示' : '显示错误显示')
              .width('100%')
              .onClick(() => {
                this.showErrorDisplay = !this.showErrorDisplay;
              })

            if (this.showErrorDisplay) {
              ErrorDisplay({
                message: '加载失败',
                description: '无法连接到服务器，请检查网络连接',
                showRetry: true,
                onRetry: () => {
                  Toast.info('重试中...');
                  this.showErrorDisplay = false;
                }
              })
                .height(200)
            }

            Button(this.showEmptyState ? '隐藏空状态' : '显示空状态')
              .width('100%')
              .onClick(() => {
                this.showEmptyState = !this.showEmptyState;
              })

            if (this.showEmptyState) {
              EmptyState({
                message: '暂无交易记录',
                description: '点击下方按钮添加第一笔交易',
                icon: '📝',
                actionText: '添加交易',
                onAction: () => {
                  Toast.info('跳转到添加页面');
                }
              })
                .height(250)
            }

            Button(this.showInlineError ? '隐藏内联错误' : '显示内联错误')
              .width('100%')
              .onClick(() => {
                this.showInlineError = !this.showInlineError;
              })

            if (this.showInlineError) {
              InlineError({
                message: '金额不能为空或小于等于0'
              })
            }

            Button('显示错误页面')
              .width('100%')
              .onClick(() => {
                this.showErrorPage = true;
              })
          }
          this.buildSectionEnd()

          // Async Error Handling
          this.buildSection('异步错误处理')
          Column({ space: ThemeSpacing.SM }) {
            Button('测试异步包装')
              .width('100%')
              .onClick(async () => {
                const result = await ErrorHandler.wrapAsync<void>(
                  async () => {
                    // Simulate async operation
                    await new Promise<void>((resolve) => setTimeout(resolve, 1000));
                    throw new Error('模拟错误');
                  },
                  '异步操作失败'
                );
                
                if (result === null) {
                  Toast.info('操作被取消');
                }
              })

            Button('测试同步包装')
              .width('100%')
              .onClick(() => {
                const result = ErrorHandler.wrapSync(
                  () => {
                    throw new Error('模拟同步错误');
                  },
                  '同步操作失败'
                );
                
                if (result === null) {
                  Toast.info('操作被取消');
                }
              })
          }
          this.buildSectionEnd()
        }
        .width('100%')
        .padding(ThemeSpacing.MD)
      }
      .layoutWeight(1)

      // Full screen loading overlay
      if (this.showFullScreenLoading) {
        FullScreenLoading({ message: '处理中，请稍候...' })
      }

      // Error page overlay
      if (this.showErrorPage) {
        ErrorPage({
          title: '页面加载失败',
          message: '无法加载页面内容，请稍后重试',
          errorCode: 'ERR_500',
          showRetry: true,
          showBack: true,
          onRetry: () => {
            Toast.info('重新加载...');
            this.showErrorPage = false;
          },
          onBack: () => {
            this.showErrorPage = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  buildSection(title: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: ThemeSpacing.SM })
    }
    .width('100%')
    .padding({ left: ThemeSpacing.MD, right: ThemeSpacing.MD, top: ThemeSpacing.MD })
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .borderRadius({ topLeft: 8, topRight: 8 })
  }

  @Builder
  buildSectionEnd() {
    Column() {
    }
    .width('100%')
    .padding({ left: ThemeSpacing.MD, right: ThemeSpacing.MD, bottom: ThemeSpacing.MD })
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    .margin({ bottom: ThemeSpacing.MD })
  }
}
