import { describe, it, expect } from '@ohos/hypium';
import { DateUtils, FormatUtils, ValidationUtils, SortUtils } from '../main/ets/utils';
import { Transaction, TransactionType, TransactionInput } from '../main/ets/models';

export default function utilsTest() {
  describe('DateUtils', () => {
    it('should format date correctly', () => {
      const timestamp = new Date(2024, 0, 15).getTime(); // Jan 15, 2024
      const formatted = DateUtils.formatDate(timestamp, 'YYYY-MM-DD');
      expect(formatted).assertEqual('2024-01-15');
    });

    it('should get start of day', () => {
      const timestamp = new Date(2024, 0, 15, 14, 30, 45).getTime();
      const startOfDay = DateUtils.getStartOfDay(timestamp);
      const date = new Date(startOfDay);
      expect(date.getHours()).assertEqual(0);
      expect(date.getMinutes()).assertEqual(0);
      expect(date.getSeconds()).assertEqual(0);
    });

    it('should get end of day', () => {
      const timestamp = new Date(2024, 0, 15, 14, 30, 45).getTime();
      const endOfDay = DateUtils.getEndOfDay(timestamp);
      const date = new Date(endOfDay);
      expect(date.getHours()).assertEqual(23);
      expect(date.getMinutes()).assertEqual(59);
      expect(date.getSeconds()).assertEqual(59);
    });

    it('should check if date is in range', () => {
      const date = new Date(2024, 0, 15).getTime();
      const startDate = new Date(2024, 0, 1).getTime();
      const endDate = new Date(2024, 0, 31).getTime();
      expect(DateUtils.isInRange(date, startDate, endDate)).assertTrue();
    });

    it('should check if two dates are same day', () => {
      const date1 = new Date(2024, 0, 15, 10, 0, 0).getTime();
      const date2 = new Date(2024, 0, 15, 20, 0, 0).getTime();
      expect(DateUtils.isSameDay(date1, date2)).assertTrue();
    });
  });

  describe('FormatUtils', () => {
    it('should format currency', () => {
      const formatted = FormatUtils.formatCurrency(1234.56);
      expect(formatted).assertEqual('¥1,234.56');
    });

    it('should format currency with custom symbol', () => {
      const formatted = FormatUtils.formatCurrency(1234.56, '$');
      expect(formatted).assertEqual('$1,234.56');
    });

    it('should format percentage from decimal', () => {
      const formatted = FormatUtils.formatPercentage(0.4567);
      expect(formatted).assertEqual('45.67%');
    });

    it('should format percentage from whole number', () => {
      const formatted = FormatUtils.formatPercentage(45.67);
      expect(formatted).assertEqual('45.67%');
    });

    it('should format number with thousand separators', () => {
      const formatted = FormatUtils.formatNumber(1234567.89);
      expect(formatted).assertEqual('1,234,567.89');
    });

    it('should format number with custom decimals', () => {
      const formatted = FormatUtils.formatNumber(1234.5678, 3);
      expect(formatted).assertEqual('1,234.568');
    });
  });

  describe('ValidationUtils', () => {
    it('should validate positive amount', () => {
      expect(ValidationUtils.isValidAmount(100)).assertTrue();
      expect(ValidationUtils.isValidAmount(0.01)).assertTrue();
    });

    it('should reject invalid amounts', () => {
      expect(ValidationUtils.isValidAmount(0)).assertFalse();
      expect(ValidationUtils.isValidAmount(-100)).assertFalse();
      expect(ValidationUtils.isValidAmount(NaN)).assertFalse();
    });

    it('should validate date timestamp', () => {
      const validDate = Date.now();
      expect(ValidationUtils.isValidDate(validDate)).assertTrue();
    });

    it('should reject invalid dates', () => {
      expect(ValidationUtils.isValidDate(NaN)).assertFalse();
      expect(ValidationUtils.isValidDate(-1)).assertFalse();
    });

    it('should validate transaction input', () => {
      const validInput: TransactionInput = {
        type: TransactionType.EXPENSE,
        amount: 100,
        category: 'Food',
        description: 'Lunch',
        date: Date.now()
      };
      const result = ValidationUtils.validateTransactionInput(validInput);
      expect(result.valid).assertTrue();
      expect(result.errors.length).assertEqual(0);
    });

    it('should reject invalid transaction input', () => {
      const invalidInput: TransactionInput = {
        type: TransactionType.EXPENSE,
        amount: -100,
        category: '',
        description: '',
        date: NaN
      };
      const result = ValidationUtils.validateTransactionInput(invalidInput);
      expect(result.valid).assertFalse();
      expect(result.errors.length).assertLarger(0);
    });
  });

  describe('SortUtils', () => {
    const transactions: Transaction[] = [
      {
        id: 1,
        type: TransactionType.EXPENSE,
        amount: 100,
        category: 'Food',
        description: 'Lunch',
        date: new Date(2024, 0, 15).getTime(),
        createdAt: Date.now(),
        updatedAt: Date.now()
      },
      {
        id: 2,
        type: TransactionType.INCOME,
        amount: 500,
        category: 'Salary',
        description: 'Monthly salary',
        date: new Date(2024, 0, 10).getTime(),
        createdAt: Date.now(),
        updatedAt: Date.now()
      },
      {
        id: 3,
        type: TransactionType.EXPENSE,
        amount: 50,
        category: 'Transport',
        description: 'Bus fare',
        date: new Date(2024, 0, 20).getTime(),
        createdAt: Date.now(),
        updatedAt: Date.now()
      }
    ];

    it('should sort by date descending', () => {
      const sorted = SortUtils.sortByDateDesc(transactions);
      expect(sorted[0].id).assertEqual(3); // Jan 20
      expect(sorted[1].id).assertEqual(1); // Jan 15
      expect(sorted[2].id).assertEqual(2); // Jan 10
    });

    it('should sort by date ascending', () => {
      const sorted = SortUtils.sortByDateAsc(transactions);
      expect(sorted[0].id).assertEqual(2); // Jan 10
      expect(sorted[1].id).assertEqual(1); // Jan 15
      expect(sorted[2].id).assertEqual(3); // Jan 20
    });

    it('should sort by amount descending', () => {
      const sorted = SortUtils.sortByAmountDesc(transactions);
      expect(sorted[0].amount).assertEqual(500);
      expect(sorted[1].amount).assertEqual(100);
      expect(sorted[2].amount).assertEqual(50);
    });

    it('should sort by amount ascending', () => {
      const sorted = SortUtils.sortByAmountAsc(transactions);
      expect(sorted[0].amount).assertEqual(50);
      expect(sorted[1].amount).assertEqual(100);
      expect(sorted[2].amount).assertEqual(500);
    });

    it('should not modify original array', () => {
      const original = [...transactions];
      SortUtils.sortByDateDesc(transactions);
      expect(transactions[0].id).assertEqual(original[0].id);
    });
  });
}
