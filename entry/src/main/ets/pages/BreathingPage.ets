/**
 * 呼吸练习页面
 * 1-3分钟引导呼吸：吸气-屏气-呼气 循环
 */
import router from '@ohos.router'
import curves from '@ohos.curves'

@Entry
@Component
struct BreathingPage {
  @State selectedDuration: number = 1 // 1,2,3分钟
  @State isRunning: boolean = false
  @State phase: string = '准备' // 准备/吸气/屏气/呼气/完成
  @State phaseSeconds: number = 0
  @State totalSeconds: number = 0
  @State circleScale: number = 0.5
  @State circleOpacity: number = 0.3
  @State cycleCount: number = 0

  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State bodyScale: number = 0
  @State bodyOpacity: number = 0

  private timerId: number = -1
  // 吸气4秒-屏气4秒-呼气6秒=14秒一循环
  private inhaleTime: number = 4
  private holdTime: number = 4
  private exhaleTime: number = 6

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 700, curve: curves.springCurve(0, 1, 328, 34) }, () => {
        this.headerScale = 1; this.headerOpacity = 1
      })
    }, 100)
    setTimeout(() => {
      animateTo({ duration: 800, curve: curves.springCurve(0, 1, 300, 28) }, () => {
        this.bodyScale = 1; this.bodyOpacity = 1
      })
    }, 250)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
  }

  private startBreathing(): void {
    this.isRunning = true
    this.totalSeconds = 0
    this.phase = '吸气'
    this.phaseSeconds = 0
    this.cycleCount = 0
    this.animateInhale()

    this.timerId = setInterval(() => {
      this.totalSeconds++
      this.phaseSeconds++

      if (this.phase === '吸气' && this.phaseSeconds >= this.inhaleTime) {
        this.phase = '屏气'
        this.phaseSeconds = 0
        this.animateHold()
      } else if (this.phase === '屏气' && this.phaseSeconds >= this.holdTime) {
        this.phase = '呼气'
        this.phaseSeconds = 0
        this.animateExhale()
      } else if (this.phase === '呼气' && this.phaseSeconds >= this.exhaleTime) {
        this.cycleCount++
        if (this.totalSeconds >= this.selectedDuration * 60) {
          this.finish()
          return
        }
        this.phase = '吸气'
        this.phaseSeconds = 0
        this.animateInhale()
      }
    }, 1000)
  }

  private animateInhale(): void {
    animateTo({ duration: this.inhaleTime * 1000, curve: Curve.EaseInOut }, () => {
      this.circleScale = 1.0
      this.circleOpacity = 0.8
    })
  }

  private animateHold(): void {
    // 保持不变
  }

  private animateExhale(): void {
    animateTo({ duration: this.exhaleTime * 1000, curve: Curve.EaseInOut }, () => {
      this.circleScale = 0.5
      this.circleOpacity = 0.3
    })
  }

  private finish(): void {
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1 }
    this.phase = '完成'
    this.isRunning = false
  }

  private stop(): void {
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1 }
    this.isRunning = false
    this.phase = '准备'
    this.circleScale = 0.5
    this.circleOpacity = 0.3
  }

  private getPhaseColor(): ResourceColor {
    if (this.phase === '吸气') return '#4CAF50'
    if (this.phase === '屏气') return '#FF9800'
    if (this.phase === '呼气') return '#42A5F5'
    if (this.phase === '完成') return '#66BB6A'
    return $r('app.color.primary_green')
  }

  private getRemainingPhaseSeconds(): number {
    if (this.phase === '吸气') return this.inhaleTime - this.phaseSeconds
    if (this.phase === '屏气') return this.holdTime - this.phaseSeconds
    if (this.phase === '呼气') return this.exhaleTime - this.phaseSeconds
    return 0
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { this.stop(); router.back() })
        Text('呼吸练习').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Column() {
        if (!this.isRunning && this.phase !== '完成') {
          // 选择时长
          Text('选择练习时长').fontSize(16).fontColor($r('app.color.text_secondary')).margin({ bottom: 16 })
          Row() {
            ForEach([1, 2, 3], (min: number) => {
              Button(`${min}分钟`).height(40).fontSize(14)
                .backgroundColor(this.selectedDuration === min ? $r('app.color.primary_green') : $r('app.color.bg_surface'))
                .fontColor(this.selectedDuration === min ? Color.White : $r('app.color.text_secondary'))
                .borderRadius(20).margin({ left: 8, right: 8 })
                .onClick(() => { this.selectedDuration = min })
            })
          }.margin({ bottom: 32 })

          Text('吸气4秒 → 屏气4秒 → 呼气6秒')
            .fontSize(13).fontColor($r('app.color.text_hint')).margin({ bottom: 32 })

          Button('开始呼吸').width('70%').height(52).fontSize(18).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(26)
            .onClick(() => { this.startBreathing() })

        } else if (this.phase === '完成') {
          Text('恭喜').fontSize(60).margin({ bottom: 16 })
          Text('呼吸练习完成！').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
          Text(`完成 ${this.cycleCount} 个呼吸循环`)
            .fontSize(14).fontColor($r('app.color.text_secondary')).margin({ top: 8, bottom: 32 })
          Button('再来一次').width('60%').height(44).fontSize(16)
            .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(22)
            .onClick(() => { this.phase = '准备'; this.circleScale = 0.5; this.circleOpacity = 0.3 })

        } else {
          // 呼吸动画圆圈
          Stack() {
            Circle().width(200).height(200)
              .fill(this.getPhaseColor())
              .opacity(this.circleOpacity)
              .scale({ x: this.circleScale, y: this.circleScale })

            Column() {
              Text(this.phase)
                .fontSize(28).fontWeight(FontWeight.Bold).fontColor(Color.White)
              Text(`${this.getRemainingPhaseSeconds()}`)
                .fontSize(48).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 4 })
            }
          }
          .margin({ top: 20, bottom: 24 })

          Text(`第 ${this.cycleCount + 1} 个循环`)
            .fontSize(14).fontColor($r('app.color.text_secondary'))

          Text(`总计 ${Math.floor(this.totalSeconds / 60)}:${(this.totalSeconds % 60).toString().padStart(2, '0')}`)
            .fontSize(16).fontColor($r('app.color.text_primary')).fontWeight(FontWeight.Bold).margin({ top: 8 })

          Button('结束').width('50%').height(44).fontSize(16)
            .fontColor(Color.White).backgroundColor($r('app.color.error_red')).borderRadius(22)
            .margin({ top: 32 })
            .onClick(() => { this.finish() })
        }
      }
      .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
