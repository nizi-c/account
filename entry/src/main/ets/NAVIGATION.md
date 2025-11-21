# Navigation and Routing Structure

## Overview
The application implements a bottom navigation bar for main pages and standard back button navigation for secondary pages.

## Page Hierarchy

### Main Pages (with Bottom Navigation)
These pages have a bottom navigation bar that allows quick switching between main sections:

1. **Index (首页)** - `pages/Index`
   - Home page showing daily transactions
   - Default landing page
   - Navigation: Bottom nav bar

2. **StatisticsPage (统计)** - `pages/StatisticsPage`
   - Statistics and charts
   - Navigation: Bottom nav bar + back button to home

3. **QueryPage (查询)** - `pages/QueryPage`
   - Advanced search and filtering
   - Navigation: Bottom nav bar + back button to home

4. **AchievementPage (成就)** - `pages/AchievementPage`
   - Achievement list and progress
   - Navigation: Bottom nav bar + back button to home

### Secondary Pages (without Bottom Navigation)
These pages use standard back button navigation:

1. **AddTransactionPage** - `pages/AddTransactionPage`
   - Add new transaction form
   - Navigation: Back button (router.back())

2. **MonthViewPage** - `pages/MonthViewPage`
   - Monthly transaction view
   - Navigation: Back button (router.back())

3. **MoodCalendarPage** - `pages/MoodCalendarPage`
   - Mood calendar view
   - Navigation: Back button (router.back())

## Navigation Implementation

### Bottom Navigation Component
- **File**: `entry/src/main/ets/components/BottomNavigation.ets`
- **Usage**: Imported and placed at the bottom of main pages
- **Behavior**: Uses `router.replaceUrl()` to avoid stacking pages

### Navigation Methods

#### Main Pages
- **Bottom Navigation**: Uses `router.replaceUrl()` to switch between main pages
- **Back Button**: Uses `router.replaceUrl()` to return to Index page

#### Secondary Pages
- **Back Button**: Uses `router.back()` to return to previous page

### Route Configuration
All pages are registered in `entry/src/main/resources/base/profile/main_pages.json`:
```json
{
  "src": [
    "pages/Index",
    "pages/AddTransactionPage",
    "pages/MonthViewPage",
    "pages/QueryPage",
    "pages/StatisticsPage",
    "pages/MoodCalendarPage",
    "pages/AchievementPage"
  ]
}
```

## Navigation Flow Examples

### Example 1: Main Page Navigation
```
Index → [Bottom Nav: Statistics] → StatisticsPage
StatisticsPage → [Bottom Nav: Query] → QueryPage
QueryPage → [Bottom Nav: Home] → Index
```

### Example 2: Secondary Page Navigation
```
Index → [+ Button] → AddTransactionPage → [Back] → Index
Index → [Month View Button] → MonthViewPage → [Back] → Index
```

### Example 3: Mixed Navigation
```
Index → [Statistics Button] → StatisticsPage → [Back Button] → Index
Index → [+ Button] → AddTransactionPage → [Back] → Index
```

## Requirements Fulfilled

- ✅ **需求 9.1**: 首页界面包含快速添加按钮和导航
- ✅ **需求 9.2**: 添加按钮显示结构化输入表单
- ✅ **需求 9.3**: 查询页面提供直观的筛选控件

## Implementation Notes

1. **Bottom Navigation Bar**:
   - Fixed at the bottom of main pages
   - Shows 4 main sections: Home, Statistics, Query, Achievement
   - Active page is highlighted with blue background
   - Uses icons and labels for clarity

2. **Back Button Handling**:
   - Main pages: Navigate to Index using `router.replaceUrl()`
   - Secondary pages: Navigate to previous page using `router.back()`
   - Prevents navigation stack issues

3. **Responsive Design**:
   - Bottom navigation adapts to screen size
   - Tablet landscape mode shows sidebar navigation instead
   - Consistent navigation experience across devices
