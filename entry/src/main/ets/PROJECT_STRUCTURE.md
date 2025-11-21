# Expense Tracker Project Structure

This document describes the project structure and organization of the Expense Tracker application.

## Directory Structure

```
entry/src/main/ets/
├── models/                    # Data models and interfaces
│   ├── Transaction.ets        # Transaction model, enums (TransactionType, MoodType)
│   ├── Category.ets           # Category model
│   ├── Achievement.ets        # Achievement model
│   ├── Summary.ets            # Summary model, PeriodType enum
│   ├── Budget.ets             # Budget model, enums (BudgetType, BudgetStatus)
│   ├── ExportData.ets         # Export data model
│   └── index.ets              # Models barrel export
│
├── repositories/              # Data access layer
│   ├── BaseRepository.ets     # Base repository class
│   ├── TransactionRepository.ets
│   ├── CategoryRepository.ets
│   ├── AchievementRepository.ets
│   ├── BudgetRepository.ets
│   └── index.ets              # Repositories barrel export
│
├── services/                  # Business logic layer
│   ├── TransactionService.ets
│   ├── CategoryService.ets
│   ├── AchievementService.ets
│   ├── StatisticsService.ets
│   ├── BudgetService.ets
│   ├── ExportService.ets
│   └── index.ets              # Services barrel export
│
├── pages/                     # UI pages (existing)
│   └── Index.ets              # Main page
│
├── components/                # Reusable UI components
│   └── README.md              # Component documentation
│
├── utils/                     # Utility functions
│   ├── DatabaseConfig.ets     # Database schema definitions
│   ├── DatabaseManager.ets    # Database initialization and management
│   ├── DateUtils.ets          # Date formatting and manipulation
│   ├── FormatUtils.ets        # Number and currency formatting
│   ├── ValidationUtils.ets    # Input validation
│   ├── SortUtils.ets          # Sorting utilities
│   └── index.ets              # Utils barrel export
│
└── entryability/              # Application entry point (existing)
    └── EntryAbility.ets
```

## Core Data Models

### Transaction
- Represents a single income or expense record
- Includes amount, category, description, date, and optional mood
- Enums: TransactionType (INCOME, EXPENSE), MoodType (SATISFIED, REGRET, SURPRISE)

### Category
- Represents transaction categories (e.g., food, transport, salary)
- Linked to TransactionType (income or expense)

### Achievement
- Represents user achievements and progress
- Tracks unlock status and progress percentage

### Summary
- Aggregated statistics for different time periods
- Includes income, expense, net amount, and category breakdown
- Enum: PeriodType (DAY, WEEK, MONTH, YEAR)

### Budget
- Represents budget goals and tracking
- Supports monthly, weekly, and category-specific budgets
- Enums: BudgetType, BudgetStatus (NORMAL, WARNING, EXCEEDED)

## Database Schema

The application uses RelationalStore (SQLite) with the following tables:

1. **transactions** - Stores all transaction records
2. **categories** - Stores category definitions
3. **achievements** - Stores achievement data
4. **budgets** - Stores budget goals and progress

Indexes are created on frequently queried fields (date, category, type) for performance.

## Architecture Pattern

The application follows a layered architecture:

1. **Presentation Layer** (pages, components) - UI and user interaction
2. **Business Logic Layer** (services) - Application logic and rules
3. **Data Access Layer** (repositories) - Database operations
4. **Storage Layer** (RelationalStore) - Persistent data storage

## Implementation Status

✅ Task 1 Complete: Project structure and core interfaces set up
- All data models defined
- Repository interfaces created
- Service interfaces created
- Database schema configured
- Utility classes scaffolded

🔄 Next Steps: Implement data access layer (Task 2)
