/**
 * 计划与目标 Tab 组件
 * 功能：创建/查看项目、进度可视化
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusProject } from '../model/DataModels'

@Component
export struct PlansTab {
  @State projects: FocusProject[] = []
  @State showCreateForm: boolean = false

  // 创建表单字段
  @State formName: string = ''
  @State formDesc: string = ''
  @State formTotalHours: string = ''
  @State formDailyHours: string = ''
  @State formTotalDays: string = ''

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State listScales: number[] = []
  @State listOpacities: number[] = []
  @State formScale: number = 0
  @State formOpacity: number = 0

  aboutToAppear(): void {
    this.loadProjects()
    this.playEntranceAnimation()
  }

  private async loadProjects(): Promise<void> {
    this.projects = await PreferencesUtil.getProjects()
    // 初始化列表动画状态
    this.listScales = []
    this.listOpacities = []
    for (let i = 0; i < this.projects.length; i++) {
      this.listScales.push(0)
      this.listOpacities.push(0)
    }

    // 列表项逐个弹性入场
    for (let i = 0; i < this.projects.length; i++) {
      let delay = 400 + i * 100
      setTimeout(() => {
        animateTo({
          duration: 700,
          curve: curves.springCurve(0, 1, 300, 30)
        }, () => {
          if (i < this.listScales.length) {
            this.listScales[i] = 1
            this.listOpacities[i] = 1
          }
        })
      }, delay)
    }
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

  private async createProject(): Promise<void> {
    if (this.formName.trim() === '') return

    let project: FocusProject = {
      id: PreferencesUtil.generateId(),
      name: this.formName.trim(),
      description: this.formDesc.trim(),
      totalGoalHours: parseFloat(this.formTotalHours) || 0,
      dailyGoalHours: parseFloat(this.formDailyHours) || 0,
      totalGoalDays: parseInt(this.formTotalDays) || 0,
      completedMinutes: 0,
      completedDays: 0,
      createdAt: Date.now(),
      isActive: true
    }

    await PreferencesUtil.saveProject(project)
    this.showCreateForm = false
    this.resetForm()
    this.loadProjects()
  }

  private resetForm(): void {
    this.formName = ''
    this.formDesc = ''
    this.formTotalHours = ''
    this.formDailyHours = ''
    this.formTotalDays = ''
  }

  build() {
    Scroll() {
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
              this.showCreateForm = !this.showCreateForm
              if (this.showCreateForm) {
                this.formScale = 0
                this.formOpacity = 0
                setTimeout(() => {
                  animateTo({
                    duration: 600,
                    curve: curves.springCurve(0, 1, 300, 28)
                  }, () => {
                    this.formScale = 1
                    this.formOpacity = 1
                  })
                }, 50)
              }
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale })
        .opacity(this.headerOpacity)

        // 创建表单
        if (this.showCreateForm) {
          Column() {
            Text('创建新项目')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 16 })

            // 项目名称
            TextInput({ placeholder: '项目名称（如：学习英语）' })
              .width('100%')
              .height(44)
              .fontSize(14)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .margin({ bottom: 12 })
              .onChange((value: string) => { this.formName = value })

            // 项目描述
            TextInput({ placeholder: '项目描述' })
              .width('100%')
              .height(44)
              .fontSize(14)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .margin({ bottom: 12 })
              .onChange((value: string) => { this.formDesc = value })

            Row() {
              TextInput({ placeholder: '总目标(小时)' })
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .type(InputType.Number)
                .backgroundColor($r('app.color.bg_surface'))
                .borderRadius(12)
                .margin({ right: 8 })
                .onChange((value: string) => { this.formTotalHours = value })

              TextInput({ placeholder: '每日目标(小时)' })
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .type(InputType.Number)
                .backgroundColor($r('app.color.bg_surface'))
                .borderRadius(12)
                .onChange((value: string) => { this.formDailyHours = value })
            }
            .width('100%')
            .margin({ bottom: 12 })

            TextInput({ placeholder: '总天数（如：30天）' })
              .width('100%')
              .height(44)
              .fontSize(14)
              .type(InputType.Number)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .margin({ bottom: 16 })
              .onChange((value: string) => { this.formTotalDays = value })

            Row() {
              Button('取消')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .backgroundColor($r('app.color.bg_surface'))
                .fontColor($r('app.color.text_secondary'))
                .borderRadius(22)
                .margin({ right: 12 })
                .onClick(() => {
                  this.showCreateForm = false
                  this.resetForm()
                })

              Button('创建')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .backgroundColor($r('app.color.primary_green'))
                .fontColor(Color.White)
                .borderRadius(22)
                .onClick(() => { this.createProject() })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.formScale, y: this.formScale })
          .opacity(this.formOpacity)
        }

        // 项目列表
        if (this.projects.length === 0) {
          Column() {
            Text('📋')
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
          ForEach(this.projects, (project: FocusProject, index: number) => {
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
            .scale({
              x: index !== undefined && index < this.listScales.length ? this.listScales[index] : 1,
              y: index !== undefined && index < this.listScales.length ? this.listScales[index] : 1
            })
            .opacity(index !== undefined && index < this.listOpacities.length ? this.listOpacities[index] : 1)
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
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
