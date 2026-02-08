/**
 * 项目详情页（二级页面）
 * 不使用自定义组件，所有 UI 在本页面 ArkUI 中直接构建
 * 展示项目信息、进度、最近专注会话
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusProject, FocusSession } from '../model/DataModels'

interface ProjectDetailParams {
  projectId: string
}

@Entry
@Component
struct ProjectDetailPage {
  @State project: FocusProject | null = null
  @State sessions: FocusSession[] = []
  @State projectId: string = ''

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State progressScale: number = 0
  @State progressOpacity: number = 0
  @State detailScale: number = 0
  @State detailOpacity: number = 0
  @State sessionListScale: number = 0
  @State sessionListOpacity: number = 0
  @State deleteScale: number = 0
  @State deleteOpacity: number = 0

  aboutToAppear(): void {
    let params = router.getParams() as ProjectDetailParams
    if (params && params.projectId) {
      this.projectId = params.projectId
    }
    this.loadData()
    this.playEntranceAnimation()
  }

  private async loadData(): Promise<void> {
    let projects = await PreferencesUtil.getProjects()
    this.project = projects.find((p: FocusProject) => p.id === this.projectId) || null
    if (this.project) {
      this.sessions = await PreferencesUtil.getSessionsByProject(this.projectId)
      this.sessions.sort((a: FocusSession, b: FocusSession) => b.startTime - a.startTime)
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
        this.progressScale = 1
        this.progressOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.detailScale = 1
        this.detailOpacity = 1
      })
    }, 400)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.sessionListScale = 1
        this.sessionListOpacity = 1
      })
    }, 550)

    setTimeout(() => {
      animateTo({
        duration: 500,
        curve: curves.springCurve(0, 1, 260, 26)
      }, () => {
        this.deleteScale = 1
        this.deleteOpacity = 1
      })
    }, 700)
  }

  private async deleteProject(): Promise<void> {
    if (this.project) {
      await PreferencesUtil.deleteProject(this.project.id)
      router.back()
    }
  }

  private getProgressPercent(): number {
    if (!this.project || this.project.totalGoalHours <= 0) return 0
    return Math.min(100, Math.round(this.project.completedMinutes / (this.project.totalGoalHours * 60) * 100))
  }

  private getRemainingMinutes(): number {
    if (!this.project) return 0
    return Math.max(0, this.project.totalGoalHours * 60 - this.project.completedMinutes)
  }

  private async toggleActive(): Promise<void> {
    if (this.project) {
      this.project.isActive = !this.project.isActive
      await PreferencesUtil.saveProject(this.project)
    }
  }

  @Builder
  buildProgressCard() {
    if (this.project && this.project.totalGoalHours > 0) {
      Column() {
        Text('时长进度')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 16 })

        // 进度百分比
        Stack() {
          Progress({
            value: this.project.completedMinutes,
            total: this.project.totalGoalHours * 60,
            type: ProgressType.Ring
          })
            .width(140)
            .height(140)
            .color($r('app.color.primary_green'))
            .backgroundColor($r('app.color.progress_track'))
            .style({ strokeWidth: 14 })

          Column() {
            Text(`${this.getProgressPercent()}%`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))
            Text('完成度')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .margin({ bottom: 16 })

        Row() {
          Column() {
            Text(PreferencesUtil.formatDuration(this.project.completedMinutes))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))
            Text('已完成')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.project.totalGoalHours}小时`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('总目标')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)

          Column() {
            Text(PreferencesUtil.formatDuration(this.getRemainingMinutes()))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.accent_orange'))
            Text('剩余')
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
      .scale({ x: this.progressScale, y: this.progressScale })
      .opacity(this.progressOpacity)
    }
  }

  @Builder
  buildDetailInfo() {
    if (this.project) {
      Column() {
        Text('项目信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 12 })

        // 描述
        if (this.project.description !== '') {
          Row() {
            Text('描述: ')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
            Text(this.project.description)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 8 })
        }

        // 每日目标
        if (this.project.dailyGoalHours > 0) {
          Row() {
            Text('每日目标: ')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
            Text(`${this.project.dailyGoalHours}小时`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_blue'))
          }
          .width('100%')
          .margin({ bottom: 8 })
        }

        // 总天数
        if (this.project.totalGoalDays > 0) {
          Row() {
            Text('目标天数: ')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
            Text(`${this.project.completedDays} / ${this.project.totalGoalDays}天`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.accent_orange'))
          }
          .width('100%')
          .margin({ bottom: 8 })
        }

        Row() {
          Text('创建时间: ')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Text(PreferencesUtil.formatDateTime(this.project.createdAt))
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('专注次数: ')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Text(`${this.sessions.length}次`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_green'))
        }
        .width('100%')

        // 操作按钮
        Row() {
          Button(this.project.isActive ? '标记完成' : '重新激活')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor(this.project.isActive ?
              $r('app.color.primary_blue_light') : $r('app.color.primary_green_light'))
            .fontColor(this.project.isActive ?
              $r('app.color.primary_blue') : $r('app.color.primary_green'))
            .borderRadius(20)
            .onClick(() => { this.toggleActive() })
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(20)
      .margin({ left: 16, right: 16, bottom: 12 })
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(20)
      .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
      .scale({ x: this.detailScale, y: this.detailScale })
      .opacity(this.detailOpacity)
    }
  }

  @Builder
  buildSessionList() {
    Column() {
      Text('专注记录')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      if (this.sessions.length === 0) {
        Text('暂无专注记录')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .padding(20)
      } else {
        ForEach(this.sessions, (session: FocusSession) => {
          Row() {
            Column() {
              Text(PreferencesUtil.formatDateTime(session.startTime))
                .fontSize(13)
                .fontColor($r('app.color.text_primary'))
              Text(session.date)
                .fontSize(11)
                .fontColor($r('app.color.text_hint'))
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text(`${session.duration}分钟`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
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
    .margin({ left: 16, right: 16, bottom: 12 })
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(20)
    .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
    .scale({ x: this.sessionListScale, y: this.sessionListScale })
    .opacity(this.sessionListOpacity)
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

        Text(this.project ? this.project.name : '项目详情')
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
          this.buildProgressCard()
          this.buildDetailInfo()
          this.buildSessionList()

          // 删除按钮
          Button('删除项目')
            .width('60%')
            .height(44)
            .fontSize(14)
            .backgroundColor($r('app.color.bg_surface'))
            .fontColor($r('app.color.error_red'))
            .borderRadius(22)
            .margin({ top: 8, bottom: 40 })
            .onClick(() => { this.deleteProject() })
            .scale({ x: this.deleteScale, y: this.deleteScale })
            .opacity(this.deleteOpacity)
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
