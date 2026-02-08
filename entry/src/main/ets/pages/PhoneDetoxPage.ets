/**
 * 戒断手机页面
 * 用户保持在此页面计时，离开页面时显示戒断时长
 */
import router from '@ohos.router'
import curves from '@ohos.curves'

@Entry
@Component
struct PhoneDetoxPage {
  @State isActive: boolean = false
  @State elapsedSeconds: number = 0
  @State showResult: boolean = false
  @State resultSeconds: number = 0

  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State bodyScale: number = 0
  @State bodyOpacity: number = 0
  @State pulseScale: number = 1
  @State breatheOpacity: number = 0.3

  private timerId: number = -1

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
    if (this.isActive) {
      this.endDetox()
    }
    if (this.timerId !== -1) clearInterval(this.timerId)
  }

  private startDetox(): void {
    this.isActive = true
    this.elapsedSeconds = 0
    this.showResult = false
    this.timerId = setInterval(() => {
      this.elapsedSeconds++
    }, 1000)

    // 呼吸脉冲动画
    animateTo({
      duration: 2000, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate
    }, () => {
      this.pulseScale = 1.1
      this.breatheOpacity = 0.6
    })
  }

  private endDetox(): void {
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1 }
    this.resultSeconds = this.elapsedSeconds
    this.isActive = false
    this.showResult = true
    this.pulseScale = 1
    this.breatheOpacity = 0.3
  }

  private formatTime(seconds: number): string {
    let h = Math.floor(seconds / 3600)
    let m = Math.floor((seconds % 3600) / 60)
    let s = seconds % 60
    let ms = m.toString().padStart(2, '0')
    let ss = s.toString().padStart(2, '0')
    if (h > 0) {
      return `${h}:${ms}:${ss}`
    }
    return `${ms}:${ss}`
  }

  private getEncouragement(): string {
    if (this.resultSeconds >= 3600) return '太厉害了！超过一小时的自控力！'
    if (this.resultSeconds >= 1800) return '半小时以上，你的意志力很强！'
    if (this.resultSeconds >= 600) return '十分钟很棒了，继续加油！'
    if (this.resultSeconds >= 120) return '不错的开始，下次更久一点！'
    return '每一次尝试都是进步！'
  }

  build() {
    Column() {
      // 顶栏：只在非活跃时显示返回按钮
      Row() {
        if (!this.isActive) {
          Button('←').width(40).height(40).fontSize(20)
            .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
            .borderRadius(20).onClick(() => { router.back() })
        }
        Text('戒断手机').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: this.isActive ? 0 : 12 }).layoutWeight(1)
          .textAlign(this.isActive ? TextAlign.Center : TextAlign.Start)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Column() {
        if (this.showResult) {
          // ===== 结果页 =====
          Text('恭喜').fontSize(60).margin({ bottom: 16 })
          Text('恭喜你完成戒断！').fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_green'))

          Text(this.formatTime(this.resultSeconds))
            .fontSize(56).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_blue')).margin({ top: 16, bottom: 8 })

          Text(this.getEncouragement())
            .fontSize(15).fontColor($r('app.color.text_secondary')).margin({ bottom: 32 })
            .textAlign(TextAlign.Center).padding({ left: 20, right: 20 })

          Button('再来一次').width('60%').height(48).fontSize(16).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(24)
            .onClick(() => { this.showResult = false })

          Button('返回').width('60%').height(40).fontSize(14)
            .fontColor($r('app.color.text_secondary')).backgroundColor($r('app.color.bg_surface'))
            .borderRadius(20).margin({ top: 12 })
            .onClick(() => { router.back() })

        } else if (this.isActive) {
          // ===== 计时中 =====
          Text('禁').fontSize(60).margin({ bottom: 12 })

          Text('保持在这个页面').fontSize(16).fontColor($r('app.color.text_secondary'))

          // 大计时器
          Stack() {
            Circle().width(220).height(220)
              .fill($r('app.color.primary_green'))
              .opacity(this.breatheOpacity * 0.3)
              .scale({ x: this.pulseScale, y: this.pulseScale })

            Circle().width(180).height(180)
              .fill($r('app.color.primary_green'))
              .opacity(this.breatheOpacity * 0.5)
              .scale({ x: this.pulseScale, y: this.pulseScale })

            Column() {
              Text(this.formatTime(this.elapsedSeconds))
                .fontSize(48).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
              Text('已戒断').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
            }
          }
          .margin({ top: 32, bottom: 32 })

          Text('离开此页面或点击下方按钮结束计时')
            .fontSize(12).fontColor($r('app.color.text_hint')).margin({ bottom: 24 })

          Button('结束戒断').width('60%').height(48).fontSize(16).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).backgroundColor($r('app.color.accent_orange')).borderRadius(24)
            .onClick(() => { this.endDetox() })

        } else {
          // ===== 未开始 =====
          Text('禁').fontSize(70).margin({ bottom: 16 })
          Text('戒断手机挑战').fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
          Text('开始后请保持在此页面\n不要切换到其他应用\n离开即结束计时')
            .fontSize(14).fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center).lineHeight(22).margin({ bottom: 40 })

          Button('开始戒断').width('70%').height(56).fontSize(20).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(28)
            .shadow({ radius: 10, color: $r('app.color.shadow_color'), offsetY: 4 })
            .onClick(() => { this.startDetox() })
        }
      }
      .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
