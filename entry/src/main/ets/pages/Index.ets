/**
 * FocusZone 主页
 * 使用 Tab + 自定义组件 实现底部导航
 */
import { FocusTimerTab } from '../components/FocusTimerTab'
import { PlansTab } from '../components/PlansTab'
import { CalendarTab } from '../components/CalendarTab'
import { NotebookTab } from '../components/NotebookTab'
import { GrowthTab } from '../components/GrowthTab'
import curves from '@ohos.curves'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State tabBarOpacity: number = 0
  @State tabBarTranslateY: number = 60
  // 刷新计数器：每次从二级页面返回时 +1，通知子组件刷新数据
  @State @Watch('onRefreshChange') refreshCounter: number = 0
  @Provide('refreshCounter') refreshProvide: number = 0

  // Tab 项配置
  private tabItems: TabItemInfo[] = [
    { title: '专注', icon: '⏱', activeIcon: '⏱' },
    { title: '计划', icon: '📋', activeIcon: '📋' },
    { title: '日历', icon: '📅', activeIcon: '📅' },
    { title: '笔记', icon: '📝', activeIcon: '📝' },
    { title: '成长', icon: '🌳', activeIcon: '🌳' }
  ]

  aboutToAppear(): void {
    // Tab 栏入场弹性动画
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

  // 从二级页面返回时触发刷新
  onPageShow(): void {
    this.refreshCounter++
    this.refreshProvide = this.refreshCounter
  }

  onRefreshChange(): void {
    this.refreshProvide = this.refreshCounter
  }

  @Builder
  tabBuilder(index: number) {
    Column() {
      Text(this.tabItems[index].icon)
        .fontSize(24)
        .margin({ bottom: 2 })
      Text(this.tabItems[index].title)
        .fontSize(10)
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
        // Tab 1: 专注计时器
        TabContent() {
          FocusTimerTab()
        }
        .tabBar(this.tabBuilder(0))

        // Tab 2: 计划与目标
        TabContent() {
          PlansTab()
        }
        .tabBar(this.tabBuilder(1))

        // Tab 3: 专注日历
        TabContent() {
          CalendarTab()
        }
        .tabBar(this.tabBuilder(2))

        // Tab 4: 智能记录本
        TabContent() {
          NotebookTab()
        }
        .tabBar(this.tabBuilder(3))

        // Tab 5: 成长系统
        TabContent() {
          GrowthTab()
        }
        .tabBar(this.tabBuilder(4))
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

// Tab 项信息接口
interface TabItemInfo {
  title: string
  icon: string
  activeIcon: string
}
