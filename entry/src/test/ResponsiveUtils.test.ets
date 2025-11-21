import { describe, it, expect } from '@ohos/hypium';
import { ResponsiveUtils, DeviceType, ScreenOrientation, Breakpoints } from '../main/ets/utils/ResponsiveUtils';

/**
 * ResponsiveUtils Test Suite
 * 测试响应式布局工具
 * 需求：10.1, 10.2, 10.4, 10.5
 */
export default function responsiveUtilsTest() {
  describe('ResponsiveUtils', () => {
    /**
     * Test device type detection
     * 需求：10.1, 10.2
     */
    it('should detect phone device type for small screens', () => {
      const deviceType = ResponsiveUtils.getDeviceType(360);
      expect(deviceType).assertEqual(DeviceType.PHONE);
    });

    it('should detect tablet device type for medium screens', () => {
      const deviceType = ResponsiveUtils.getDeviceType(700);
      expect(deviceType).assertEqual(DeviceType.TABLET);
    });

    it('should detect desktop device type for large screens', () => {
      const deviceType = ResponsiveUtils.getDeviceType(1000);
      expect(deviceType).assertEqual(DeviceType.DESKTOP);
    });

    /**
     * Test screen orientation detection
     */
    it('should detect portrait orientation', () => {
      const orientation = ResponsiveUtils.getOrientation(360, 780);
      expect(orientation).assertEqual(ScreenOrientation.PORTRAIT);
    });

    it('should detect landscape orientation', () => {
      const orientation = ResponsiveUtils.getOrientation(780, 360);
      expect(orientation).assertEqual(ScreenOrientation.LANDSCAPE);
    });

    /**
     * Test responsive configuration
     * 需求：10.1, 10.2
     */
    it('should return single column config for phone', () => {
      const config = ResponsiveUtils.getResponsiveConfig(360, 780);
      expect(config.deviceType).assertEqual(DeviceType.PHONE);
      expect(config.columns).assertEqual(1);
      expect(config.useSidebar).assertEqual(false);
    });

    it('should return multi-column config for tablet portrait', () => {
      const config = ResponsiveUtils.getResponsiveConfig(700, 1000);
      expect(config.deviceType).assertEqual(DeviceType.TABLET);
      expect(config.columns).assertEqual(2);
      expect(config.useSidebar).assertEqual(false);
    });

    it('should return sidebar config for tablet landscape', () => {
      const config = ResponsiveUtils.getResponsiveConfig(1000, 700);
      expect(config.deviceType).assertEqual(DeviceType.TABLET);
      expect(config.columns).assertEqual(3);
      expect(config.useSidebar).assertEqual(true);
    });

    /**
     * Test chart sizing
     * 需求：10.4
     */
    it('should return appropriate chart size for phone', () => {
      const chartSize = ResponsiveUtils.getChartSize(360, 780);
      expect(chartSize.width).assertLarger(0);
      expect(chartSize.height).assertLarger(0);
      expect(chartSize.width).assertLessOrEqual(360);
    });

    it('should return larger chart size for tablet', () => {
      const phoneSize = ResponsiveUtils.getChartSize(360, 780);
      const tabletSize = ResponsiveUtils.getChartSize(700, 1000);
      expect(tabletSize.width).assertLarger(phoneSize.width);
    });

    /**
     * Test sidebar width
     * 需求：10.5
     */
    it('should return zero sidebar width for phone', () => {
      const sidebarWidth = ResponsiveUtils.getSidebarWidth(360);
      expect(sidebarWidth).assertEqual(0);
    });

    it('should return non-zero sidebar width for tablet', () => {
      const sidebarWidth = ResponsiveUtils.getSidebarWidth(700);
      expect(sidebarWidth).assertLarger(0);
    });

    /**
     * Test helper methods
     */
    it('should correctly identify phone screens', () => {
      expect(ResponsiveUtils.isPhone(360)).assertTrue();
      expect(ResponsiveUtils.isPhone(700)).assertFalse();
    });

    it('should correctly identify tablet screens', () => {
      expect(ResponsiveUtils.isTablet(700)).assertTrue();
      expect(ResponsiveUtils.isTablet(360)).assertFalse();
    });

    it('should correctly identify landscape orientation', () => {
      expect(ResponsiveUtils.isLandscape(1000, 700)).assertTrue();
      expect(ResponsiveUtils.isLandscape(700, 1000)).assertFalse();
    });

    it('should correctly identify portrait orientation', () => {
      expect(ResponsiveUtils.isPortrait(700, 1000)).assertTrue();
      expect(ResponsiveUtils.isPortrait(1000, 700)).assertFalse();
    });

    /**
     * Test responsive value selection
     */
    it('should return phone value for phone screen', () => {
      const value = ResponsiveUtils.responsive(360, {
        phone: 'small',
        tablet: 'medium',
        desktop: 'large'
      });
      expect(value).assertEqual('small');
    });

    it('should return tablet value for tablet screen', () => {
      const value = ResponsiveUtils.responsive(700, {
        phone: 'small',
        tablet: 'medium',
        desktop: 'large'
      });
      expect(value).assertEqual('medium');
    });

    it('should fallback to phone value if tablet not specified', () => {
      const value = ResponsiveUtils.responsive(700, {
        phone: 'small',
        desktop: 'large'
      });
      expect(value).assertEqual('small');
    });

    /**
     * Test grid columns
     */
    it('should return correct grid columns for different devices', () => {
      const phoneColumns = ResponsiveUtils.getGridColumns(360, 780);
      const tabletColumns = ResponsiveUtils.getGridColumns(700, 1000);
      
      expect(phoneColumns).assertEqual(1);
      expect(tabletColumns).assertLarger(phoneColumns);
    });

    /**
     * Test compact layout detection
     */
    it('should use compact layout for phone', () => {
      expect(ResponsiveUtils.shouldUseCompactLayout(360)).assertTrue();
    });

    it('should not use compact layout for tablet', () => {
      expect(ResponsiveUtils.shouldUseCompactLayout(700)).assertFalse();
    });

    /**
     * Test scaling factors
     */
    it('should return appropriate font scale for different devices', () => {
      const phoneScale = ResponsiveUtils.getFontScale(360);
      const tabletScale = ResponsiveUtils.getFontScale(700);
      
      expect(phoneScale).assertEqual(1.0);
      expect(tabletScale).assertLarger(phoneScale);
    });

    it('should return appropriate spacing scale for different devices', () => {
      const phoneScale = ResponsiveUtils.getSpacingScale(360);
      const tabletScale = ResponsiveUtils.getSpacingScale(700);
      
      expect(phoneScale).assertEqual(1.0);
      expect(tabletScale).assertLarger(phoneScale);
    });
  });
}
