/**
 * LineChart Component
 * 折线图组件 - 使用Canvas绘制
 */

export interface LineChartData {
  labels: string[];
  values: number[];
  colors?: string[];
}

export interface LineChartPoint {
  x: number;
  y: number;
  value: number;
  label: string;
}

@Component
export struct LineChart {
  @Prop chartData: LineChartData;
  @Prop width: number = 350;
  @Prop height: number = 250;
  @State selectedPoint: number = -1;
  @State points: LineChartPoint[] = [];
  
  private canvasContext: CanvasRenderingContext2D | null = null;
  private padding = { top: 20, right: 20, bottom: 40, left: 50 };
  private chartWidth: number = 0;
  private chartHeight: number = 0;
  private minValue: number = 0;
  private maxValue: number = 0;
  private lineColor: string = '#4CAF50';
  private renderTimer: number = -1;

  aboutToAppear() {
    this.calculatePoints();
  }

  aboutToDisappear() {
    // Clean up timer
    if (this.renderTimer !== -1) {
      clearTimeout(this.renderTimer);
    }
  }

  /**
   * Calculate point positions
   */
  private calculatePoints() {
    if (!this.chartData || !this.chartData.values || this.chartData.values.length === 0) {
      this.points = [];
      return;
    }

    this.chartWidth = this.width - this.padding.left - this.padding.right;
    this.chartHeight = this.height - this.padding.top - this.padding.bottom;

    // Find min and max values for scaling
    this.minValue = Math.min(...this.chartData.values, 0);
    this.maxValue = Math.max(...this.chartData.values);
    
    // Add some padding to max value
    const valueRange = this.maxValue - this.minValue;
    this.maxValue += valueRange * 0.1;
    this.minValue -= valueRange * 0.1;

    // Calculate points
    const points: LineChartPoint[] = [];
    const stepX = this.chartWidth / Math.max(this.chartData.values.length - 1, 1);

    this.chartData.values.forEach((value, index) => {
      const x = this.padding.left + (index * stepX);
      const normalizedValue = (value - this.minValue) / (this.maxValue - this.minValue);
      const y = this.padding.top + this.chartHeight - (normalizedValue * this.chartHeight);

      points.push({
        x: x,
        y: y,
        value: value,
        label: this.chartData.labels[index] || `${index + 1}`
      });
    });

    this.points = points;
    
    // Set line color based on data
    if (this.chartData.colors && this.chartData.colors.length > 0) {
      this.lineColor = this.chartData.colors[0];
    }
  }

  /**
   * Draw the line chart on canvas
   * 性能优化：使用debouncing优化渲染
   */
  private drawLineChart(context: CanvasRenderingContext2D) {
    if (!this.points || this.points.length === 0) {
      this.drawEmptyState(context);
      return;
    }

    // Debounce rendering to avoid excessive redraws
    if (this.renderTimer !== -1) {
      clearTimeout(this.renderTimer);
    }

    this.renderTimer = setTimeout(() => {
      this.performDraw(context);
      this.renderTimer = -1;
    }, 16); // ~60fps
  }

  /**
   * Perform actual drawing
   */
  private performDraw(context: CanvasRenderingContext2D) {
    // Clear canvas
    context.clearRect(0, 0, this.width, this.height);

    // Draw grid and axes
    this.drawGrid(context);
    this.drawAxes(context);

    // Draw line
    this.drawLine(context);

    // Draw points
    this.drawPoints(context);

    // Draw selected point info
    if (this.selectedPoint >= 0 && this.selectedPoint < this.points.length) {
      this.drawSelectedPointInfo(context);
    }
  }

  /**
   * Draw grid lines
   */
  private drawGrid(context: CanvasRenderingContext2D) {
    context.strokeStyle = '#E0E0E0';
    context.lineWidth = 1;

    // Horizontal grid lines
    const gridLines = 5;
    for (let i = 0; i <= gridLines; i++) {
      const y = this.padding.top + (this.chartHeight / gridLines) * i;
      context.beginPath();
      context.moveTo(this.padding.left, y);
      context.lineTo(this.padding.left + this.chartWidth, y);
      context.stroke();
    }

    // Vertical grid lines (optional, for better readability)
    const verticalLines = Math.min(this.points.length - 1, 10);
    if (verticalLines > 0) {
      for (let i = 0; i <= verticalLines; i++) {
        const x = this.padding.left + (this.chartWidth / verticalLines) * i;
        context.beginPath();
        context.moveTo(x, this.padding.top);
        context.lineTo(x, this.padding.top + this.chartHeight);
        context.stroke();
      }
    }
  }

  /**
   * Draw axes
   */
  private drawAxes(context: CanvasRenderingContext2D) {
    context.strokeStyle = '#333333';
    context.lineWidth = 2;

    // Y-axis
    context.beginPath();
    context.moveTo(this.padding.left, this.padding.top);
    context.lineTo(this.padding.left, this.padding.top + this.chartHeight);
    context.stroke();

    // X-axis
    context.beginPath();
    context.moveTo(this.padding.left, this.padding.top + this.chartHeight);
    context.lineTo(this.padding.left + this.chartWidth, this.padding.top + this.chartHeight);
    context.stroke();

    // Y-axis labels
    this.drawYAxisLabels(context);

    // X-axis labels
    this.drawXAxisLabels(context);
  }

  /**
   * Draw Y-axis labels
   */
  private drawYAxisLabels(context: CanvasRenderingContext2D) {
    context.fillStyle = '#666666';
    context.font = '10px sans-serif';
    context.textAlign = 'right';
    context.textBaseline = 'middle';

    const labelCount = 5;
    for (let i = 0; i <= labelCount; i++) {
      const value = this.minValue + ((this.maxValue - this.minValue) / labelCount) * (labelCount - i);
      const y = this.padding.top + (this.chartHeight / labelCount) * i;
      context.fillText(value.toFixed(0), this.padding.left - 5, y);
    }
  }

  /**
   * Draw X-axis labels
   */
  private drawXAxisLabels(context: CanvasRenderingContext2D) {
    context.fillStyle = '#666666';
    context.font = '10px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'top';

    // Show labels for every few points to avoid crowding
    const labelInterval = Math.ceil(this.points.length / 8);
    
    this.points.forEach((point, index) => {
      if (index % labelInterval === 0 || index === this.points.length - 1) {
        // Truncate long labels
        let label = point.label;
        if (label.length > 10) {
          label = label.substring(5); // Show last part of date
        }
        context.fillText(label, point.x, this.padding.top + this.chartHeight + 5);
      }
    });
  }

  /**
   * Draw the line connecting points
   */
  private drawLine(context: CanvasRenderingContext2D) {
    if (this.points.length < 2) {
      return;
    }

    context.strokeStyle = this.lineColor;
    context.lineWidth = 2;
    context.beginPath();

    this.points.forEach((point, index) => {
      if (index === 0) {
        context.moveTo(point.x, point.y);
      } else {
        context.lineTo(point.x, point.y);
      }
    });

    context.stroke();

    // Fill area under line (optional gradient effect)
    context.lineTo(this.points[this.points.length - 1].x, this.padding.top + this.chartHeight);
    context.lineTo(this.points[0].x, this.padding.top + this.chartHeight);
    context.closePath();
    
    context.fillStyle = this.lineColor + '20'; // Add transparency
    context.fill();
  }

  /**
   * Draw data points
   */
  private drawPoints(context: CanvasRenderingContext2D) {
    this.points.forEach((point, index) => {
      const isSelected = index === this.selectedPoint;
      const radius = isSelected ? 6 : 4;

      context.beginPath();
      context.arc(point.x, point.y, radius, 0, 2 * Math.PI);
      context.fillStyle = isSelected ? '#FF5722' : this.lineColor;
      context.fill();
      
      context.strokeStyle = '#FFFFFF';
      context.lineWidth = 2;
      context.stroke();
    });
  }

  /**
   * Draw selected point information
   */
  private drawSelectedPointInfo(context: CanvasRenderingContext2D) {
    const point = this.points[this.selectedPoint];
    
    // Draw tooltip box
    const tooltipText = `${point.label}: ¥${point.value.toFixed(2)}`;
    context.font = '12px sans-serif';
    const textWidth = context.measureText(tooltipText).width;
    
    const boxWidth = textWidth + 16;
    const boxHeight = 30;
    let boxX = point.x - boxWidth / 2;
    let boxY = point.y - boxHeight - 10;
    
    // Adjust if tooltip goes off screen
    if (boxX < 0) boxX = 0;
    if (boxX + boxWidth > this.width) boxX = this.width - boxWidth;
    if (boxY < 0) boxY = point.y + 10;

    // Draw box
    context.fillStyle = 'rgba(0, 0, 0, 0.8)';
    context.fillRect(boxX, boxY, boxWidth, boxHeight);

    // Draw text
    context.fillStyle = '#FFFFFF';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(tooltipText, boxX + boxWidth / 2, boxY + boxHeight / 2);
  }

  /**
   * Draw empty state
   */
  private drawEmptyState(context: CanvasRenderingContext2D) {
    context.clearRect(0, 0, this.width, this.height);
    context.fillStyle = '#999999';
    context.font = '16px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText('暂无数据', this.width / 2, this.height / 2);
  }

  /**
   * Handle touch/click on canvas
   */
  private handleCanvasClick(x: number, y: number) {
    if (!this.points || this.points.length === 0) {
      return;
    }

    // Find nearest point
    let nearestIndex = -1;
    let minDistance = Infinity;

    this.points.forEach((point, index) => {
      const distance = Math.sqrt(Math.pow(x - point.x, 2) + Math.pow(y - point.y, 2));
      if (distance < minDistance && distance < 20) { // 20px threshold
        minDistance = distance;
        nearestIndex = index;
      }
    });

    this.selectedPoint = nearestIndex;
  }

  build() {
    Column() {
      // Canvas for line chart
      Canvas(this.canvasContext)
        .width(this.width)
        .height(this.height)
        .onReady(() => {
          if (this.canvasContext) {
            this.drawLineChart(this.canvasContext);
          }
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            const touch = event.touches[0];
            this.handleCanvasClick(touch.x, touch.y);
            if (this.canvasContext) {
              this.drawLineChart(this.canvasContext);
            }
          }
        })

      // Chart info
      if (this.points && this.points.length > 0) {
        Row({ space: 16 }) {
          Column({ space: 4 }) {
            Text('数据点数')
              .fontSize(12)
              .fontColor('#666666')
            Text(`${this.points.length}`)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
          }

          Column({ space: 4 }) {
            Text('最大值')
              .fontSize(12)
              .fontColor('#666666')
            Text(`¥${Math.max(...this.chartData.values).toFixed(2)}`)
              .fontSize(16)
              .fontColor('#4CAF50')
              .fontWeight(FontWeight.Bold)
          }

          Column({ space: 4 }) {
            Text('最小值')
              .fontSize(12)
              .fontColor('#666666')
            Text(`¥${Math.min(...this.chartData.values).toFixed(2)}`)
              .fontSize(16)
              .fontColor('#F44336')
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ top: 16 })
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
      }
    }
    .width('100%')
  }
}
