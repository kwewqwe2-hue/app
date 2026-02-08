/**
 * 白噪音/环境音页面
 * 雨声、咖啡厅两种声音，带音量控制和计时
 */
import router from '@ohos.router'
import curves from '@ohos.curves'

@Entry
@Component
struct WhiteNoisePage {
  @State currentSound: number = -1 // -1无, 0雨声, 1咖啡厅
  @State isPlaying: boolean = false
  @State volume: number = 70
  @State timerSeconds: number = 0
  @State timerRunning: boolean = false

  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State cardScale: number = 0
  @State cardOpacity: number = 0
  @State waveOffset: number = 0

  private timerId: number = -1

  aboutToAppear(): void {
    this.playEntranceAnimation()
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
  }

  private playEntranceAnimation(): void {
    setTimeout(() => {
      animateTo({ duration: 700, curve: curves.springCurve(0, 1, 328, 34) }, () => {
        this.headerScale = 1; this.headerOpacity = 1
      })
    }, 100)
    setTimeout(() => {
      animateTo({ duration: 800, curve: curves.springCurve(0, 1, 300, 28) }, () => {
        this.cardScale = 1; this.cardOpacity = 1
      })
    }, 250)
    // 波浪动画
    setTimeout(() => {
      animateTo({ duration: 3000, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
        this.waveOffset = 10
      })
    }, 500)
  }

  private selectSound(index: number): void {
    if (this.currentSound === index) {
      this.isPlaying = !this.isPlaying
    } else {
      this.currentSound = index
      this.isPlaying = true
    }
    if (this.isPlaying && !this.timerRunning) {
      this.startTimer()
    }
    if (!this.isPlaying) {
      this.stopTimer()
    }
  }

  private startTimer(): void {
    this.timerRunning = true
    this.timerSeconds = 0
    this.timerId = setInterval(() => {
      this.timerSeconds++
    }, 1000)
  }

  private stopTimer(): void {
    this.timerRunning = false
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1 }
  }

  private formatTime(seconds: number): string {
    let m = Math.floor(seconds / 60).toString().padStart(2, '0')
    let s = (seconds % 60).toString().padStart(2, '0')
    return `${m}:${s}`
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { this.stopTimer(); router.back() })
        Text('白噪音').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          // 播放状态视觉
          Column() {
            if (this.isPlaying) {
              // 波形动画
              Row() {
                ForEach([16, 24, 32, 20, 28, 36, 22, 30, 18, 26], (h: number, i: number) => {
                  Row()
                    .width(4).height(h + (i !== undefined && i % 2 === 0 ? this.waveOffset : -this.waveOffset))
                    .borderRadius(2)
                    .backgroundColor(this.currentSound === 0 ? '#42A5F5' : '#8D6E63')
                    .margin({ left: 3, right: 3 })
                    .opacity(0.7)
                })
              }
              .margin({ bottom: 16 })

              Text(this.currentSound === 0 ? '🌧 雨声播放中...' : '☕ 咖啡厅音播放中...')
                .fontSize(18).fontColor($r('app.color.text_primary')).fontWeight(FontWeight.Bold)

              Text(this.formatTime(this.timerSeconds))
                .fontSize(40).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_blue')).margin({ top: 8 })
            } else {
              Text('🎵').fontSize(60).margin({ bottom: 8 })
              Text('选择一种环境音开始放松')
                .fontSize(16).fontColor($r('app.color.text_secondary'))
            }
          }
          .width('100%').padding({ top: 40, bottom: 40 })
          .alignItems(HorizontalAlign.Center)

          // 声音选择卡片
          Row() {
            // 雨声
            Column() {
              Text('🌧').fontSize(40).margin({ bottom: 8 })
              Text('雨声').fontSize(16).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
              Text('静谧雨夜').fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 4 })

              if (this.currentSound === 0 && this.isPlaying) {
                Text('播放中').fontSize(11).fontColor('#42A5F5')
                  .fontWeight(FontWeight.Bold).margin({ top: 8 })
              }
            }
            .layoutWeight(1)
            .padding(24)
            .backgroundColor(this.currentSound === 0 && this.isPlaying ? '#E3F2FD' : $r('app.color.bg_card'))
            .borderRadius(20)
            .alignItems(HorizontalAlign.Center)
            .border({ width: this.currentSound === 0 && this.isPlaying ? 2 : 0, color: '#42A5F5' })
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
            .onClick(() => { this.selectSound(0) })

            Column().width(12)

            // 咖啡厅
            Column() {
              Text('☕').fontSize(40).margin({ bottom: 8 })
              Text('咖啡厅').fontSize(16).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
              Text('舒适嘈杂').fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 4 })

              if (this.currentSound === 1 && this.isPlaying) {
                Text('播放中').fontSize(11).fontColor('#8D6E63')
                  .fontWeight(FontWeight.Bold).margin({ top: 8 })
              }
            }
            .layoutWeight(1)
            .padding(24)
            .backgroundColor(this.currentSound === 1 && this.isPlaying ? '#EFEBE9' : $r('app.color.bg_card'))
            .borderRadius(20)
            .alignItems(HorizontalAlign.Center)
            .border({ width: this.currentSound === 1 && this.isPlaying ? 2 : 0, color: '#8D6E63' })
            .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
            .onClick(() => { this.selectSound(1) })
          }
          .width('100%').padding({ left: 16, right: 16 })

          // 音量控制
          Column() {
            Row() {
              Text('🔊 音量').fontSize(14).fontColor($r('app.color.text_secondary'))
              Blank()
              Text(`${this.volume}%`).fontSize(14).fontColor($r('app.color.text_primary')).fontWeight(FontWeight.Bold)
            }.width('100%').margin({ bottom: 8 })

            Slider({ value: this.volume, min: 0, max: 100, step: 5 })
              .blockColor($r('app.color.primary_blue'))
              .trackColor($r('app.color.progress_track'))
              .selectedColor($r('app.color.primary_blue'))
              .onChange((value: number) => { this.volume = value })
          }
          .width('100%').padding(20)
          .margin({ left: 16, right: 16, top: 16 })
          .backgroundColor($r('app.color.bg_card')).borderRadius(20)
          .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 停止按钮
          if (this.isPlaying) {
            Button('停止播放').width('60%').height(48).fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor(Color.White).backgroundColor($r('app.color.error_red')).borderRadius(24)
              .margin({ top: 24 })
              .onClick(() => { this.isPlaying = false; this.stopTimer() })
          }

          // 提示
          Text('提示：白噪音为视觉模拟，实际音频需配合系统媒体播放')
            .fontSize(11).fontColor($r('app.color.text_hint'))
            .margin({ top: 20, bottom: 40 }).textAlign(TextAlign.Center)
        }.width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
