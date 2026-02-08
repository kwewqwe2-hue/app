/**
 * FocusZone 主页
 * 使用 Tab + 自定义组件 实现底部导航
 */
import { FocusTimerTab } from '../components/FocusTimerTab'
import { PlansTab } from '../components/PlansTab'
import { CalendarTab } from '../components/CalendarTab'
import { NotebookTab } from '../components/NotebookTab'
import { GrowthTab } from '../components/GrowthTab'
import { ToolboxTab } from '../components/ToolboxTab'
import curves from '@ohos.curves'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State tabBarOpacity: number = 0
  @State tabBarTranslateY: number = 60
  @State @Watch('onRefreshChange') refreshCounter: number = 0
  @Provide('refreshCounter') refreshProvide: number = 0

  private tabTitles: string[] = ['专注', '计划', '日历', '记录', '成长', '工具箱']

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: curves.springCurve(0, 1, 328, 34)
      }, () => {
        this.tabBarOpacity = 1
        this.tabBarTranslateY = 0
      })
    }, 200)
  }

  onPageShow(): void {
    this.refreshCounter++
    this.refreshProvide = this.refreshCounter
  }

  onRefreshChange(): void {
    this.refreshProvide = this.refreshCounter
  }

  private getTabIcon(index: number): Resource {
    let icons: Resource[] = [
      $r('app.media.tab_focus'),
      $r('app.media.tab_plan'),
      $r('app.media.tab_calendar'),
      $r('app.media.tab_note'),
      $r('app.media.tab_growth'),
      $r('app.media.tab_toolbox')
    ]
    return icons[index]
  }

  @Builder
  tabBuilder(index: number) {
    Column() {
      Image(this.getTabIcon(index))
        .width(24)
        .height(24)
        .margin({ bottom: 2 })
        .objectFit(ImageFit.Contain)
      Text(this.tabTitles[index])
        .fontSize(9)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? $r('app.color.tab_active') : $r('app.color.tab_inactive'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          FocusTimerTab()
        }
        .tabBar(this.tabBuilder(0))

        TabContent() {
          PlansTab()
        }
        .tabBar(this.tabBuilder(1))

        TabContent() {
          CalendarTab()
        }
        .tabBar(this.tabBuilder(2))

        TabContent() {
          NotebookTab()
        }
        .tabBar(this.tabBuilder(3))

        TabContent() {
          GrowthTab()
        }
        .tabBar(this.tabBuilder(4))

        TabContent() {
          ToolboxTab()
        }
        .tabBar(this.tabBuilder(5))
      }
      .barHeight(56)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .opacity(this.tabBarOpacity)
      .translate({ y: this.tabBarTranslateY })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}
