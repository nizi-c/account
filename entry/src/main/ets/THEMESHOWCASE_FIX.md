# ThemeShowcase UI Component Syntax Fix

## Issue

ThemeShowcase.ets had 4 UI component syntax errors where `if` statements were used directly in a Column component without wrapping their content in UI components.

## Problem

In ArkTS @Builder methods and build() methods, `if` statements cannot directly contain @Builder method calls or UI components. They must wrap the content in a UI component like Column, Row, etc.

```typescript
// WRONG - Not allowed in ArkTS
Column() {
  if (condition) {
    this.buildSomeSection();  // ❌ Error: Only UI component syntax can be written here
  }
}

// CORRECT - Wrap in UI component
Column() {
  if (condition) {
    Column() {
      this.buildSomeSection();  // ✅ Works correctly
    }
  }
}
```

## Solution

Wrapped each conditional @Builder call in a Column component:

```typescript
// Before (lines 56-71)
Column() {
  if (this.selectedTab === 0) {
    this.buildColorSection();
  }
  if (this.selectedTab === 1) {
    this.buildButtonSection();
  }
  if (this.selectedTab === 2) {
    this.buildCardSection();
  }
  if (this.selectedTab === 3) {
    this.buildInputSection();
  }
  if (this.selectedTab === 4) {
    this.buildTextSection();
  }
}

// After
Column() {
  if (this.selectedTab === 0) {
    Column() {
      this.buildColorSection();
    }
  }
  if (this.selectedTab === 1) {
    Column() {
      this.buildButtonSection();
    }
  }
  if (this.selectedTab === 2) {
    Column() {
      this.buildCardSection();
    }
  }
  if (this.selectedTab === 3) {
    Column() {
      this.buildInputSection();
    }
  }
  if (this.selectedTab === 4) {
    Column() {
      this.buildTextSection();
    }
  }
}
```

## ArkTS UI Component Syntax Rules

1. **If statements in UI context must wrap content in UI components**
   - Cannot have bare @Builder calls or UI components directly in if blocks
   - Must wrap in Column, Row, Stack, or other container components

2. **Alternative approaches:**
   - Use ternary operators for simple cases
   - Use separate @Builder methods for each condition
   - Use ForEach with conditional arrays

## Status

✅ All 4 errors resolved
✅ File compiles without warnings
✅ Theme showcase functionality preserved
✅ Proper ArkTS UI component syntax
