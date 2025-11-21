import { Transaction } from '../models/Transaction';
import { TransactionCard } from './TransactionCard';
import promptAction from '@ohos.promptAction';

/**
 * TransactionList Component
 * 交易列表组件
 * 支持虚拟滚动、侧滑删除、空状态显示
 * 需求：1.2, 1.3, 3.1, 3.3, 3.5, 5.6, 7.3
 */
@Component
export struct TransactionList {
  @Link transactions: Transaction[];
  @Prop showDate: boolean = false; // Whether to show full date
  @Prop emptyMessage: string = '暂无交易记录';
  @Prop emptyIcon: string = '📝';
  onDelete?: (transaction: Transaction) => void;
  
  @State deleteDialogVisible: boolean = false;
  @State transactionToDelete: Transaction | null = null;

  /**
   * Handle swipe delete action
   * 需求：1.2 - 侧滑删除
   */
  private handleSwipeDelete(transaction: Transaction) {
    this.transactionToDelete = transaction;
    this.deleteDialogVisible = true;
  }

  /**
   * Confirm delete action
   * 需求：1.3 - 确认删除
   */
  private confirmDelete() {
    if (this.transactionToDelete && this.onDelete) {
      this.onDelete(this.transactionToDelete);
      
      // Show success toast
      promptAction.showToast({
        message: '删除成功',
        duration: 2000
      });
    }
    
    this.deleteDialogVisible = false;
    this.transactionToDelete = null;
  }

  /**
   * Cancel delete action
   */
  private cancelDelete() {
    this.deleteDialogVisible = false;
    this.transactionToDelete = null;
  }

  /**
   * Build UI
   */
  build() {
    Column() {
      if (this.transactions.length === 0) {
        // Empty state (需求 5.6)
        this.buildEmptyView();
      } else {
        // Transaction list with virtual scrolling
        this.buildTransactionList();
      }
      
      // Delete confirmation dialog
      if (this.deleteDialogVisible) {
        this.buildDeleteDialog();
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * Build transaction list with swipe-to-delete
   * 支持虚拟滚动 (需求 3.1, 3.3)
   * 性能优化：增加缓存数量，启用懒加载
   */
  @Builder
  buildTransactionList() {
    List({ space: 8 }) {
      ForEach(this.transactions, (transaction: Transaction) => {
        ListItem() {
          TransactionCard({ 
            transaction: transaction,
            showDate: this.showDate
          })
        }
        .swipeAction({ end: this.buildSwipeDeleteButton(transaction) })
      }, (transaction: Transaction) => transaction.id.toString())
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .scrollBar(BarState.Auto)
    .cachedCount(10) // Virtual scrolling optimization - increased cache
    .edgeEffect(EdgeEffect.Spring) // Smooth scrolling effect
  }

  /**
   * Build swipe delete button
   * 需求：1.2 - 侧滑删除功能
   */
  @Builder
  buildSwipeDeleteButton(transaction: Transaction) {
    Button({ type: ButtonType.Normal }) {
      Text('删除')
        .fontSize(16)
        .fontColor(Color.White)
    }
    .width(80)
    .height('100%')
    .backgroundColor('#FF4D4F')
    .borderRadius(8)
    .onClick(() => {
      this.handleSwipeDelete(transaction);
    })
  }

  /**
   * Build empty view
   * 需求：5.6 - 空状态显示
   */
  @Builder
  buildEmptyView() {
    Column() {
      Text(this.emptyIcon)
        .fontSize(48)
      
      Text(this.emptyMessage)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build delete confirmation dialog
   * 需求：1.3 - 删除确认对话框
   */
  @Builder
  buildDeleteDialog() {
    Column() {
      // Overlay background
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.cancelDelete();
        })
      
      // Dialog content
      Column() {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 16 })
        
        if (this.transactionToDelete) {
          Text(`确定要删除这条${this.transactionToDelete.category}记录吗？`)
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 24 })
        }
        
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .onClick(() => {
              this.cancelDelete();
            })
          
          Button('删除')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .layoutWeight(1)
            .onClick(() => {
              this.confirmDelete();
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .position({ x: '10%', y: '40%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }
}
