/**
 * 专注质量评分页面
 * 结束后自评1-5星 + 记录中断原因
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusNote } from '../model/DataModels'

@Entry
@Component
struct FocusRatingPage {
  @State rating: number = 0
  @State interruptReason: string = ''
  @State notes: string = ''
  @State saved: boolean = false
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State bodyScale: number = 0
  @State bodyOpacity: number = 0

  private reasons: string[] = ['手机通知', '有人打扰', '走神了', '太累了', '环境嘈杂', '其他']

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

  private async saveRating(): Promise<void> {
    let ratingNote: FocusNote = {
      id: PreferencesUtil.generateId(),
      type: 'shortterm',
      title: `专注评分: ${'星'.repeat(this.rating)}${'☆'.repeat(5 - this.rating)}`,
      content: `评分: ${this.rating}/5\n${this.interruptReason !== '' ? '中断原因: ' + this.interruptReason + '\n' : ''}${this.notes !== '' ? '备注: ' + this.notes : ''}`,
      targetDate: 0,
      status: 'completed',
      url: '',
      createdAt: Date.now(),
      updatedAt: Date.now()
    }
    await PreferencesUtil.saveNote(ratingNote)
    this.saved = true
  }

  build() {
    Column() {
      Row() {
        Button('←').width(40).height(40).fontSize(20)
          .backgroundColor($r('app.color.bg_surface')).fontColor($r('app.color.text_primary'))
          .borderRadius(20).onClick(() => { router.back() })
        Text('专注质量评分').fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ left: 12 }).layoutWeight(1)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .scale({ x: this.headerScale, y: this.headerScale }).opacity(this.headerOpacity)

      Scroll() {
        Column() {
          if (this.saved) {
            Column() {
              Text('完成').fontSize(60).margin({ bottom: 16 })
              Text('评分已保存！').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_green'))
              Button('返回').width('50%').height(44).fontSize(16)
                .fontColor(Color.White).backgroundColor($r('app.color.primary_green')).borderRadius(22)
                .margin({ top: 24 }).onClick(() => { router.back() })
            }.width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)
          } else {
            // 星星评分
            Column() {
              Text('这次专注质量如何？').fontSize(18).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary')).margin({ bottom: 20 })
              Row() {
                ForEach([1, 2, 3, 4, 5], (star: number) => {
                  Text(star <= this.rating ? '星' : '☆')
                    .fontSize(44).fontColor(star <= this.rating ? '#FFB300' : $r('app.color.text_hint'))
                    .margin({ left: 6, right: 6 })
                    .onClick(() => { this.rating = star })
                })
              }
              Text(this.rating === 0 ? '点击星星评分' :
                ['', '需要改进', '一般', '还不错', '很好', '完美！'][this.rating])
                .fontSize(14).fontColor($r('app.color.text_secondary')).margin({ top: 12 })
            }.width('100%').padding(24).margin({ left: 16, right: 16, bottom: 12 })
              .backgroundColor($r('app.color.bg_card')).borderRadius(20)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
              .alignItems(HorizontalAlign.Center)

            // 中断原因
            Column() {
              Text('是否有中断？选择原因').fontSize(16).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 12 })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.reasons, (reason: string) => {
                  Text(reason).fontSize(13)
                    .fontColor(this.interruptReason === reason ? $r('app.color.primary_blue') : $r('app.color.text_secondary'))
                    .backgroundColor(this.interruptReason === reason ? $r('app.color.primary_blue_light') : $r('app.color.bg_surface'))
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .borderRadius(16).margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.interruptReason = this.interruptReason === reason ? '' : reason
                    })
                })
              }.width('100%')
            }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 12 })
              .backgroundColor($r('app.color.bg_card')).borderRadius(20)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

            // 备注
            Column() {
              Text('补充备注（可选）').fontSize(16).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary')).width('100%').margin({ bottom: 8 })
              TextArea({ placeholder: '记录一下这次专注的感受...' })
                .width('100%').height(80).fontSize(14)
                .backgroundColor($r('app.color.bg_surface')).borderRadius(12)
                .onChange((v: string) => { this.notes = v })
            }.width('100%').padding(20).margin({ left: 16, right: 16, bottom: 16 })
              .backgroundColor($r('app.color.bg_card')).borderRadius(20)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })

            Button('保存评分').width('80%').height(48).fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor(Color.White).backgroundColor(this.rating > 0 ? $r('app.color.primary_green') : $r('app.color.text_hint'))
              .borderRadius(24).margin({ bottom: 40 })
              .onClick(() => { if (this.rating > 0) this.saveRating() })
          }
        }.width('100%').padding({ top: 8 })
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top)
        .scale({ x: this.bodyScale, y: this.bodyScale }).opacity(this.bodyOpacity)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }
}
