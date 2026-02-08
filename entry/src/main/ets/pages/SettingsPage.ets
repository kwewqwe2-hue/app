/**
 * 设置页面（二级页面）
 * 不使用自定义组件，所有 UI 在 ArkUI 中直接构建
 * 包含应用信息、版本、关于等
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { UserGrowth } from '../model/DataModels'

@Entry
@Component
struct SettingsPage {
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
  @State aboutScale: number = 0
  @State aboutOpacity: number = 0
  @State statsScale: number = 0
  @State statsOpacity: number = 0
  @State infoScale: number = 0
  @State infoOpacity: number = 0

  aboutToAppear(): void {
    this.loadData()
    this.playEntranceAnimation()
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
        duration: 800,
        curve: curves.springCurve(0, 1, 300, 28)
      }, () => {
        this.aboutScale = 1
        this.aboutOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 280, 26)
      }, () => {
        this.statsScale = 1
        this.statsOpacity = 1
      })
    }, 400)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 260, 24)
      }, () => {
        this.infoScale = 1
        this.infoOpacity = 1
      })
    }, 550)
  }

  @Builder
  buildSettingRow(title: string, value: string) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
      Text(value)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .border({
      width: { bottom: 0.5 },
      color: $r('app.color.divider')
    })
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

        Text('设置')
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

      Scroll() {
        Column() {
          // 应用介绍
          Column() {
            // Logo区域
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill($r('app.color.primary_green_light'))

              Text('F')
                .fontSize(40)
            }
            .margin({ bottom: 16 })

            Text('FocusZone')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_green'))

            Text('专注力管理与激励工具')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 6, bottom: 12 })

            Text('集番茄时钟、习惯追踪、进度可视化、游戏化激励和轻量笔记于一体的综合性专注力辅助工具。帮助你建立专注习惯，培育属于你的生命之树。')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
              .lineHeight(20)
              .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .padding(24)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.aboutScale, y: this.aboutScale })
          .opacity(this.aboutOpacity)

          // 我的数据
          Column() {
            Text('我的数据')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 8 })

            this.buildSettingRow('总积分', `${this.growth.totalPoints} 分`)
            this.buildSettingRow('总专注时长',
              PreferencesUtil.formatDuration(this.growth.totalFocusMinutes))
            this.buildSettingRow('当前连续打卡', `${this.growth.currentStreak} 天`)
            this.buildSettingRow('最长连续打卡', `${this.growth.longestStreak} 天`)
            this.buildSettingRow('生命之树阶段',
              `${ ['种子', '嫩芽', '小树', '茂盛树', '开花树', '参天大树'][this.growth.treeStage]}`)
            this.buildSettingRow('上次活跃',
              this.growth.lastActiveDate !== '' ? this.growth.lastActiveDate : '暂无记录')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.statsScale, y: this.statsScale })
          .opacity(this.statsOpacity)

          // 应用信息
          Column() {
            Text('应用信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 8 })

            this.buildSettingRow('应用名称', 'FocusZone')
            this.buildSettingRow('版本号', '1.0.0')
            this.buildSettingRow('目标平台', 'HarmonyOS 6.0.2')
            this.buildSettingRow('SDK版本', 'API 12+')
            this.buildSettingRow('开发框架', 'ArkTS / ArkUI')
            this.buildSettingRow('数据存储', '本地存储 (Preferences)')

            Row() {
              Text('隐私说明')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
              Text('所有数据仅存储在本地，保护您的隐私')
                .fontSize(12)
                .fontColor($r('app.color.success_green'))
            }
            .width('100%')
            .padding({ top: 14, bottom: 14 })
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.infoScale, y: this.infoScale })
          .opacity(this.infoOpacity)

          // 功能特色
          Column() {
            Text('功能特色')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            Column() {
              this.buildFeatureItem('时', '专注计时', '预设/手动双模式计时，番茄钟工作法')
              this.buildFeatureItem('划', '计划管理', '创建项目，设定目标，追踪进度')
              this.buildFeatureItem('历', '专注日历', '月历展示专注记录，可视化热力图')
              this.buildFeatureItem('树', '成长系统', '积分激励，生命之树六阶段成长')
              this.buildFeatureItem('录', '智能笔记', '长期计划/短期备忘/个人收藏')
              this.buildFeatureItem('图', '关键词分析', '自动分析笔记内容，提取关键词热度')
            }
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 40 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.infoScale, y: this.infoScale })
          .opacity(this.infoOpacity)
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

  @Builder
  buildFeatureItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .width(40)
        .textAlign(TextAlign.Center)

      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(desc)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }
}
