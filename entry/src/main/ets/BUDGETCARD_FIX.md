# BudgetCard Destructuring Fix

## Issue

BudgetCard.ets had a destructuring error at line 39:
```
Destructuring variable declarations are not supported (arkts-no-destruct-decls)
```

## Problem

ArkTS does not support destructuring assignments in variable declarations. The code was using:

```typescript
const [year, month] = this.budget.period.split('-');
```

This is a common JavaScript/TypeScript pattern, but it's not allowed in ArkTS.

## Solution

Replaced destructuring with explicit array indexing:

```typescript
// Before (not allowed in ArkTS)
const [year, month] = this.budget.period.split('-');

// After (ArkTS compliant)
const parts = this.budget.period.split('-');
const year = parts[0];
const month = parts[1];
```

## ArkTS Restriction

ArkTS has stricter syntax rules than standard TypeScript:
- **No destructuring in variable declarations** - Must use explicit indexing
- This applies to both array and object destructuring
- Destructuring in function parameters is also not allowed

## Status

✅ Error resolved
✅ File compiles without warnings
✅ Functionality unchanged
✅ ArkTS syntax compliant
