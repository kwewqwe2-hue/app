/**
 * 专注日历 Tab 组件
 * 功能：月历显示、颜色标记专注记录、点击查看详情
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { DayRecord } from '../model/DataModels'

@Component
export struct CalendarTab {
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number
  @State currentYear: number = new Date().getFullYear()
  @State currentMonth: number = new Date().getMonth() + 1
  @State dayRecords: Map<string, DayRecord> = new Map()
  @State allRecords: DayRecord[] = []
  @State selectedDate: string = ''
  @State monthFocusMinutes: number = 0

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State calendarScale: number = 0
  @State calendarOpacity: number = 0
  @State statsScale: number = 0
  @State statsOpacity: number = 0

  aboutToAppear(): void {
    this.loadRecords()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadRecords()
  }

  private async loadRecords(): Promise<void> {
    this.allRecords = await PreferencesUtil.getDayRecords()
    this.dayRecords = new Map()
    this.monthFocusMinutes = 0

    let monthPrefix = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}`
    for (let record of this.allRecords) {
      this.dayRecords.set(record.date, record)
      if (record.date.startsWith(monthPrefix)) {
        this.monthFocusMinutes += record.totalMinutes
      }
    }
  }

  private playEntranceAnimation(): void {
    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 328, 34)
      }, () => {
        this.headerScale = 1
        this.headerOpacity = 1
      })
    }, 100)

    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.calendarScale = 1
        this.calendarOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.statsScale = 1
        this.statsOpacity = 1
      })
    }, 450)
  }

  // 获取当月天数
  private getDaysInMonth(): number {
    return new Date(this.currentYear, this.currentMonth, 0).getDate()
  }

  // 获取当月第一天是星期几 (0=周日)
  private getFirstDayOfWeek(): number {
    return new Date(this.currentYear, this.currentMonth - 1, 1).getDay()
  }

  // 切换月份
  private changeMonth(delta: number): void {
    let newMonth = this.currentMonth + delta
    if (newMonth > 12) {
      this.currentYear += 1
      this.currentMonth = 1
    } else if (newMonth < 1) {
      this.currentYear -= 1
      this.currentMonth = 12
    } else {
      this.currentMonth = newMonth
    }
    this.loadRecords()

    // 切换月份动画
    this.calendarScale = 0.9
    this.calendarOpacity = 0.5
    setTimeout(() => {
      animateTo({
        duration: 500,
        curve: curves.springCurve(0, 1, 320, 32)
      }, () => {
        this.calendarScale = 1
        this.calendarOpacity = 1
      })
    }, 50)
  }

  // 获取日期对应的颜色
  private getDayColor(day: number): ResourceColor {
    let dateStr = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    let record = this.dayRecords.get(dateStr)
    if (!record) {
      return Color.Transparent
    }
    if (record.totalMinutes >= 120) {
      return $r('app.color.calendar_heavy_record')
    } else if (record.totalMinutes >= 30) {
      return $r('app.color.calendar_has_record')
    } else {
      return $r('app.color.primary_green_light')
    }
  }

  // 判断是否是今天
  private isToday(day: number): boolean {
    let now = new Date()
    return this.currentYear === now.getFullYear() &&
      this.currentMonth === now.getMonth() + 1 &&
      day === now.getDate()
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('专注日历')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .padding({ left: 20, top: 16, bottom: 8 })
          .scale({ x: this.headerScale, y: this.headerScale })
          .opacity(this.headerOpacity)

        // 月份导航
        Row() {
          Button('<')
            .width(36)
            .height(36)
            .fontSize(18)
            .backgroundColor($r('app.color.bg_surface'))
            .fontColor($r('app.color.text_primary'))
            .borderRadius(18)
            .onClick(() => { this.changeMonth(-1) })

          Text(`${this.currentYear}年${this.currentMonth}月`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('>')
            .width(36)
            .height(36)
            .fontSize(18)
            .backgroundColor($r('app.color.bg_surface'))
            .fontColor($r('app.color.text_primary'))
            .borderRadius(18)
            .onClick(() => { this.changeMonth(1) })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 12 })
        .scale({ x: this.headerScale, y: this.headerScale })
        .opacity(this.headerOpacity)

        // 日历网格
        Column() {
          // 星期标题
          Row() {
            ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
              Text(day)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('14.28%')
                .textAlign(TextAlign.Center)
            })
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 日历格子
          Flex({ wrap: FlexWrap.Wrap }) {
            // 填充空白
            ForEach(Array.from({ length: this.getFirstDayOfWeek() }), (_: undefined, index: number) => {
              Column()
                .width('14.28%')
                .height(48)
            })

            // 日期格子
            ForEach(this.getDaysList(), (day: number) => {
              Column() {
                Stack() {
                  // 背景色标记
                  Circle()
                    .width(36)
                    .height(36)
                    .fill(this.getDayColor(day))

                  // 今天标记
                  if (this.isToday(day)) {
                    Circle()
                      .width(36)
                      .height(36)
                      .fill(Color.Transparent)
                      .border({ width: 2, color: $r('app.color.calendar_today') })
                  }

                  Text(`${day}`)
                    .fontSize(14)
                    .fontColor(this.isToday(day) ? $r('app.color.calendar_today') : $r('app.color.text_primary'))
                    .fontWeight(this.isToday(day) ? FontWeight.Bold : FontWeight.Normal)
                }
              }
              .width('14.28%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.onDayClick(day)
              })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ left: 16, right: 16 })
        .padding(16)
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(20)
        .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
        .scale({ x: this.calendarScale, y: this.calendarScale })
        .opacity(this.calendarOpacity)

        // 本月统计
        Column() {
          Text('本月统计')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 16 })

          Row() {
            Column() {
              Text(PreferencesUtil.formatDuration(this.monthFocusMinutes))
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_green'))
              Text('总专注时长')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .layoutWeight(1)

            Column() {
              Text(`${this.getMonthActiveDays()}天`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_blue'))
              Text('活跃天数')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .layoutWeight(1)

            Column() {
              Text(`${Math.round(this.monthFocusMinutes / Math.max(this.getMonthActiveDays(), 1))}分钟`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.accent_orange'))
              Text('日均时长')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .margin({ left: 16, right: 16, top: 12 })
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(20)
        .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
        .scale({ x: this.statsScale, y: this.statsScale })
        .opacity(this.statsOpacity)

        // 图例
        Row() {
          Row() {
            Circle().width(12).height(12).fill($r('app.color.primary_green_light')).margin({ right: 4 })
            Text('<30分').fontSize(11).fontColor($r('app.color.text_hint'))
          }.margin({ right: 16 })

          Row() {
            Circle().width(12).height(12).fill($r('app.color.calendar_has_record')).margin({ right: 4 })
            Text('30-120分').fontSize(11).fontColor($r('app.color.text_hint'))
          }.margin({ right: 16 })

          Row() {
            Circle().width(12).height(12).fill($r('app.color.calendar_heavy_record')).margin({ right: 4 })
            Text('>120分').fontSize(11).fontColor($r('app.color.text_hint'))
          }
        }
        .margin({ top: 16, bottom: 20 })
        .opacity(this.statsOpacity)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
  }

  // 生成日期数组 [1, 2, 3, ..., 28/30/31]
  private getDaysList(): number[] {
    let days: number[] = []
    let total = this.getDaysInMonth()
    for (let i = 1; i <= total; i++) {
      days.push(i)
    }
    return days
  }

  // 点击日期跳转
  private onDayClick(day: number): void {
    let dateStr = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    this.selectedDate = dateStr
    router.pushUrl({
      url: 'pages/DayDetailPage',
      params: { date: dateStr }
    })
  }

  private getMonthActiveDays(): number {
    let monthPrefix = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}`
    let count = 0
    for (let record of this.allRecords) {
      if (record.date.startsWith(monthPrefix)) {
        count++
      }
    }
    return count
  }
}
