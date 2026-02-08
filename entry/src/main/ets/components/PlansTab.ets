/**
 * 计划与目标 Tab 组件
 * 功能：查看项目列表、跳转新建页面、进度可视化
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusProject } from '../model/DataModels'

@Component
export struct PlansTab {
  @State projects: FocusProject[] = []
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0

  aboutToAppear(): void {
    this.loadProjects()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadProjects()
  }

  private async loadProjects(): Promise<void> {
    this.projects = await PreferencesUtil.getProjects()
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
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('计划与目标')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Button('+ 新建')
          .height(36)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .backgroundColor($r('app.color.primary_green'))
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => {
            router.pushUrl({ url: 'pages/PlanCreatePage' })
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })
      .scale({ x: this.headerScale, y: this.headerScale })
      .opacity(this.headerOpacity)

      // 项目列表
      Scroll() {
        Column() {
          if (this.projects.length === 0) {
            Column() {
              Text('暂无')
                .fontSize(48)
                .margin({ bottom: 12 })
              Text('还没有项目')
                .fontSize(16)
                .fontColor($r('app.color.text_hint'))
              Text('点击右上角"+ 新建"创建你的第一个项目')
                .fontSize(13)
                .fontColor($r('app.color.text_hint'))
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 80 })
          } else {
            ForEach(this.projects, (project: FocusProject) => {
              Column() {
                // 项目名称和状态
                Row() {
                  Column() {
                    Text(project.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.text_primary'))
                    if (project.description !== '') {
                      Text(project.description)
                        .fontSize(13)
                        .fontColor($r('app.color.text_secondary'))
                        .margin({ top: 4 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Text(project.isActive ? '进行中' : '已完成')
                    .fontSize(12)
                    .fontColor(project.isActive ? $r('app.color.primary_green') : $r('app.color.text_hint'))
                    .backgroundColor(project.isActive ? $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .borderRadius(12)
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 进度条 - 时长
                if (project.totalGoalHours > 0) {
                  Column() {
                    Row() {
                      Text('时长进度')
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                      Blank()
                      Text(`${PreferencesUtil.formatDuration(project.completedMinutes)} / ${project.totalGoalHours}小时`)
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                    }
                    .width('100%')

                    Progress({
                      value: project.completedMinutes,
                      total: project.totalGoalHours * 60,
                      type: ProgressType.Linear
                    })
                      .width('100%')
                      .height(8)
                      .color($r('app.color.primary_green'))
                      .backgroundColor($r('app.color.progress_track'))
                      .borderRadius(4)
                      .margin({ top: 6 })
                  }
                  .margin({ bottom: 12 })
                }

                // 每日目标和其他信息
                Row() {
                  if (project.dailyGoalHours > 0) {
                    Column() {
                      Text(`${project.dailyGoalHours}h`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.primary_blue'))
                      Text('每日目标')
                        .fontSize(10)
                        .fontColor($r('app.color.text_hint'))
                    }
                    .layoutWeight(1)
                  }

                  if (project.totalGoalDays > 0) {
                    Column() {
                      Text(`${project.completedDays}/${project.totalGoalDays}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.accent_orange'))
                      Text('天数')
                        .fontSize(10)
                        .fontColor($r('app.color.text_hint'))
                    }
                    .layoutWeight(1)
                  }

                  Column() {
                    Text(PreferencesUtil.formatDuration(project.completedMinutes))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.primary_green'))
                    Text('已完成')
                      .fontSize(10)
                      .fontColor($r('app.color.text_hint'))
                  }
                  .layoutWeight(1)
                }
              }
              .width('100%')
              .padding(20)
              .margin({ left: 16, right: 16, bottom: 12 })
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(20)
              .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ProjectDetailPage',
                  params: { projectId: project.id }
                })
              })
            })
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
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
