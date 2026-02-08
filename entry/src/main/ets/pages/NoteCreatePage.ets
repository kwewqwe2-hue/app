/**
 * 笔记创建页面（二级页面）
 * 不使用自定义组件，所有 UI 在 ArkUI 中直接构建
 * 支持三种类型模板化输入：长期计划、短期备忘、个人收藏
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusNote, NoteType, NoteStatus } from '../model/DataModels'

interface NoteCreateParams {
  type: NoteType
}

@Entry
@Component
struct NoteCreatePage {
  @State noteType: NoteType = 'longterm'
  @State title: string = ''
  @State content: string = ''
  @State targetDateStr: string = ''
  @State status: NoteStatus = 'pending'
  @State url: string = ''

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State formScale: number = 0
  @State formOpacity: number = 0
  @State buttonScale: number = 0
  @State buttonOpacity: number = 0

  private statusOptions: NoteStatus[] = ['pending', 'inprogress', 'completed']
  private statusLabels: string[] = ['待开始', '进行中', '已完成']

  aboutToAppear(): void {
    let params = router.getParams() as NoteCreateParams
    if (params && params.type) {
      this.noteType = params.type
    }
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

  private getTypeTitle(): string {
    if (this.noteType === 'longterm') return '长期计划'
    if (this.noteType === 'shortterm') return '短期备忘'
    return '个人收藏'
  }

  private async saveNote(): Promise<void> {
    if (this.title.trim() === '') return

    let targetDate = 0
    if (this.targetDateStr !== '') {
      targetDate = new Date(this.targetDateStr).getTime()
    }

    let note: FocusNote = {
      id: PreferencesUtil.generateId(),
      type: this.noteType,
      title: this.title.trim(),
      content: this.content.trim(),
      targetDate: targetDate,
      status: this.noteType === 'longterm' ? this.status : 'pending',
      url: this.url.trim(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    }

    await PreferencesUtil.saveNote(note)
    router.back()
  }

  @Builder
  buildLongTermForm() {
    Column() {
      // 标题
      Text('计划标题')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: '输入计划标题' })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.title = value })

      // 目标日期
      Text('目标日期')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: 'YYYY-MM-DD' })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.targetDateStr = value })

      // 详细内容
      Text('详细内容')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextArea({ placeholder: '描述你的长期计划...' })
        .width('100%')
        .height(120)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.content = value })

      // 状态选择
      Text('当前状态')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 8 })

      Row() {
        ForEach(this.statusLabels, (label: string, index: number) => {
          Button(label)
            .height(36)
            .fontSize(13)
            .backgroundColor(index !== undefined && this.status === this.statusOptions[index] ?
              $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
            .fontColor(index !== undefined && this.status === this.statusOptions[index] ?
              $r('app.color.primary_green') : $r('app.color.text_secondary'))
            .borderRadius(18)
            .margin({ right: 10 })
            .onClick(() => {
              if (index !== undefined) {
                this.status = this.statusOptions[index]
              }
            })
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  buildShortTermForm() {
    Column() {
      // 标题
      Text('备忘标题')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: '输入备忘标题' })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.title = value })

      // 内容
      Text('备忘内容')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextArea({ placeholder: '快速记录你的想法、需求、待办...' })
        .width('100%')
        .height(180)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .onChange((value: string) => { this.content = value })
    }
    .width('100%')
  }

  @Builder
  buildFavoriteForm() {
    Column() {
      // 标题
      Text('收藏标题')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: '给收藏起个名字' })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.title = value })

      // URL
      Text('网址链接 (可选)')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: 'https://...' })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.url = value })

      // 描述/文本片段
      Text('描述或文本片段')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextArea({ placeholder: '输入你要收藏的内容...' })
        .width('100%')
        .height(120)
        .fontSize(15)
        .backgroundColor($r('app.color.bg_surface'))
        .borderRadius(12)
        .onChange((value: string) => { this.content = value })
    }
    .width('100%')
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

        Text(`新建${this.getTypeTitle()}`)
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

      // 表单区域
      Scroll() {
        Column() {
          // 类型选择标签
          Row() {
            Text('📋 长期计划')
              .fontSize(13)
              .fontColor(this.noteType === 'longterm' ? $r('app.color.primary_green') : $r('app.color.text_hint'))
              .fontWeight(this.noteType === 'longterm' ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.noteType === 'longterm' ? $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
              .borderRadius(16)
              .onClick(() => { this.noteType = 'longterm' })
              .margin({ right: 8 })

            Text('⚡ 短期备忘')
              .fontSize(13)
              .fontColor(this.noteType === 'shortterm' ? $r('app.color.primary_blue') : $r('app.color.text_hint'))
              .fontWeight(this.noteType === 'shortterm' ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.noteType === 'shortterm' ? $r('app.color.primary_blue_light') : $r('app.color.bg_surface'))
              .borderRadius(16)
              .onClick(() => { this.noteType = 'shortterm' })
              .margin({ right: 8 })

            Text('⭐ 个人收藏')
              .fontSize(13)
              .fontColor(this.noteType === 'favorite' ? $r('app.color.accent_orange') : $r('app.color.text_hint'))
              .fontWeight(this.noteType === 'favorite' ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.noteType === 'favorite' ? $r('app.color.accent_orange_light') : $r('app.color.bg_surface'))
              .borderRadius(16)
              .onClick(() => { this.noteType = 'favorite' })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 根据类型显示不同表单
          Column() {
            if (this.noteType === 'longterm') {
              this.buildLongTermForm()
            } else if (this.noteType === 'shortterm') {
              this.buildShortTermForm()
            } else {
              this.buildFavoriteForm()
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })

          // 保存按钮
          Button('保存')
            .width('80%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_green'))
            .borderRadius(24)
            .margin({ top: 28, bottom: 40 })
            .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 4 })
            .onClick(() => { this.saveNote() })
            .scale({ x: this.buttonScale, y: this.buttonScale })
            .opacity(this.buttonOpacity)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .scale({ x: this.formScale, y: this.formScale })
        .opacity(this.formOpacity)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}
