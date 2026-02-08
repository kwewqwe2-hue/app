/**
 * 成长系统 Tab 组件
 * 功能：生命之树展示、积分统计、历史记录
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { UserGrowth, FocusSession, TreeStageInfo } from '../model/DataModels'
import { TreeView } from './TreeView'

@Component
export struct GrowthTab {
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number
  @State growth: UserGrowth = {
    totalPoints: 0,
    treeStage: 0,
    totalFocusMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastActiveDate: ''
  }
  @State recentSessions: FocusSession[] = []

  // 动画状态
  @State treeAreaScale: number = 0
  @State treeAreaOpacity: number = 0
  @State statsScale: number = 0
  @State statsOpacity: number = 0
  @State historyScale: number = 0
  @State historyOpacity: number = 0

  aboutToAppear(): void {
    this.loadData()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    this.growth = await PreferencesUtil.getUserGrowth()
    let allSessions = await PreferencesUtil.getFocusSessions()
    // 按时间倒序，取最近 10 条
    allSessions.sort((a: FocusSession, b: FocusSession) => b.startTime - a.startTime)
    this.recentSessions = allSessions.slice(0, 10)
  }

  private playEntranceAnimation(): void {
    setTimeout(() => {
      animateTo({
        duration: 900,
        curve: curves.springCurve(0, 1, 280, 26)
      }, () => {
        this.treeAreaScale = 1
        this.treeAreaOpacity = 1
      })
    }, 100)

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.statsScale = 1
        this.statsOpacity = 1
      })
    }, 350)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.historyScale = 1
        this.historyOpacity = 1
      })
    }, 550)
  }

  private getNextStageName(): string {
    return TreeStageInfo.getStageConfig(this.growth.treeStage + 1).name
  }

  private getNextStageMinPoints(): number {
    return TreeStageInfo.getStageConfig(this.growth.treeStage + 1).minPoints
  }

  private getProgressValue(): number {
    return this.growth.totalPoints - TreeStageInfo.getStageConfig(this.growth.treeStage).minPoints
  }

  private getProgressTotal(): number {
    return TreeStageInfo.getStageConfig(this.growth.treeStage + 1).minPoints -
      TreeStageInfo.getStageConfig(this.growth.treeStage).minPoints
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Row() {
          Text('成长之路')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Button('⚙')
            .width(36)
            .height(36)
            .fontSize(18)
            .backgroundColor($r('app.color.bg_surface'))
            .borderRadius(18)
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' })
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        // 生命之树区域
        Column() {
          // 树的视觉
          TreeView({
            treeStage: this.growth.treeStage,
            totalPoints: this.growth.totalPoints
          })

          // 阶段名称
          Text(TreeStageInfo.getStageConfig(this.growth.treeStage).name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_green'))
            .margin({ top: 8 })

          Text(TreeStageInfo.getStageConfig(this.growth.treeStage).description)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })

          // 成长进度条
          if (this.growth.treeStage < 5) {
            Column() {
              Row() {
                Text(`距离「${this.getNextStageName()}」`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Blank()
                Text(`${this.growth.totalPoints}/${this.getNextStageMinPoints()}`)
                  .fontSize(12)
                  .fontColor($r('app.color.accent_orange'))
              }
              .width('100%')

              Progress({
                value: this.getProgressValue(),
                total: this.getProgressTotal(),
                type: ProgressType.Linear
              })
                .width('100%')
                .height(8)
                .color($r('app.color.primary_green'))
                .backgroundColor($r('app.color.progress_track'))
                .borderRadius(4)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 16 })
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 20 })
        .margin({ left: 16, right: 16 })
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(24)
        .shadow({ radius: 12, color: $r('app.color.shadow_color'), offsetY: 4 })
        .scale({ x: this.treeAreaScale, y: this.treeAreaScale })
        .opacity(this.treeAreaOpacity)

        // 数据统计
        Row() {
          Column() {
            Text(`${this.growth.totalPoints}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.accent_orange'))
            Text('总积分')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(16)
          .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          Column() {
            Text(PreferencesUtil.formatDuration(this.growth.totalFocusMinutes))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))
            Text('总时长')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding(16)
          .margin({ left: 10, right: 10 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(16)
          .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          Column() {
            Text(`${this.growth.currentStreak}天`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_blue'))
            Text('连续打卡')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(16)
          .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 16 })
        .scale({ x: this.statsScale, y: this.statsScale })
        .opacity(this.statsOpacity)

        // 最近记录
        Column() {
          Text('最近专注记录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 12 })

          if (this.recentSessions.length === 0) {
            Text('暂无专注记录')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))
              .padding(20)
          } else {
            ForEach(this.recentSessions, (session: FocusSession) => {
              Row() {
                Column() {
                  Text(session.projectName)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                  Text(PreferencesUtil.formatDateTime(session.startTime))
                    .fontSize(11)
                    .fontColor($r('app.color.text_hint'))
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Text(`${session.duration}分钟`)
                    .fontSize(14)
                    .fontColor($r('app.color.primary_green'))
                  Text(`+${session.points}分`)
                    .fontSize(12)
                    .fontColor($r('app.color.accent_orange'))
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
              .border({
                width: { bottom: 0.5 },
                color: $r('app.color.divider')
              })
            })
          }
        }
        .width('100%')
        .padding(20)
        .margin({ left: 16, right: 16, top: 16, bottom: 20 })
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(20)
        .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
        .scale({ x: this.historyScale, y: this.historyScale })
        .opacity(this.historyOpacity)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
  }
}
