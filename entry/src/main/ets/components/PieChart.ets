/**
 * PieChart Component
 * 饼图组件 - 使用Canvas绘制
 */

export interface PieChartData {
  labels: string[];
  values: number[];
  colors?: string[];
}

export interface PieChartSegment {
  label: string;
  value: number;
  color: string;
  startAngle: number;
  endAngle: number;
  percentage: number;
}

@Component
export struct PieChart {
  @Prop chartData: PieChartData;
  @Prop chartWidth: number = 300;
  @Prop chartHeight: number = 300;
  @State selectedSegment: number = -1;
  @State segments: PieChartSegment[] = [];
  
  private canvasContext: CanvasRenderingContext2D | null = null;
  private centerX: number = 0;
  private centerY: number = 0;
  private radius: number = 0;
  private renderTimer: number = -1;
  
  // Default colors if not provided
  private defaultColors: string[] = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A',
    '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2',
    '#F8B739', '#52B788'
  ];

  aboutToAppear() {
    this.calculateSegments();
  }

  aboutToDisappear() {
    // Clean up timer
    if (this.renderTimer !== -1) {
      clearTimeout(this.renderTimer);
    }
  }

  /**
   * Calculate segment angles and percentages
   */
  private calculateSegments() {
    if (!this.chartData || !this.chartData.values || this.chartData.values.length === 0) {
      this.segments = [];
      return;
    }

    const total = this.chartData.values.reduce((sum, val) => sum + val, 0);
    
    if (total === 0) {
      this.segments = [];
      return;
    }

    let currentAngle = -Math.PI / 2; // Start from top
    const segments: PieChartSegment[] = [];

    this.chartData.values.forEach((value, index) => {
      const percentage = (value / total) * 100;
      const angleSize = (value / total) * 2 * Math.PI;
      const endAngle = currentAngle + angleSize;

      const color = this.chartData.colors && this.chartData.colors[index]
        ? this.chartData.colors[index]
        : this.defaultColors[index % this.defaultColors.length];

      segments.push({
        label: this.chartData.labels[index] || `Item ${index + 1}`,
        value: value,
        color: color,
        startAngle: currentAngle,
        endAngle: endAngle,
        percentage: percentage
      });

      currentAngle = endAngle;
    });

    this.segments = segments;
  }

  /**
   * Draw the pie chart on canvas
   * 性能优化：使用requestAnimationFrame优化渲染
   */
  private drawPieChart(context: CanvasRenderingContext2D) {
    if (!this.segments || this.segments.length === 0) {
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
    context.clearRect(0, 0, this.chartWidth, this.chartHeight);

    // Calculate dimensions
    this.centerX = this.chartWidth / 2;
    this.centerY = this.chartHeight / 2;
    this.radius = Math.min(this.chartWidth, this.chartHeight) * 0.35;

    // Draw each segment
    this.segments.forEach((segment, index) => {
      this.drawSegment(context, segment, index === this.selectedSegment);
    });

    // Draw center circle for donut effect (optional)
    // this.drawCenterCircle(context);
  }

  /**
   * Draw a single pie segment
   */
  private drawSegment(context: CanvasRenderingContext2D, segment: PieChartSegment, isSelected: boolean) {
    const radius = isSelected ? this.radius * 1.1 : this.radius;

    context.beginPath();
    context.moveTo(this.centerX, this.centerY);
    context.arc(this.centerX, this.centerY, radius, segment.startAngle, segment.endAngle);
    context.closePath();

    context.fillStyle = segment.color;
    context.fill();

    // Draw border
    context.strokeStyle = '#FFFFFF';
    context.lineWidth = 2;
    context.stroke();

    // Draw label if segment is large enough
    if (segment.percentage > 5) {
      this.drawSegmentLabel(context, segment);
    }
  }

  /**
   * Draw label on segment
   */
  private drawSegmentLabel(context: CanvasRenderingContext2D, segment: PieChartSegment) {
    const midAngle = (segment.startAngle + segment.endAngle) / 2;
    const labelRadius = this.radius * 0.7;
    const x = this.centerX + Math.cos(midAngle) * labelRadius;
    const y = this.centerY + Math.sin(midAngle) * labelRadius;

    context.fillStyle = '#FFFFFF';
    context.font = '12px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(`${segment.percentage.toFixed(1)}%`, x, y);
  }

  /**
   * Draw empty state
   */
  private drawEmptyState(context: CanvasRenderingContext2D) {
    context.clearRect(0, 0, this.chartWidth, this.chartHeight);
    context.fillStyle = '#999999';
    context.font = '16px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText('暂无数据', this.chartWidth / 2, this.chartHeight / 2);
  }

  /**
   * Handle touch/click on canvas
   */
  private handleCanvasClick(x: number, y: number) {
    if (!this.segments || this.segments.length === 0) {
      return;
    }

    // Calculate distance from center
    const dx = x - this.centerX;
    const dy = y - this.centerY;
    const distance = Math.sqrt(dx * dx + dy * dy);

    // Check if click is within pie radius
    if (distance > this.radius * 1.1) {
      this.selectedSegment = -1;
      return;
    }

    // Calculate angle of click
    let angle = Math.atan2(dy, dx);
    
    // Normalize angle to match our start angle (-PI/2)
    angle = angle + Math.PI / 2;
    if (angle < 0) {
      angle += 2 * Math.PI;
    }

    // Find which segment was clicked
    for (let i = 0; i < this.segments.length; i++) {
      const segment = this.segments[i];
      let startAngle = segment.startAngle + Math.PI / 2;
      let endAngle = segment.endAngle + Math.PI / 2;
      
      if (startAngle < 0) startAngle += 2 * Math.PI;
      if (endAngle < 0) endAngle += 2 * Math.PI;
      
      // Handle wrap-around
      if (startAngle > endAngle) {
        if (angle >= startAngle || angle <= endAngle) {
          this.selectedSegment = i;
          return;
        }
      } else {
        if (angle >= startAngle && angle <= endAngle) {
          this.selectedSegment = i;
          return;
        }
      }
    }

    this.selectedSegment = -1;
  }

  build() {
    Column() {
      // Canvas for pie chart
      Canvas(this.canvasContext)
        .width(this.chartWidth)
        .height(this.chartHeight)
        .onReady(() => {
          if (this.canvasContext) {
            this.drawPieChart(this.canvasContext);
          }
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            const touch = event.touches[0];
            this.handleCanvasClick(touch.x, touch.y);
            if (this.canvasContext) {
              this.drawPieChart(this.canvasContext);
            }
          }
        })

      // Legend
      if (this.segments && this.segments.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.segments, (segment: PieChartSegment, index: number) => {
            Row({ space: 8 }) {
              // Color indicator
              Row()
                .width(16)
                .height(16)
                .backgroundColor(segment.color)
                .borderRadius(2)

              // Label and value
              Column({ space: 2 }) {
                Text(segment.label)
                  .fontSize(14)
                  .fontColor('#333333')
                  .fontWeight(this.selectedSegment === index ? FontWeight.Bold : FontWeight.Normal)
                
                Text(`¥${segment.value.toFixed(2)} (${segment.percentage.toFixed(1)}%)`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(8)
            .backgroundColor(this.selectedSegment === index ? '#F5F5F5' : '#FFFFFF')
            .borderRadius(4)
            .onClick(() => {
              this.selectedSegment = index;
              if (this.canvasContext) {
                this.drawPieChart(this.canvasContext);
              }
            })
          })
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
  }
}
