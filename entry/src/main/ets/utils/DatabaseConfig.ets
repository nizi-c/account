/**
 * Database Configuration
 * 数据库配置和表结构定义
 */

export const DATABASE_NAME = 'expense_tracker.db';
export const DATABASE_VERSION = 1;

/**
 * Transactions Table Schema
 */
export const CREATE_TRANSACTIONS_TABLE = `
  CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    date INTEGER NOT NULL,
    mood TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
`;

/**
 * Categories Table Schema
 */
export const CREATE_CATEGORIES_TABLE = `
  CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    icon TEXT,
    color TEXT
  )
`;

/**
 * Achievements Table Schema
 */
export const CREATE_ACHIEVEMENTS_TABLE = `
  CREATE TABLE IF NOT EXISTS achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    unlocked INTEGER DEFAULT 0,
    unlocked_at INTEGER,
    progress REAL DEFAULT 0,
    target REAL NOT NULL
  )
`;

/**
 * Budgets Table Schema
 */
export const CREATE_BUDGETS_TABLE = `
  CREATE TABLE IF NOT EXISTS budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    period TEXT NOT NULL,
    category TEXT,
    amount REAL NOT NULL,
    spent REAL DEFAULT 0,
    remaining REAL NOT NULL,
    percentage REAL DEFAULT 0,
    status TEXT DEFAULT 'normal',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    UNIQUE(type, period, category)
  )
`;

/**
 * Create Indexes for Performance
 */
export const CREATE_TRANSACTIONS_DATE_INDEX = `
  CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)
`;

export const CREATE_TRANSACTIONS_CATEGORY_INDEX = `
  CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category)
`;

export const CREATE_TRANSACTIONS_TYPE_INDEX = `
  CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type)
`;

export const CREATE_BUDGETS_PERIOD_INDEX = `
  CREATE INDEX IF NOT EXISTS idx_budgets_period ON budgets(period)
`;

/**
 * All table creation statements
 */
export const ALL_TABLE_SCHEMAS = [
  CREATE_TRANSACTIONS_TABLE,
  CREATE_CATEGORIES_TABLE,
  CREATE_ACHIEVEMENTS_TABLE,
  CREATE_BUDGETS_TABLE
];

/**
 * All index creation statements
 */
export const ALL_INDEX_SCHEMAS = [
  CREATE_TRANSACTIONS_DATE_INDEX,
  CREATE_TRANSACTIONS_CATEGORY_INDEX,
  CREATE_TRANSACTIONS_TYPE_INDEX,
  CREATE_BUDGETS_PERIOD_INDEX
];
