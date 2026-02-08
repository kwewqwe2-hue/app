/**
 * 设置 Tab 组件
 * 功能：深色模式切换、应用信息、数据管理
 */
import curves from '@ohos.curves'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant'
import common from '@ohos.app.ability.common'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { UserGrowth } from '../model/DataModels'

@Component
export struct SettingsTab {
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number
  @State isDarkMode: boolean = false
  @State growth: UserGrowth = {
    totalPoints: 0,
    treeStage: 0,
    totalFocusMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastActiveDate: ''
  }

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State card1Scale: number = 0
  @State card1Opacity: number = 0
  @State card2Scale: number = 0
  @State card2Opacity: number = 0
  @State card3Scale: number = 0
  @State card3Opacity: number = 0

  aboutToAppear(): void {
    this.loadData()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    this.growth = await PreferencesUtil.getUserGrowth()
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
        duration: 700,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.card1Scale = 1
        this.card1Opacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.card2Scale = 1
        this.card2Opacity = 1
      })
    }, 400)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 260, 26)
      }, () => {
        this.card3Scale = 1
        this.card3Opacity = 1
      })
    }, 550)
  }

  // 切换深色模式（由 Toggle onChange 调用，isOn 已是最新值）
  private applyColorMode(isDark: boolean): void {
    try {
      let context = getContext(this) as common.UIAbilityContext
      if (isDark) {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      } else {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      }
    } catch (e) {
      // fallback
    }
  }

  private getTreeStageName(): string {
    let names: string[] = ['种子', '嫩芽', '小树', '茂盛树', '开花树', '参天大树']
    return this.growth.treeStage < names.length ? names[this.growth.treeStage] : '参天大树'
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })
      .scale({ x: this.headerScale, y: this.headerScale })
      .opacity(this.headerOpacity)

      Scroll() {
        Column() {

          // ===== 外观设置 =====
          Column() {
            Text('外观')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            // 深色模式
            Row() {
              Column() {
                Text('深色模式')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                Text('切换应用到深色主题')
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
            .padding({ top: 4, bottom: 4 })
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.card1Scale, y: this.card1Scale })
          .opacity(this.card1Opacity)

          // ===== 我的数据 =====
          Column() {
            Text('我的数据')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text(`${this.growth.totalPoints}`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.accent_orange'))
                Text('总积分')
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(PreferencesUtil.formatDuration(this.growth.totalFocusMinutes))
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_green'))
                Text('总时长')
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(`${this.growth.currentStreak}天`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_blue'))
                Text('连续打卡')
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 分割线
            Divider().color($r('app.color.divider')).margin({ bottom: 12 })

            Row() {
              Text('最长连续打卡')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
              Blank()
              Text(`${this.growth.longestStreak} 天`)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('生命之树阶段')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
              Blank()
              Text(this.getTreeStageName())
                .fontSize(14)
                .fontColor($r('app.color.primary_green'))
                .fontWeight(FontWeight.Bold)
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('上次活跃')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
              Blank()
              Text(this.growth.lastActiveDate !== '' ? this.growth.lastActiveDate : '暂无')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }.width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.card2Scale, y: this.card2Scale })
          .opacity(this.card2Opacity)

          // ===== 关于 =====
          Column() {
            // Logo
            Stack() {
              Circle()
                .width(64).height(64)
                .fill($r('app.color.primary_green_light'))
              Text('🌿')
                .fontSize(32)
            }
            .margin({ bottom: 12 })

            Text('FocusZone')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))

            Text('专注力管理与激励工具')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4, bottom: 16 })

            Divider().color($r('app.color.divider')).margin({ bottom: 12 })

            Row() {
              Text('版本')
                .fontSize(14).fontColor($r('app.color.text_primary'))
              Blank()
              Text('1.0.0')
                .fontSize(14).fontColor($r('app.color.text_secondary'))
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('平台')
                .fontSize(14).fontColor($r('app.color.text_primary'))
              Blank()
              Text('HarmonyOS 6.0.2')
                .fontSize(14).fontColor($r('app.color.text_secondary'))
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('数据存储')
                .fontSize(14).fontColor($r('app.color.text_primary'))
              Blank()
              Text('本地存储')
                .fontSize(14).fontColor($r('app.color.success_green'))
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('隐私')
                .fontSize(14).fontColor($r('app.color.text_primary'))
              Blank()
              Text('所有数据仅存储在本地')
                .fontSize(12).fontColor($r('app.color.success_green'))
            }.width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 40 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.card3Scale, y: this.card3Scale })
          .opacity(this.card3Opacity)
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
