/**
 * 专注计时器 Tab 组件
 * 核心功能：预设/手动计时、暂停/结束、今日累计显示
 */
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { PointsCalculator } from '../utils/PointsCalculator'
import { FocusSession, FocusProject } from '../model/DataModels'

@Component
export struct FocusTimerTab {
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number

  // 计时器状态
  @State isRunning: boolean = false
  @State isPaused: boolean = false
  @State isPresetMode: boolean = true
  @State presetMinutes: number = 25
  @State elapsedSeconds: number = 0
  @State remainingSeconds: number = 0
  @State todayMinutes: number = 0

  // 会话信息
  @State startTime: number = 0
  @State selectedProjectId: string = ''
  @State selectedProjectName: string = '自由专注'
  @State projects: FocusProject[] = []

  // 结算状态
  @State showResult: boolean = false
  @State resultPoints: number = 0
  @State resultMinutes: number = 0
  @State resultRank: string = ''

  // 动画状态
  @State timerScale: number = 0
  @State timerOpacity: number = 0
  @State controlScale: number = 0
  @State controlOpacity: number = 0
  @State infoScale: number = 0
  @State infoOpacity: number = 0
  @State resultScale: number = 0
  @State resultOpacity: number = 0

  private timerId: number = -1

  aboutToAppear(): void {
    this.loadData()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadData()
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
    }
  }

  private async loadData(): Promise<void> {
    this.todayMinutes = await PreferencesUtil.getTodayFocusMinutes()
    this.projects = await PreferencesUtil.getProjects()
  }

  private playEntranceAnimation(): void {
    // 计时器区域弹性入场
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: curves.springCurve(0, 1, 328, 34)
      }, () => {
        this.timerScale = 1
        this.timerOpacity = 1
      })
    }, 100)

    // 控制按钮弹性入场
    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.controlScale = 1
        this.controlOpacity = 1
      })
    }, 300)

    // 信息区域弹性入场
    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.infoScale = 1
        this.infoOpacity = 1
      })
    }, 500)
  }

  // 开始计时
  private startTimer(): void {
    this.isRunning = true
    this.isPaused = false
    this.startTime = Date.now()
    this.elapsedSeconds = 0

    if (this.isPresetMode) {
      this.remainingSeconds = this.presetMinutes * 60
    }

    this.timerId = setInterval(() => {
      if (!this.isPaused) {
        this.elapsedSeconds += 1
        if (this.isPresetMode) {
          this.remainingSeconds -= 1
          if (this.remainingSeconds <= 0) {
            this.endTimer()
          }
        }
      }
    }, 1000)
  }

  // 暂停/继续
  private togglePause(): void {
    this.isPaused = !this.isPaused
  }

  // 结束计时
  private endTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }

    let durationMinutes = this.elapsedSeconds / 60
    if (this.elapsedSeconds < 3) {
      // 不足3秒不记录（防误触）
      this.isRunning = false
      this.isPaused = false
      return
    }

    let points = Math.max(1, PointsCalculator.calculatePoints(durationMinutes))
    let rank = PointsCalculator.getPointsRank(points)

    // 保存会话
    let session: FocusSession = {
      id: PreferencesUtil.generateId(),
      projectId: this.selectedProjectId,
      projectName: this.selectedProjectName,
      startTime: this.startTime,
      endTime: Date.now(),
      duration: Math.round(durationMinutes * 10) / 10,
      points: points,
      date: PreferencesUtil.getDateStr(new Date())
    }

    PreferencesUtil.saveFocusSession(session)
    PreferencesUtil.addPointsAndUpdate(points, Math.round(durationMinutes))

    // 更新项目进度
    if (this.selectedProjectId !== '') {
      this.updateProjectProgress(durationMinutes)
    }

    // 显示结算
    this.resultPoints = points
    this.resultMinutes = Math.round(durationMinutes * 10) / 10
    this.resultRank = rank
    this.showResult = true

    // 结算弹性动画
    this.resultScale = 0
    this.resultOpacity = 0
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: curves.springCurve(0, 1, 280, 26)
      }, () => {
        this.resultScale = 1
        this.resultOpacity = 1
      })
    }, 100)

    this.isRunning = false
    this.isPaused = false
    this.todayMinutes += durationMinutes
  }

  private async updateProjectProgress(minutes: number): Promise<void> {
    let project = this.projects.find((p: FocusProject) => p.id === this.selectedProjectId)
    if (project) {
      project.completedMinutes += minutes
      await PreferencesUtil.saveProject(project)
    }
  }

  // 格式化秒数为 MM:SS 或 HH:MM:SS
  private formatTime(totalSeconds: number): string {
    let hours = Math.floor(totalSeconds / 3600)
    let minutes = Math.floor((totalSeconds % 3600) / 60)
    let seconds = Math.floor(totalSeconds % 60)
    let minStr = minutes.toString().padStart(2, '0')
    let secStr = seconds.toString().padStart(2, '0')
    if (hours > 0) {
      let hourStr = hours.toString().padStart(2, '0')
      return `${hourStr}:${minStr}:${secStr}`
    }
    return `${minStr}:${secStr}`
  }

  build() {
    Scroll() {
      Column() {
        // 标题区域
        Row() {
          Text('FocusZone')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_green'))
          Blank()
          Text(`今日已专注: ${PreferencesUtil.formatDuration(this.todayMinutes)}`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16 })
        .opacity(this.infoOpacity)
        .scale({ x: this.infoScale, y: this.infoScale })

        if (this.showResult) {
          // ===== 结算面板 =====
          Column() {
            Text('🎉 专注完成！')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))
              .margin({ bottom: 16 })

            // 成绩卡片
            Column() {
              Text(this.resultRank)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.accent_orange'))
                .margin({ bottom: 12 })

              Row() {
                Column() {
                  Text(`${this.resultMinutes}`)
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                  Text('分钟')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)

                Divider()
                  .vertical(true)
                  .height(50)
                  .color($r('app.color.divider'))

                Column() {
                  Text(`+${this.resultPoints}`)
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.accent_orange'))
                  Text('积分')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(24)
            .backgroundColor($r('app.color.bg_card'))
            .borderRadius(20)
            .shadow({ radius: 12, color: $r('app.color.shadow_color'), offsetY: 4 })
            .margin({ bottom: 20 })

            Text(`项目: ${this.selectedProjectName}`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Button('继续专注')
              .width('80%')
              .height(48)
              .backgroundColor($r('app.color.primary_green'))
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .borderRadius(24)
              .onClick(() => {
                this.showResult = false
                this.loadData()
              })
          }
          .width('100%')
          .padding(20)
          .margin({ top: 40 })
          .scale({ x: this.resultScale, y: this.resultScale })
          .opacity(this.resultOpacity)

        } else if (!this.isRunning) {
          // ===== 计时器设置面板 =====
          Column() {
            // 模式选择
            Row() {
              Button('预设时间')
                .height(36)
                .fontSize(14)
                .fontWeight(this.isPresetMode ? FontWeight.Bold : FontWeight.Normal)
                .backgroundColor(this.isPresetMode ? $r('app.color.primary_green') : $r('app.color.bg_surface'))
                .fontColor(this.isPresetMode ? Color.White : $r('app.color.text_secondary'))
                .borderRadius(18)
                .margin({ right: 12 })
                .onClick(() => { this.isPresetMode = true })

              Button('手动计时')
                .height(36)
                .fontSize(14)
                .fontWeight(!this.isPresetMode ? FontWeight.Bold : FontWeight.Normal)
                .backgroundColor(!this.isPresetMode ? $r('app.color.primary_green') : $r('app.color.bg_surface'))
                .fontColor(!this.isPresetMode ? Color.White : $r('app.color.text_secondary'))
                .borderRadius(18)
                .onClick(() => { this.isPresetMode = false })
            }
            .margin({ top: 24, bottom: 28 })
            .opacity(this.controlOpacity)
            .scale({ x: this.controlScale, y: this.controlScale })

            // 计时器显示
            Column() {
              if (this.isPresetMode) {
                Text(this.formatTime(this.presetMinutes * 60))
                  .fontSize(72)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .letterSpacing(4)

                // 快捷时间选择
                Row() {
                  ForEach([15, 25, 45, 60, 90], (min: number) => {
                    Button(`${min}`)
                      .width(52)
                      .height(36)
                      .fontSize(14)
                      .backgroundColor(this.presetMinutes === min ?
                        $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
                      .fontColor(this.presetMinutes === min ?
                        $r('app.color.primary_green') : $r('app.color.text_secondary'))
                      .borderRadius(18)
                      .margin({ left: 4, right: 4 })
                      .onClick(() => { this.presetMinutes = min })
                  })
                }
                .margin({ top: 20 })
              } else {
                Text('00:00')
                  .fontSize(72)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .letterSpacing(4)

                Text('点击开始自由计时')
                  .fontSize(14)
                  .fontColor($r('app.color.text_hint'))
                  .margin({ top: 12 })
              }
            }
            .padding({ top: 32, bottom: 32 })
            .width('100%')
            .backgroundColor($r('app.color.timer_bg'))
            .borderRadius(24)
            .scale({ x: this.timerScale, y: this.timerScale })
            .opacity(this.timerOpacity)

            // 项目选择
            Column() {
              Text('选择项目')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 8 })

              Row() {
                Button('自由专注')
                  .height(32)
                  .fontSize(12)
                  .backgroundColor(this.selectedProjectId === '' ?
                    $r('app.color.primary_blue_light') : $r('app.color.bg_surface'))
                  .fontColor(this.selectedProjectId === '' ?
                    $r('app.color.primary_blue') : $r('app.color.text_secondary'))
                  .borderRadius(16)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.selectedProjectId = ''
                    this.selectedProjectName = '自由专注'
                  })

                ForEach(this.projects, (project: FocusProject) => {
                  Button(project.name)
                    .height(32)
                    .fontSize(12)
                    .backgroundColor(this.selectedProjectId === project.id ?
                      $r('app.color.primary_blue_light') : $r('app.color.bg_surface'))
                    .fontColor(this.selectedProjectId === project.id ?
                      $r('app.color.primary_blue') : $r('app.color.text_secondary'))
                    .borderRadius(16)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedProjectId = project.id
                      this.selectedProjectName = project.name
                    })
                })
              }
              .width('100%')
            }
            .width('100%')
            .margin({ top: 24 })
            .alignItems(HorizontalAlign.Start)
            .opacity(this.controlOpacity)
            .scale({ x: this.controlScale, y: this.controlScale })

            // 开始按钮
            Button(this.isPresetMode ? '开始预设' : '手动开始')
              .width('80%')
              .height(52)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary_green'))
              .borderRadius(26)
              .margin({ top: 32 })
              .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 4 })
              .onClick(() => {
                this.startTimer()
              })
              .opacity(this.controlOpacity)
              .scale({ x: this.controlScale, y: this.controlScale })
          }
          .width('100%')
          .padding(20)

        } else {
          // ===== 计时中面板 =====
          Column() {
            Text(this.selectedProjectName)
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 24, bottom: 8 })

            Text(this.isPresetMode ? '剩余时间' : '已专注时间')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))
              .margin({ bottom: 4 })

            // 计时显示
            Column() {
              Text(this.isPresetMode ?
                this.formatTime(this.remainingSeconds) :
                this.formatTime(this.elapsedSeconds))
                .fontSize(80)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .letterSpacing(4)

              if (this.isPresetMode) {
                // 进度条
                Progress({
                  value: this.presetMinutes * 60 - this.remainingSeconds,
                  total: this.presetMinutes * 60,
                  type: ProgressType.Linear
                })
                  .width('80%')
                  .height(8)
                  .color($r('app.color.primary_green'))
                  .backgroundColor($r('app.color.progress_track'))
                  .borderRadius(4)
                  .margin({ top: 20 })
              }

              if (this.isPaused) {
                Text('已暂停')
                  .fontSize(16)
                  .fontColor($r('app.color.accent_orange'))
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 12 })
              }
            }
            .padding({ top: 40, bottom: 40 })
            .width('100%')
            .backgroundColor($r('app.color.timer_bg'))
            .borderRadius(24)
            .margin({ top: 20 })

            // 控制按钮
            Row() {
              Button(this.isPaused ? '继续' : '暂停')
                .width(120)
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_blue'))
                .backgroundColor($r('app.color.primary_blue_light'))
                .borderRadius(24)
                .onClick(() => {
                  this.togglePause()
                })

              Button('结束')
                .width(120)
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .backgroundColor($r('app.color.primary_green'))
                .borderRadius(24)
                .margin({ left: 20 })
                .onClick(() => {
                  this.endTimer()
                })
            }
            .margin({ top: 32 })
          }
          .width('100%')
          .padding(20)
        }
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
