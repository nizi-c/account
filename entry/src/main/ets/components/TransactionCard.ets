import { Transaction, TransactionType, MoodType } from '../models/Transaction';
import { DateUtils } from '../utils/DateUtils';
import { FormatUtils } from '../utils/FormatUtils';

/**
 * TransactionCard Component
 * 交易记录卡片组件
 * 需求：1.2, 3.1, 7.3
 */
@Component
export struct TransactionCard {
  @Prop transaction: Transaction;
  @Prop showDate: boolean = false; // Whether to show full date (for non-daily views)
  
  /**
   * Get mood emoji
   */
  private getMoodEmoji(mood?: MoodType): string {
    if (!mood) return '';
    switch (mood) {
      case MoodType.SATISFIED:
        return '😊';
      case MoodType.REGRET:
        return '😟';
      case MoodType.SURPRISE:
        return '🎉';
      default:
        return '';
    }
  }

  /**
   * Build UI
   */
  build() {
    Row() {
      // Left side - transaction info
      Column({ space: 4 }) {
        // Category and mood
        Row() {
          Text(this.transaction.category)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          // Mood icon display (需求 7.3)
          if (this.transaction.mood) {
            Text(this.getMoodEmoji(this.transaction.mood))
              .fontSize(16)
              .margin({ left: 4 })
          }
        }
        
        // Description
        Text(this.transaction.description)
          .fontSize(14)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        // Time or date
        Text(this.showDate 
          ? DateUtils.formatDate(this.transaction.date, 'YYYY-MM-DD HH:mm')
          : DateUtils.formatDateTime(this.transaction.date, 'HH:mm')
        )
          .fontSize(12)
          .fontColor('#CCCCCC')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // Right side - amount
      Text(
        (this.transaction.type === TransactionType.INCOME ? '+' : '-') +
        FormatUtils.formatCurrency(this.transaction.amount)
      )
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.transaction.type === TransactionType.INCOME ? '#52C41A' : '#FF4D4F')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
