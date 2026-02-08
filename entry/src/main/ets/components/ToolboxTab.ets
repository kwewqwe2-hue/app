/**
 * 工具箱 Tab 组件
 * 8 大专注工具 + 设置（深色模式）
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant'
import common from '@ohos.app.ability.common'

@Component
export struct ToolboxTab {
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number
  @State isDarkMode: boolean = false

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State gridScales: number[] = [0, 0, 0, 0, 0, 0, 0, 0]
  @State gridOpacities: number[] = [0, 0, 0, 0, 0, 0, 0, 0]
  @State settingsScale: number = 0
  @State settingsOpacity: number = 0

  aboutToAppear(): void {
    this.playEntranceAnimation()
  }

  onRefresh(): void {
  }

  private playEntranceAnimation(): void {
    setTimeout(() => {
      animateTo({
        duration: 700, curve: curves.springCurve(0, 1, 328, 34)
      }, () => {
        this.headerScale = 1
        this.headerOpacity = 1
      })
    }, 100)

    // 工具卡片逐个弹入
    for (let i = 0; i < 8; i++) {
      let delay = 200 + i * 60
      setTimeout(() => {
        animateTo({
          duration: 600, curve: curves.springCurve(0, 1, 300, 28)
        }, () => {
          this.gridScales[i] = 1
          this.gridOpacities[i] = 1
        })
      }, delay)
    }

    setTimeout(() => {
      animateTo({
        duration: 500, curve: curves.springCurve(0, 1, 280, 26)
      }, () => {
        this.settingsScale = 1
        this.settingsOpacity = 1
      })
    }, 750)
  }

  private applyColorMode(isDark: boolean): void {
    try {
      let context = getContext(this) as common.UIAbilityContext
      if (isDark) {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      } else {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      }
    } catch (e) {
    }
  }

  private getToolIcon(index: number): string {
    let icons: string[] = ['音', '呼', '星', '记', '杯', '图', '标', '禁']
    return icons[index]
  }

  private getToolName(index: number): string {
    let names: string[] = ['白噪音', '呼吸练习', '专注评分', '专注日记', '每日挑战', '专注报告', '目标追踪', '戒断手机']
    return names[index]
  }

  private getToolDesc(index: number): string {
    let descs: string[] = [
      '雨声/咖啡厅环境音',
      '1-3分钟引导呼吸',
      '自评1-5星+中断原因',
      '简短复盘今日成果',
      '连续7天解锁成就',
      '周/月时段分布',
      '本周计划完成进度',
      '保持界面计时戒断'
    ]
    return descs[index]
  }

  private getToolColor(index: number): string {
    let colors: string[] = [
      '#E3F2FD', '#E8F5E9', '#FFF3E0', '#F3E5F5',
      '#FFF8E1', '#E0F2F1', '#FCE4EC', '#EFEBE9'
    ]
    return colors[index]
  }

  private getToolRoute(index: number): string {
    let routes: string[] = [
      'pages/WhiteNoisePage',
      'pages/BreathingPage',
      'pages/FocusRatingPage',
      'pages/FocusDiaryPage',
      'pages/ChallengesPage',
      'pages/FocusReportPage',
      'pages/GoalTrackingPage',
      'pages/PhoneDetoxPage'
    ]
    return routes[index]
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('工具箱')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .scale({ x: this.headerScale, y: this.headerScale })
      .opacity(this.headerOpacity)

      Scroll() {
        Column() {
          // 工具网格 (2列4行)
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach([0, 1, 2, 3, 4, 5, 6, 7], (index: number) => {
              Column() {
                Text(this.getToolIcon(index))
                  .fontSize(32)
                  .margin({ bottom: 8 })

                Text(this.getToolName(index))
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))

                Text(this.getToolDesc(index))
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
                  .textAlign(TextAlign.Center)
                  .maxLines(2)
              }
              .width('47%')
              .padding({ top: 20, bottom: 20, left: 12, right: 12 })
              .margin({ bottom: 12 })
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(20)
              .alignItems(HorizontalAlign.Center)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
              .scale({
                x: index < this.gridScales.length ? this.gridScales[index] : 1,
                y: index < this.gridScales.length ? this.gridScales[index] : 1
              })
              .opacity(index < this.gridOpacities.length ? this.gridOpacities[index] : 1)
              .onClick(() => {
                router.pushUrl({ url: this.getToolRoute(index) })
              })
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 设置区域
          Column() {
            Text('设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text('深色模式')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                Text('切换深色主题')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
                .selectedColor($r('app.color.primary_green'))
                .switchPointColor(Color.White)
                .onChange((isOn: boolean) => {
                  this.isDarkMode = isOn
                  this.applyColorMode(isOn)
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, top: 4, bottom: 40 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.settingsScale, y: this.settingsScale })
          .opacity(this.settingsOpacity)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
  }
}
