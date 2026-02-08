/**
 * 周/月专注报告页面
 * 可视化专注时段分布
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusSession } from '../model/DataModels'

@Entry
@Component
struct FocusReportPage {
  @State viewMode: string = 'week' // week / month
  @State sessions: FocusSession[] = []
  @State weekData: number[] = [0, 0, 0, 0, 0, 0, 0] // 周日-周六的分钟数
  @State totalMinutes: number = 0
  @State totalSessions: number = 0
  @State maxDayMinutes: number = 1

  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State bodyScale: number = 0
  @State bodyOpacity: number = 0

  aboutToAppear(): void {
    this.loadData()
    setTimeout(() => {
      animateTo({ duration: 700, curve: curves.springCurve(0, 1, 328, 34) }, () => { this.headerScale = 1; this.headerOpacity = 1 })
    }, 100)
    setTimeout(() => {
      animateTo({ duration: 800, curve: curves.springCurve(0, 1, 300, 28) }, () => { this.bodyScale = 1; this.bodyOpacity = 1 })
    }, 250)
  }

  private async loadData(): Promise<void> {
    this.sessions = await PreferencesUtil.getFocusSessions()
    this.calculateStats()
  }

  private calculateStats(): void {
    let now = new Date()
    this.weekData = [0, 0, 0, 0, 0, 0, 0]
    this.totalMinutes = 0
    this.totalSessions = 0

    let rangeMs = this.viewMode === 'week' ? 7 * 86400000 : 30 * 86400000
    let startTime = now.getTime() - rangeMs

    for (let session of this.sessions) {
      if (session.startTime >= startTime) {
        this.totalMinutes += session.duration
        this.totalSessions++
        let d = new Date(session.startTime)
        let dayOfWeek = d.getDay()
        this.weekData[dayOfWeek] += session.duration
      }
    }

    this.maxDayMinutes = 1
    for (let v of this.weekData) {
      if (v > this.maxDayMinutes) this.maxDayMinutes = v
    }
  }

  private switchMode(mode: string): void {
    this.viewMode = mode
    this.calculateStats()
  }

  private getDayLabel(index: number): string {
    let labels: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return labels[index]
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { router.back() })
        Text('专注报告').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          // 模式切换
          Row() {
            Button('本周').height(36).fontSize(14)
              .backgroundColor(this.viewMode === 'week' ? $r('app.color.primary_blue') : $r('app.color.bg_surface'))
              .fontColor(this.viewMode === 'week' ? Color.White : $r('app.color.text_secondary'))
              .borderRadius(18).margin({ right: 8 })
              .onClick(() => { this.switchMode('week') })
            Button('本月').height(36).fontSize(14)
              .backgroundColor(this.viewMode === 'month' ? $r('app.color.primary_blue') : $r('app.color.bg_surface'))
              .fontColor(this.viewMode === 'month' ? Color.White : $r('app.color.text_secondary'))
              .borderRadius(18)
              .onClick(() => { this.switchMode('month') })
          }.margin({ left: 16, bottom: 12 })

          // 总览
          Column() {
            Text(`${this.viewMode === 'week' ? '本周' : '本月'}概览`).fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 16 })
            Row() {
              Column() {
                Text(PreferencesUtil.formatDuration(this.totalMinutes))
                  .fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
                Text('总时长').fontSize(11).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
              }.layoutWeight(1)
              Column() {
                Text(`${this.totalSessions}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
                Text('专注次数').fontSize(11).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
              }.layoutWeight(1)
              Column() {
                Text(`${Math.round(this.totalMinutes / Math.max(this.viewMode === 'week' ? 7 : 30, 1))}分`)
                  .fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent_orange'))
                Text('日均').fontSize(11).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
              }.layoutWeight(1)
            }.width('100%')
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 12 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 按星期分布柱状图
          Column() {
            Text('按星期分布').fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 16 })
            Row() {
              ForEach([0, 1, 2, 3, 4, 5, 6], (i: number) => {
                Column() {
                  Text(`${Math.round(this.weekData[i])}`)
                    .fontSize(10).fontColor($r('app.color.text_hint')).margin({ bottom: 4 })
                  Column()
                    .width(24)
                    .height(Math.max(4, (this.weekData[i] / this.maxDayMinutes) * 100))
                    .backgroundColor($r('app.color.primary_green'))
                    .borderRadius(4)
                  Text(this.getDayLabel(i))
                    .fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 6 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.End)
              })
            }.width('100%').height(160).alignItems(VerticalAlign.Bottom)
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 40 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
        .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
