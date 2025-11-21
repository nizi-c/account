import { TransactionRepository, CategoryRepository, AchievementRepository, BudgetRepository } from '../repositories';
import { ExportData, Transaction, MoodType, TransactionType, Budget } from '../models';
import { DateUtils } from '../utils/DateUtils';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

/**
 * Export Service
 * 数据导出业务逻辑层
 */
export class ExportService {
  private transactionRepo: TransactionRepository;
  private categoryRepo: CategoryRepository;
  private achievementRepo: AchievementRepository;
  private budgetRepo: BudgetRepository;
  private context?: common.UIAbilityContext;

  constructor(
    transactionRepo: TransactionRepository,
    categoryRepo: CategoryRepository,
    achievementRepo: AchievementRepository,
    budgetRepo: BudgetRepository,
    context?: common.UIAbilityContext
  ) {
    this.transactionRepo = transactionRepo;
    this.categoryRepo = categoryRepo;
    this.achievementRepo = achievementRepo;
    this.budgetRepo = budgetRepo;
    this.context = context;
  }

  /**
   * Export to CSV format with optional date range filtering
   * 导出为CSV格式（支持日期范围过滤）
   * @param startDate - Optional start date timestamp
   * @param endDate - Optional end date timestamp
   * @returns CSV content as string
   */
  async exportToCSV(startDate?: number, endDate?: number): Promise<string> {
    try {
      // Get transactions with optional date filtering
      let transactions: Transaction[];
      
      if (startDate !== undefined && endDate !== undefined) {
        transactions = await this.transactionRepo.getByDateRange(startDate, endDate);
      } else {
        transactions = await this.transactionRepo.getAll();
      }

      // Generate CSV content
      const csvContent = this.generateCSVContent(transactions);
      
      return csvContent;
    } catch (error) {
      console.error('Error exporting to CSV:', error);
      throw new Error(`CSV导出失败: ${error.message || '未知错误'}`);
    }
  }

  /**
   * Export to JSON format with optional date range filtering
   * 导出为JSON格式（支持日期范围过滤）
   * @param startDate - Optional start date timestamp
   * @param endDate - Optional end date timestamp
   * @returns ExportData object
   */
  async exportToJSON(startDate?: number, endDate?: number): Promise<ExportData> {
    try {
      // Get transactions with optional date filtering
      let transactions: Transaction[];
      
      if (startDate !== undefined && endDate !== undefined) {
        transactions = await this.transactionRepo.getByDateRange(startDate, endDate);
      } else {
        transactions = await this.transactionRepo.getAll();
      }

      // Get categories and achievements (always include all)
      const categories = await this.categoryRepo.getAll();
      const achievements = await this.achievementRepo.getAll();
      
      // Get budgets (optional, may not exist)
      let budgets: Budget[] = [];
      try {
        budgets = await this.budgetRepo.getAll();
      } catch (error) {
        console.warn('Failed to get budgets for export:', error);
      }

      // Create export data object
      const exportData: ExportData = {
        version: '1.0.0',
        exportDate: Date.now(),
        transactions: transactions,
        categories: categories,
        achievements: achievements,
        budgets: budgets.length > 0 ? budgets : undefined
      };

      return exportData;
    } catch (error) {
      console.error('Error exporting to JSON:', error);
      throw new Error(`JSON导出失败: ${error.message || '未知错误'}`);
    }
  }

  /**
   * Generate CSV content from transactions
   * 生成CSV内容（包含表头：日期、类型、分类、金额、用途、情绪）
   * @param transactions - Array of transactions
   * @returns CSV formatted string
   */
  generateCSVContent(transactions: Transaction[]): string {
    // CSV header
    const header = '日期,类型,分类,金额,用途,情绪\n';
    
    // Convert transactions to CSV rows
    const rows = transactions.map(transaction => {
      const date = DateUtils.formatDate(transaction.date, 'YYYY-MM-DD');
      const type = transaction.type === TransactionType.INCOME ? '收入' : '支出';
      const category = this.escapeCsvField(transaction.category);
      const amount = transaction.amount.toFixed(2);
      const description = this.escapeCsvField(transaction.description);
      const mood = this.getMoodLabel(transaction.mood);
      
      return `${date},${type},${category},${amount},${description},${mood}`;
    });

    return header + rows.join('\n');
  }

  /**
   * Generate full backup including all data
   * 生成完整备份（包含交易、分类、成就、预算）
   * @returns ExportData object with all data
   */
  async generateFullBackup(): Promise<ExportData> {
    try {
      // Get all data
      const transactions = await this.transactionRepo.getAll();
      const categories = await this.categoryRepo.getAll();
      const achievements = await this.achievementRepo.getAll();
      
      // Get budgets (optional)
      let budgets: Budget[] = [];
      try {
        budgets = await this.budgetRepo.getAll();
      } catch (error) {
        console.warn('Failed to get budgets for backup:', error);
      }

      // Create full backup data
      const backupData: ExportData = {
        version: '1.0.0',
        exportDate: Date.now(),
        transactions: transactions,
        categories: categories,
        achievements: achievements,
        budgets: budgets.length > 0 ? budgets : undefined
      };

      return backupData;
    } catch (error) {
      console.error('Error generating full backup:', error);
      throw new Error(`完整备份生成失败: ${error.message || '未知错误'}`);
    }
  }

  /**
   * Save export file to user accessible directory
   * 保存导出文件到用户可访问目录
   * @param content - File content (string or JSON)
   * @param filename - File name
   * @param format - File format ('csv' or 'json')
   * @returns File path where the file was saved
   */
  async saveExportFile(content: string, filename: string, format: 'csv' | 'json'): Promise<string> {
    try {
      if (!this.context) {
        throw new Error('Context未初始化，无法保存文件');
      }

      // Get files directory (user accessible)
      const filesDir = this.context.filesDir;
      
      // Ensure filename has correct extension
      const extension = format === 'csv' ? '.csv' : '.json';
      const finalFilename = filename.endsWith(extension) ? filename : `${filename}${extension}`;
      
      // Full file path
      const filePath = `${filesDir}/${finalFilename}`;

      // Write file with retry logic
      let retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          // Open file for writing (create if not exists, truncate if exists)
          const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC | fileIo.OpenMode.WRITE_ONLY);
          
          // Write content
          fileIo.writeSync(file.fd, content);
          
          // Close file
          fileIo.closeSync(file);
          
          console.info(`File saved successfully: ${filePath}`);
          return filePath;
        } catch (writeError) {
          retryCount++;
          console.error(`Write attempt ${retryCount} failed:`, writeError);
          
          if (retryCount >= maxRetries) {
            throw new Error(`File write failed after ${maxRetries} attempts: ${writeError}`);
          }
          
          // Wait before retry (exponential backoff)
          await this.delay(100 * Math.pow(2, retryCount - 1));
        }
      }

      throw new Error('文件保存失败，已达到最大重试次数');
    } catch (error) {
      console.error('Error saving export file:', error);
      throw new Error(`文件保存失败: ${error.message || '未知错误'}`);
    }
  }

  /**
   * Escape CSV field (handle commas, quotes, newlines)
   * 转义CSV字段
   * @param field - Field value
   * @returns Escaped field value
   */
  private escapeCsvField(field: string): string {
    if (!field) {
      return '';
    }
    
    // If field contains comma, quote, or newline, wrap in quotes and escape quotes
    if (field.includes(',') || field.includes('"') || field.includes('\n')) {
      return `"${field.replace(/"/g, '""')}"`;
    }
    
    return field;
  }

  /**
   * Get mood label in Chinese
   * 获取情绪标签中文
   * @param mood - Mood type
   * @returns Chinese mood label
   */
  private getMoodLabel(mood?: MoodType): string {
    if (!mood) {
      return '';
    }
    
    switch (mood) {
      case MoodType.SATISFIED:
        return '满意😊';
      case MoodType.REGRET:
        return '后悔😟';
      case MoodType.SURPRISE:
        return '惊喜🎉';
      default:
        return '';
    }
  }

  /**
   * Delay helper for retry logic
   * 延迟辅助函数（用于重试逻辑）
   * @param ms - Milliseconds to delay
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
