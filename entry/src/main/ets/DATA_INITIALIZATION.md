# Data Initialization Guide

## Overview

The data initialization system ensures that predefined categories and achievements are set up when the app is first launched. This provides users with a ready-to-use experience without requiring manual setup.

## Components

### InitializationService

The `InitializationService` is responsible for:

1. **First Launch Detection**: Tracks whether the app has been launched before using preferences
2. **Category Initialization**: Populates the database with predefined income and expense categories
3. **Achievement Initialization**: Sets up the achievement system with predefined goals
4. **Sample Data Generation**: Optionally creates sample transactions for demonstration

## First Launch Flow

```
App Launch
    ↓
EntryAbility.onCreate()
    ↓
initializeApp()
    ↓
Check if first launch (via Preferences)
    ↓
If first launch:
    ├─ Initialize Categories (14 predefined)
    ├─ Initialize Achievements (6 predefined)
    └─ Optionally generate sample data
    ↓
Mark as initialized
```

## Predefined Data

### Categories

**Income Categories (5):**
- 工资 (Salary) 💰
- 奖金 (Bonus) 🎁
- 投资收益 (Investment) 📈
- 兼职 (Part-time) 💼
- 其他收入 (Other Income) 💵

**Expense Categories (9):**
- 餐饮 (Food) 🍔
- 交通 (Transport) 🚗
- 购物 (Shopping) 🛍️
- 娱乐 (Entertainment) 🎮
- 住房 (Housing) 🏠
- 医疗 (Healthcare) 💊
- 教育 (Education) 📚
- 水电费 (Utilities) 💡
- 其他支出 (Other Expense) 📝

### Achievements

1. **连续记账7天** (7-Day Streak) 🔥
   - Target: 7 consecutive days of recording transactions

2. **月度预算控制达人** (Budget Master) 💎
   - Target: Stay within monthly budget

3. **餐饮消费合理化** (Reasonable Food Spending) 🍽️
   - Target: Keep food expenses below threshold

4. **记账新手** (First Transaction) 🌟
   - Target: Complete first transaction

5. **记账达人** (100 Transactions) 📊
   - Target: Record 100 transactions

6. **收支平衡** (Positive Balance) 💰
   - Target: Monthly income exceeds expenses

## Usage

### Basic Initialization

The initialization happens automatically in `EntryAbility.onCreate()`:

```typescript
private async initializeApp(): Promise<void> {
  const dbManager = DatabaseManager.getInstance();
  const store = await dbManager.initialize(this.context);
  
  const categoryRepo = new CategoryRepository(store);
  const achievementRepo = new AchievementRepository(store);
  const transactionRepo = new TransactionRepository(store);
  
  const initService = new InitializationService(categoryRepo, achievementRepo, transactionRepo);
  
  // Initialize without sample data
  await initService.initializeApp(this.context, store, false);
}
```

### With Sample Data

To include sample transactions for testing or demonstration:

```typescript
// Initialize with sample data
await initService.initializeApp(this.context, store, true);
```

This will create 12 sample transactions spanning the last 20 days, including:
- Various expense types (food, transport, shopping, etc.)
- Income transactions (salary, bonus)
- Different mood tags (satisfied, regret, surprise)

### Manual Initialization

You can also manually trigger initialization:

```typescript
const initService = new InitializationService(categoryRepo, achievementRepo, transactionRepo);

// Check if first launch
const isFirst = await initService.isFirstLaunch(context);

// Initialize data only
await initService.initializeData(context, store);

// Generate sample data separately
await initService.generateSampleData(context);
```

## Preferences Storage

The service uses HarmonyOS Preferences to track initialization state:

- **Preference Name**: `app_preferences`
- **Keys**:
  - `is_first_launch`: Boolean indicating if app has been launched before
  - `data_initialized`: Boolean indicating if predefined data has been set up

## Error Handling

The initialization process includes error handling:

- Individual category/achievement insertion failures are logged but don't stop the process
- Overall initialization failures are caught and logged
- The app can still function even if initialization partially fails

## Testing

Unit tests verify:
- Default categories are properly defined
- Categories have unique IDs
- Both income and expense categories exist
- Category colors are valid hex codes
- Expected categories are present (工资, 餐饮, etc.)

Run tests with:
```bash
npm test
```

## Resetting Initialization

To reset the app and trigger initialization again:

1. Clear app data through system settings
2. Or manually delete preferences:
   ```typescript
   const prefs = await preferences.getPreferences(context, 'app_preferences');
   await prefs.delete('is_first_launch');
   await prefs.delete('data_initialized');
   await prefs.flush();
   ```

## Future Enhancements

Potential improvements:
- User-customizable categories
- Import/export of category definitions
- Achievement customization
- Multiple sample data sets
- Localization of category names
- Category icons from resources instead of emoji
