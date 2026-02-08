/**
 * 日详情页（二级页面）
 * 不使用自定义组件，所有 UI 在 ArkUI 中直接构建
 * 展示指定日期的所有专注会话详情
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusSession, DayRecord } from '../model/DataModels'

interface DayDetailParams {
  date: string
}

@Entry
@Component
struct DayDetailPage {
  @State date: string = ''
  @State sessions: FocusSession[] = []
  @State dayRecord: DayRecord | null = null

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State summaryScale: number = 0
  @State summaryOpacity: number = 0
  @State timelineScale: number = 0
  @State timelineOpacity: number = 0

  aboutToAppear(): void {
    let params = router.getParams() as DayDetailParams
    if (params && params.date) {
      this.date = params.date
    } else {
      this.date = PreferencesUtil.getDateStr(new Date())
    }
    this.loadData()
    this.playEntranceAnimation()
  }

  private async loadData(): Promise<void> {
    this.sessions = await PreferencesUtil.getSessionsByDate(this.date)
    this.sessions.sort((a: FocusSession, b: FocusSession) => a.startTime - b.startTime)
    this.dayRecord = await PreferencesUtil.getDayRecord(this.date)
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
        this.summaryScale = 1
        this.summaryOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.timelineScale = 1
        this.timelineOpacity = 1
      })
    }, 400)
  }

  // 格式化时间为 HH:MM
  private formatTime(timestamp: number): string {
    let d = new Date(timestamp)
    let h = d.getHours().toString().padStart(2, '0')
    let m = d.getMinutes().toString().padStart(2, '0')
    return `${h}:${m}`
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor($r('app.color.bg_surface'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(20)
          .onClick(() => { router.back() })

        Text(this.date)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 12 })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .scale({ x: this.headerScale, y: this.headerScale })
      .opacity(this.headerOpacity)

      // 内容区
      Scroll() {
        Column() {
          // 日汇总卡片
          Column() {
            Text('📊 日汇总')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 20 })

            Row() {
              Column() {
                Text(this.dayRecord ?
                  PreferencesUtil.formatDuration(this.dayRecord.totalMinutes) : '0分钟')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_green'))
                Text('总时长')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(`${this.dayRecord ? this.dayRecord.totalPoints : 0}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.accent_orange'))
                Text('总积分')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(`${this.dayRecord ? this.dayRecord.sessionCount : 0}次`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_blue'))
                Text('专注次数')
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
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.summaryScale, y: this.summaryScale })
          .opacity(this.summaryOpacity)

          // 时间线
          Column() {
            Text('⏱ 专注时间线')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            if (this.sessions.length === 0) {
              Column() {
                Text('😴')
                  .fontSize(48)
                  .margin({ bottom: 12 })
                Text('这一天还没有专注记录')
                  .fontSize(14)
                  .fontColor($r('app.color.text_hint'))
              }
              .width('100%')
              .padding({ top: 24, bottom: 24 })
            } else {
              ForEach(this.sessions, (session: FocusSession, index: number) => {
                Row() {
                  // 时间轴指示器
                  Column() {
                    Circle()
                      .width(12)
                      .height(12)
                      .fill($r('app.color.primary_green'))

                    if (index !== undefined && index < this.sessions.length - 1) {
                      Row()
                        .width(2)
                        .height(60)
                        .backgroundColor($r('app.color.divider'))
                    }
                  }
                  .width(30)
                  .alignItems(HorizontalAlign.Center)

                  // 会话信息
                  Column() {
                    Row() {
                      Text(session.projectName)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.text_primary'))
                        .layoutWeight(1)

                      Text(`+${session.points}分`)
                        .fontSize(13)
                        .fontColor($r('app.color.accent_orange'))
                        .fontWeight(FontWeight.Bold)
                    }
                    .width('100%')

                    Row() {
                      Text(this.formatTime(session.startTime))
                        .fontSize(13)
                        .fontColor($r('app.color.text_secondary'))
                        .fontWeight(FontWeight.Medium)
                      Text(' - ')
                        .fontSize(13)
                        .fontColor($r('app.color.text_hint'))
                      Text(this.formatTime(session.endTime))
                        .fontSize(13)
                        .fontColor($r('app.color.text_secondary'))
                        .fontWeight(FontWeight.Medium)
                      Blank()
                      Text(`${session.duration}分钟`)
                        .fontSize(13)
                        .fontColor($r('app.color.primary_green'))
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                    .margin({ top: 6 })

                    // 时长进度条
                    Row()
                      .width(`${Math.min(100, session.duration / 1.2)}%`)
                      .height(4)
                      .borderRadius(2)
                      .backgroundColor($r('app.color.primary_green'))
                      .margin({ top: 8 })
                  }
                  .layoutWeight(1)
                  .padding({ left: 12, bottom: 20 })
                }
                .width('100%')
              })
            }
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 40 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.timelineScale, y: this.timelineScale })
          .opacity(this.timelineOpacity)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}
