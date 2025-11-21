import router from '@ohos.router';

/**
 * BottomNavigation - 底部导航栏组件
 * 提供主要页面间的快速导航
 * 需求：9.1, 9.2, 9.3
 */

export interface NavigationItem {
  icon: string;
  label: string;
  url: string;
  active: boolean;
}

@Component
export struct BottomNavigation {
  @Prop currentPage: string = 'Index'; // Current active page name
  
  /**
   * Get navigation items
   * 需求：12.1 - 在导航栏添加预算管理入口
   * 需求：13.1 - 在设置或更多页面添加数据导出入口
   */
  private getNavigationItems(): NavigationItem[] {
    return [
      {
        icon: '🏠',
        label: '首页',
        url: 'pages/Index',
        active: this.currentPage === 'Index'
      },
      {
        icon: '📊',
        label: '统计',
        url: 'pages/StatisticsPage',
        active: this.currentPage === 'StatisticsPage'
      },
      {
        icon: '💰',
        label: '预算',
        url: 'pages/BudgetPage',
        active: this.currentPage === 'BudgetPage'
      },
      {
        icon: '🔍',
        label: '查询',
        url: 'pages/QueryPage',
        active: this.currentPage === 'QueryPage'
      },
      {
        icon: '⋯',
        label: '更多',
        url: 'pages/MorePage',
        active: this.currentPage === 'MorePage'
      }
    ];
  }

  /**
   * Navigate to page
   */
  private navigateToPage(url: string) {
    // Use replaceUrl to avoid stacking navigation pages
    router.replaceUrl({
      url: url
    }).catch((error: Error) => {
      console.error(`Failed to navigate to ${url}:`, error);
    });
  }

  /**
   * Build UI
   */
  build() {
    Row() {
      ForEach(this.getNavigationItems(), (item: NavigationItem) => {
        Column() {
          Text(item.icon)
            .fontSize(24)
            .margin({ bottom: 4 })
          
          Text(item.label)
            .fontSize(12)
            .fontColor(item.active ? '#1890FF' : '#666666')
            .fontWeight(item.active ? FontWeight.Medium : FontWeight.Normal)
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(item.active ? '#E6F7FF' : Color.Transparent)
        .onClick(() => {
          if (!item.active) {
            this.navigateToPage(item.url);
          }
        })
      }, (item: NavigationItem) => item.url)
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: -2
    })
  }
}
