# Components Directory

This directory contains reusable UI components for the Expense Tracker app.

## Implemented Components

- **TransactionCard**: Display individual transaction records with mood icons (需求 1.2, 3.1, 7.3)
- **TransactionList**: Transaction list with swipe-to-delete, virtual scrolling, and empty state (需求 1.2, 1.3, 3.1, 3.3, 3.5, 5.6, 7.3)
- **PieChart**: Pie chart component with Canvas rendering, interactive segments, and legend (需求 6.1, 6.2, 6.3, 6.5, 10.4)
- **LineChart**: Line chart component with Canvas rendering, grid, axes, and tooltips (需求 6.1, 6.2, 6.3, 6.5, 10.4)

## Planned Components

- **CategorySelector**: Category selection component
- **MoodSelector**: Mood selection component
- **DateRangePicker**: Date range picker component
- **SummaryCard**: Summary statistics card
- **AchievementBadge**: Achievement badge component
- **BudgetProgressBar**: Budget progress bar component
- **BudgetCard**: Budget card component
- **WarningAlert**: Warning alert component

Components will be implemented in subsequent tasks.


## Chart Components Details

### PieChart

A pie chart component that visualizes data as circular segments with interactive features.

**Features:**
- Canvas-based rendering for smooth graphics
- Interactive segment selection (click/touch)
- Automatic color assignment with customizable colors
- Percentage labels on segments
- Legend with color indicators
- Responsive sizing
- Empty state handling

**Props:**
- `chartData: PieChartData` - Chart data with labels, values, and optional colors
- `width: number` - Chart width (default: 300)
- `height: number` - Chart height (default: 300)

**Usage:**
```typescript
PieChart({
  chartData: {
    labels: ['餐饮', '交通', '购物'],
    values: [500, 300, 200],
    colors: ['#FF6B6B', '#4ECDC4', '#45B7D1']
  },
  width: 300,
  height: 300
})
```

### LineChart

A line chart component that displays trends over time with grid and axes.

**Features:**
- Canvas-based rendering with smooth lines
- Grid lines and axes with labels
- Interactive point selection (click/touch)
- Tooltip on selected point
- Area fill under line
- Auto-scaling based on data range
- Responsive sizing
- Empty state handling

**Props:**
- `chartData: LineChartData` - Chart data with labels, values, and optional colors
- `width: number` - Chart width (default: 350)
- `height: number` - Chart height (default: 250)

**Usage:**
```typescript
LineChart({
  chartData: {
    labels: ['2024-01-01', '2024-01-02', '2024-01-03'],
    values: [100, 150, 120],
    colors: ['#4CAF50']
  },
  width: 350,
  height: 250
})
```

## Implementation Notes

Both chart components:
- Use Canvas API for high-performance rendering
- Support touch interactions for mobile devices
- Handle empty data gracefully
- Are responsive to different screen sizes
- Follow the app's design system for colors and typography
- Provide visual feedback on user interactions
