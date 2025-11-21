import router from '@ohos.router';
import { BottomNavigation } from '../components/BottomNavigation';
import { ResponsiveUtils, DeviceType } from '../utils/ResponsiveUtils';
import display from '@ohos.display';

/**
 * MorePage - 更多功能页面
 * 提供数据导出等额外功能的入口
 * 需求：13.1 - 在设置或更多页面添加数据导出入口
 */
@Entry
@Component
struct MorePage {
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  @State deviceType: DeviceType = DeviceType.PHONE;

  /**
   * Component lifecycle - on page show
   */
  async aboutToAppear() {
    await this.initializeScreenSize();
  }

  /**
   * Initialize screen size and device type
   */
  private async initializeScreenSize() {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      this.screenWidth = px2vp(defaultDisplay.width);
      this.screenHeight = px2vp(defaultDisplay.height);
      this.deviceType = ResponsiveUtils.getDeviceType(this.screenWidth);
    } catch (error) {
      console.error('Failed to get screen size:', error);
      this.screenWidth = 360;
      this.screenHeight = 780;
      this.deviceType = DeviceType.PHONE;
    }
  }

  /**
   * Navigate to export page
   */
  private navigateToExportPage() {
    router.pushUrl({
      url: 'pages/ExportPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to ExportPage:', error);
    });
  }

  /**
   * Navigate to mood calendar page
   */
  private navigateToMoodCalendarPage() {
    router.pushUrl({
      url: 'pages/MoodCalendarPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to MoodCalendarPage:', error);
    });
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      // Header
      this.buildHeader();

      // Content
      Scroll() {
        Column({ space: 0 }) {
          // Section: Data Management
          this.buildSectionHeader('数据管理');
          this.buildMenuItem('📤', '数据导出', '导出交易数据为CSV或JSON格式', () => {
            this.navigateToExportPage();
          });

          Divider()
            .color('#F0F0F0')
            .margin({ left: 56 })

          // Section: Additional Features
          this.buildSectionHeader('其他功能');
          this.buildMenuItem('😊', '情绪日历', '查看每日消费情绪记录', () => {
            this.navigateToMoodCalendarPage();
          });

          Divider()
            .color('#F0F0F0')
            .margin({ left: 56 })

          // Section: About
          this.buildSectionHeader('关于');
          this.buildMenuItem('ℹ️', '关于应用', '版本 1.0.0', null);
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // Bottom navigation
      BottomNavigation({ currentPage: 'MorePage' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * Build header
   */
  @Builder
  buildHeader() {
    Row() {
      Text('更多')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
  }

  /**
   * Build section header
   */
  @Builder
  buildSectionHeader(title: string) {
    Text(title)
      .fontSize(14)
      .fontColor('#999999')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      .width('100%')
  }

  /**
   * Build menu item
   */
  @Builder
  buildMenuItem(icon: string, title: string, description: string, onClick: (() => void) | null) {
    Row() {
      // Icon
      Text(icon)
        .fontSize(28)
        .margin({ right: 16 })

      // Title and description
      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)

        Text(description)
          .fontSize(14)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // Arrow
      if (onClick) {
        Text('>')
          .fontSize(20)
          .fontColor('#CCCCCC')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }
}
