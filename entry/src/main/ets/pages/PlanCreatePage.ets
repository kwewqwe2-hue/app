/**
 * 计划创建页面（二级页面）
 * 不使用自定义组件，所有 UI 在 ArkUI 中直接构建
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusProject } from '../model/DataModels'

@Entry
@Component
struct PlanCreatePage {
  @State formName: string = ''
  @State formDesc: string = ''
  @State formTotalHours: string = ''
  @State formDailyHours: string = ''
  @State formTotalDays: string = ''

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State formScale: number = 0
  @State formOpacity: number = 0
  @State buttonScale: number = 0
  @State buttonOpacity: number = 0

  aboutToAppear(): void {
    this.playEntranceAnimation()
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
        this.formScale = 1
        this.formOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: curves.springCurve(0, 1, 280, 26)
      }, () => {
        this.buttonScale = 1
        this.buttonOpacity = 1
      })
    }, 450)
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
    router.back()
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

        Text('新建计划')
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

      // 表单
      Scroll() {
        Column() {
          // 项目名称
          Column() {
            Text('项目名称')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: 6 })

            TextInput({ placeholder: '给你的计划起个名字（如：学习英语）' })
              .width('100%')
              .height(48)
              .fontSize(15)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 项目描述
          Column() {
            Text('项目描述（可选）')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: 6 })

            TextArea({ placeholder: '描述你的计划目标和内容...' })
              .width('100%')
              .height(100)
              .fontSize(15)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .onChange((value: string) => { this.formDesc = value })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 总目标时长
          Column() {
            Text('总目标时长（小时）')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: 6 })

            TextInput({ placeholder: '如：90（代表总共 90 小时）' })
              .width('100%')
              .height(48)
              .fontSize(15)
              .type(InputType.Number)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .onChange((value: string) => { this.formTotalHours = value })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 每日目标
          Column() {
            Text('每日目标时长（小时）')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: 6 })

            TextInput({ placeholder: '如：3（代表每天 3 小时）' })
              .width('100%')
              .height(48)
              .fontSize(15)
              .type(InputType.Number)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .onChange((value: string) => { this.formDailyHours = value })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 目标天数
          Column() {
            Text('目标天数（可选）')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: 6 })

            TextInput({ placeholder: '如：30（代表连续 30 天）' })
              .width('100%')
              .height(48)
              .fontSize(15)
              .type(InputType.Number)
              .backgroundColor($r('app.color.bg_surface'))
              .borderRadius(12)
              .onChange((value: string) => { this.formTotalDays = value })
          }
          .width('100%')
          .margin({ bottom: 32 })

          // 创建按钮
          Button('创建计划')
            .width('100%')
            .height(52)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_green'))
            .borderRadius(26)
            .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 4 })
            .onClick(() => { this.createProject() })
            .scale({ x: this.buttonScale, y: this.buttonScale })
            .opacity(this.buttonOpacity)

          // 取消按钮
          Button('取消')
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.bg_surface'))
            .borderRadius(22)
            .margin({ top: 12, bottom: 40 })
            .onClick(() => { router.back() })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })
        .scale({ x: this.formScale, y: this.formScale })
        .opacity(this.formOpacity)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}
