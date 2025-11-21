import { describe, it, expect, beforeEach } from '@ohos/hypium';
import { CacheManager } from '../main/ets/utils/CacheManager';

/**
 * CacheManager Unit Tests
 * 测试缓存管理器的基本功能
 */
export default function cacheManagerTest() {
  describe('CacheManager', () => {
    let cacheManager: CacheManager;

    beforeEach(() => {
      cacheManager = CacheManager.getInstance();
      cacheManager.clear(); // Clear cache before each test
    });

    /**
     * Test: Singleton pattern
     */
    it('should return same instance', () => {
      const instance1 = CacheManager.getInstance();
      const instance2 = CacheManager.getInstance();
      expect(instance1).assertEqual(instance2);
    });

    /**
     * Test: Set and get cache
     */
    it('should set and get cache value', () => {
      const key = 'test-key';
      const value = { data: 'test-data' };
      
      cacheManager.set(key, value);
      const retrieved = cacheManager.get(key);
      
      expect(retrieved).assertNotNull();
      expect(retrieved.data).assertEqual('test-data');
    });

    /**
     * Test: Cache expiration
     */
    it('should expire cache after TTL', async () => {
      const key = 'expire-key';
      const value = 'expire-value';
      const ttl = 100; // 100ms
      
      cacheManager.set(key, value, ttl);
      
      // Should exist immediately
      expect(cacheManager.has(key)).assertTrue();
      
      // Wait for expiration
      await new Promise(resolve => setTimeout(resolve, 150));
      
      // Should be expired
      expect(cacheManager.has(key)).assertFalse();
      expect(cacheManager.get(key)).assertNull();
    });

    /**
     * Test: Cache invalidation
     */
    it('should invalidate specific cache', () => {
      cacheManager.set('key1', 'value1');
      cacheManager.set('key2', 'value2');
      
      cacheManager.invalidate('key1');
      
      expect(cacheManager.has('key1')).assertFalse();
      expect(cacheManager.has('key2')).assertTrue();
    });

    /**
     * Test: Pattern-based invalidation
     */
    it('should invalidate caches matching pattern', () => {
      cacheManager.set('summary:day:123', 'data1');
      cacheManager.set('summary:week:456', 'data2');
      cacheManager.set('chart:pie:789', 'data3');
      
      cacheManager.invalidatePattern('summary:.*');
      
      expect(cacheManager.has('summary:day:123')).assertFalse();
      expect(cacheManager.has('summary:week:456')).assertFalse();
      expect(cacheManager.has('chart:pie:789')).assertTrue();
    });

    /**
     * Test: Clear all cache
     */
    it('should clear all cache', () => {
      cacheManager.set('key1', 'value1');
      cacheManager.set('key2', 'value2');
      cacheManager.set('key3', 'value3');
      
      expect(cacheManager.size()).assertEqual(3);
      
      cacheManager.clear();
      
      expect(cacheManager.size()).assertEqual(0);
    });

    /**
     * Test: Clean expired entries
     */
    it('should clean expired entries', async () => {
      cacheManager.set('key1', 'value1', 100); // 100ms TTL
      cacheManager.set('key2', 'value2', 10000); // 10s TTL
      
      // Wait for first entry to expire
      await new Promise(resolve => setTimeout(resolve, 150));
      
      cacheManager.cleanExpired();
      
      expect(cacheManager.has('key1')).assertFalse();
      expect(cacheManager.has('key2')).assertTrue();
      expect(cacheManager.size()).assertEqual(1);
    });

    /**
     * Test: Generate summary cache key
     */
    it('should generate correct summary cache key', () => {
      const key = CacheManager.generateSummaryKey('month', 1000, 2000);
      expect(key).assertEqual('summary:month:1000:2000');
    });

    /**
     * Test: Generate chart cache key
     */
    it('should generate correct chart cache key', () => {
      const key = CacheManager.generateChartKey('pie', 'month', 1234567890);
      expect(key).assertEqual('chart:pie:month:1234567890');
    });

    /**
     * Test: Generate transactions cache key
     */
    it('should generate correct transactions cache key', () => {
      const key = CacheManager.generateTransactionsKey(1000, 2000);
      expect(key).assertEqual('transactions:1000:2000');
    });

    /**
     * Test: Cache with different data types
     */
    it('should cache different data types', () => {
      cacheManager.set('string', 'test');
      cacheManager.set('number', 123);
      cacheManager.set('boolean', true);
      cacheManager.set('object', { a: 1, b: 2 });
      cacheManager.set('array', [1, 2, 3]);
      
      expect(cacheManager.get('string')).assertEqual('test');
      expect(cacheManager.get('number')).assertEqual(123);
      expect(cacheManager.get('boolean')).assertTrue();
      expect(cacheManager.get('object').a).assertEqual(1);
      expect(cacheManager.get('array').length).assertEqual(3);
    });
  });
}
