/**
 * 每日专注挑战页面
 * 连续7天完成目标解锁成就
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { UserGrowth } from '../model/DataModels'

@Entry
@Component
struct ChallengesPage {
  @State growth: UserGrowth = { totalPoints: 0, treeStage: 0, totalFocusMinutes: 0, currentStreak: 0, longestStreak: 0, lastActiveDate: '' }
  @State todayMinutes: number = 0
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
    this.growth = await PreferencesUtil.getUserGrowth()
    this.todayMinutes = await PreferencesUtil.getTodayFocusMinutes()
  }

  private isDayCompleted(dayIndex: number): boolean {
    return dayIndex < this.growth.currentStreak
  }

  private getAchievementStatus(required: number): string {
    return this.growth.longestStreak >= required ? '已解锁' : `需连续${required}天`
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { router.back() })
        Text('每日挑战').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          // 今日进度
          Column() {
            Text('今日挑战').fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 12 })
            Text(`今日已专注: ${PreferencesUtil.formatDuration(this.todayMinutes)}`)
              .fontSize(16).fontColor($r('app.color.primary_green')).fontWeight(FontWeight.Bold)
            Progress({ value: Math.min(this.todayMinutes, 60), total: 60, type: ProgressType.Linear })
              .width('100%').height(10).color($r('app.color.primary_green'))
              .backgroundColor($r('app.color.progress_track')).borderRadius(5).margin({ top: 12 })
            Text(this.todayMinutes >= 60 ? '今日挑战完成！' : `目标: 专注60分钟 (还差${Math.max(0, 60 - Math.round(this.todayMinutes))}分钟)`)
              .fontSize(13).fontColor($r('app.color.text_secondary')).margin({ top: 8 })
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 12 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 7天连续挑战
          Column() {
            Text('7天连续挑战').fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 16 })
            Row() {
              ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
                Column() {
                  Text(this.isDayCompleted(day - 1) ? '√' : (day === this.growth.currentStreak + 1 ? '>' : '⬜'))
                    .fontSize(24)
                  Text(`D${day}`).fontSize(11).fontColor($r('app.color.text_hint')).margin({ top: 4 })
                }.layoutWeight(1)
              })
            }.width('100%')
            Text(`当前连续: ${this.growth.currentStreak}天 | 最长: ${this.growth.longestStreak}天`)
              .fontSize(13).fontColor($r('app.color.text_secondary')).margin({ top: 12 })
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 12 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 成就列表
          Column() {
            Text('成就').fontSize(18).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 12 })

            ForEach([
              { name: '初次尝试', desc: '完成第一次专注', req: 1 },
              { name: '三天坚持', desc: '连续专注3天', req: 3 },
              { name: '一周达人', desc: '连续专注7天', req: 7 },
              { name: '半月之星', desc: '连续专注15天', req: 15 },
              { name: '月度冠军', desc: '连续专注30天', req: 30 }
            ], (item: AchievementItem) => {
              Row() {
                Column() {
                  Text(item.name).fontSize(15).fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                  Text(item.desc).fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 2 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text(this.getAchievementStatus(item.req))
                  .fontSize(12).fontColor(this.growth.longestStreak >= item.req ?
                  $r('app.color.success_green') : $r('app.color.text_hint'))
              }.width('100%').padding({ top: 12, bottom: 12 })
                .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') })
            })
          }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 40 })
            .backgroundColor($r('app.color.bg_card')).borderRadius(20)
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
        .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}

interface AchievementItem {
  name: string
  desc: string
  req: number
}
