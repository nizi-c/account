import localUnitTest from './LocalUnit.test';
import categoryServiceTest from './CategoryService.test';
import statisticsServiceTest from './StatisticsService.test';
import achievementServiceTest from './AchievementService.test';
import utilsTest from './Utils.test';
import transactionListTest from './TransactionList.test';
import achievementPageTest from './AchievementPage.test';
import responsiveUtilsTest from './ResponsiveUtils.test';
import cacheManagerTest from './CacheManager.test';
import initializationServiceTest from './InitializationService.test';
import exportServiceTest from './ExportService.test';
import integrationTest from './Integration.test';

export default function testsuite() {
  localUnitTest();
  categoryServiceTest();
  statisticsServiceTest();
  achievementServiceTest();
  utilsTest();
  transactionListTest();
  achievementPageTest();
  responsiveUtilsTest();
  cacheManagerTest();
  initializationServiceTest();
  exportServiceTest();
  integrationTest();
}