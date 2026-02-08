/**
 * 专注日记页面
 * 记录今天完成了什么，简短复盘
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusNote } from '../model/DataModels'

@Entry
@Component
struct FocusDiaryPage {
  @State diaryContent: string = ''
  @State mood: string = ''
  @State saved: boolean = false
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State bodyScale: number = 0
  @State bodyOpacity: number = 0

  private moods: string[] = ['开心', '平静', '充实', '疲惫', '焦虑', '一般']

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 700, curve: curves.springCurve(0, 1, 328, 34) }, () => {
        this.headerScale = 1; this.headerOpacity = 1
      })
    }, 100)
    setTimeout(() => {
      animateTo({ duration: 800, curve: curves.springCurve(0, 1, 300, 28) }, () => {
        this.bodyScale = 1; this.bodyOpacity = 1
      })
    }, 250)
  }

  private async saveDiary(): Promise<void> {
    if (this.diaryContent.trim() === '') return
    let today = PreferencesUtil.getDateStr(new Date())
    let diary: FocusNote = {
      id: PreferencesUtil.generateId(),
      type: 'longterm',
      title: `专注日记 ${today}`,
      content: `${this.mood !== '' ? '心情: ' + this.mood + '\n\n' : ''}${this.diaryContent}`,
      targetDate: 0,
      status: 'completed',
      url: '',
      createdAt: Date.now(),
      updatedAt: Date.now()
    }
    await PreferencesUtil.saveNote(diary)
    this.saved = true
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { router.back() })
        Text('专注日记').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          if (this.saved) {
            Column() {
              Text('记').fontSize(60).margin({ bottom: 16 })
              Text('日记已保存！').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
              Text('可以在「笔记 > 长期计划」中查看').fontSize(13).fontColor($r('app.color.text_secondary')).margin({ top: 8 })
              Button('返回').width('50%').height(44).fontSize(16)
                .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(22)
                .margin({ top: 24 }).onClick(() => { router.back() })
            }.width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)
          } else {
            // 日期
            Text(`${PreferencesUtil.getDateStr(new Date())}`)
              .fontSize(16).fontColor($r('app.color.primary_blue')).fontWeight(FontWeight.Bold)
              .width('100%').padding({ left: 20 }).margin({ bottom: 12 })

            // 心情选择
            Column() {
              Text('今天的心情').fontSize(16).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 12 })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.moods, (m: string) => {
                  Text(m).fontSize(13)
                    .fontColor(this.mood === m ? $r('app.color.primary_green') : $r('app.color.text_secondary'))
                    .backgroundColor(this.mood === m ? $r('app.color.primary_green_light') : $r('app.color.bg_surface'))
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .borderRadius(16).margin({ right: 8, bottom: 8 })
                    .onClick(() => { this.mood = this.mood === m ? '' : m })
                })
              }
            }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 12 })
              .backgroundColor($r('app.color.bg_card')).borderRadius(20)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

            // 日记内容
            Column() {
              Text('今日复盘').fontSize(16).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 8 })
              TextArea({ placeholder: '今天完成了什么？有什么收获或感悟？\n\n例如：\n- 完成了XX的学习\n- 专注力比昨天好\n- 明天要继续...' })
                .width('100%').height(200).fontSize(14)
                .backgroundColor($r('app.color.bg_surface')).borderRadius(12)
                .onChange((v: string) => { this.diaryContent = v })
            }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 16 })
              .backgroundColor($r('app.color.bg_card')).borderRadius(20)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

            Button('保存日记').width('80%').height(48).fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(24)
              .margin({ bottom: 40 })
              .onClick(() => { this.saveDiary() })
          }
        }.width('100%').padding({ top: 8 })
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
        .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
