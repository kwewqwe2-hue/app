/**
 * 目标追踪页面
 * 本周计划专注多少小时，完成进度
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'

@Entry
@Component
struct GoalTrackingPage {
  @State weeklyGoalHours: number = 10
  @State weeklyCompletedMinutes: number = 0
  @State editingGoal: boolean = false
  @State goalInput: string = '10'
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
    // 计算本周已完成分钟数
    let sessions = await PreferencesUtil.getFocusSessions()
    let now = new Date()
    let dayOfWeek = now.getDay()
    let mondayMs = now.getTime() - ((dayOfWeek === 0 ? 6 : dayOfWeek - 1) * 86400000)
    let mondayStart = new Date(mondayMs)
    mondayStart.setHours(0, 0, 0, 0)

    this.weeklyCompletedMinutes = 0
    for (let s of sessions) {
      if (s.startTime >= mondayStart.getTime()) {
        this.weeklyCompletedMinutes += s.duration
      }
    }
  }

  private getProgressPercent(): number {
    if (this.weeklyGoalHours <= 0) return 0
    return Math.min(100, Math.round(this.weeklyCompletedMinutes / (this.weeklyGoalHours * 60) * 100))
  }

  private getRemainingText(): string {
    let remaining = Math.max(0, this.weeklyGoalHours * 60 - this.weeklyCompletedMinutes)
    if (remaining <= 0) return '🎉 本周目标已完成！'
    return `还差 ${PreferencesUtil.formatDuration(remaining)}`
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { router.back() })
        Text('目标追踪').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          // 本周进度
          Column() {
            Text('🎯 本周目标').fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 20 })

            // 环形进度
            Stack() {
              Progress({ value: this.weeklyCompletedMinutes, total: this.weeklyGoalHours * 60, type: ProgressType.Ring })
                .width(160).height(160)
                .color($r('app.color.primary_green'))
                .backgroundColor($r('app.color.progress_track'))
                .style({ strokeWidth: 16 })

              Column() {
                Text(`${this.getProgressPercent()}%`)
                  .fontSize(36).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
                Text('完成度').fontSize(12).fontColor($r('app.color.text_secondary'))
              }
            }.margin({ bottom: 20 })

            Row() {
              Column() {
                Text(PreferencesUtil.formatDuration(this.weeklyCompletedMinutes))
                  .fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
                Text('已完成').fontSize(11).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
              }.layoutWeight(1)
              Column() {
                Text(`${this.weeklyGoalHours}小时`)
                  .fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
                Text('本周目标').fontSize(11).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
              }.layoutWeight(1)
            }.width('100%').margin({ bottom: 12 })

            Text(this.getRemainingText())
              .fontSize(15).fontColor($r('app.color.accent_orange')).fontWeight(FontWeight.Bold)
          }.width('100%').padding(24).margin({ left: 16, right: 16, bottom: 12 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 修改目标
          Column() {
            Text('⚙ 调整目标').fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 12 })
            Row() {
              Text('每周目标时长:').fontSize(14).fontColor($r('app.color.text_secondary'))
              Blank()
              Row() {
                ForEach([5, 10, 15, 20, 30], (h: number) => {
                  Text(`${h}h`).fontSize(13)
                    .fontColor(this.weeklyGoalHours === h ? $r('app.color.primary_green') : $r('app.color.text_hint'))
                    .fontWeight(this.weeklyGoalHours === h ? FontWeight.Bold : FontWeight.Normal)
                    .backgroundColor(this.weeklyGoalHours === h ? $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(12).margin({ left: 4 })
                    .onClick(() => { this.weeklyGoalHours = h })
                })
              }
            }.width('100%')
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 40 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
        .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
