/**
 * 智能记录本 Tab 组件
 * 功能：三栏式（长期计划/短期备忘/个人收藏），模板化输入，卡片列表展示
 */
import curves from '@ohos.curves'
import router from '@ohos.router'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusNote, NoteType } from '../model/DataModels'

@Component
export struct NotebookTab {
  @State currentTab: number = 0
  @State notes: FocusNote[] = []
  @State filteredNotes: FocusNote[] = []
  @Consume('refreshCounter') @Watch('onRefresh') refreshCounter: number

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State tabScale: number = 0
  @State tabOpacity: number = 0
  @State listScale: number = 0
  @State listOpacity: number = 0

  private tabTypes: NoteType[] = ['longterm', 'shortterm', 'favorite']
  private tabNames: string[] = ['长期计划', '短期备忘', '个人收藏']

  aboutToAppear(): void {
    this.loadNotes()
    this.playEntranceAnimation()
  }

  onRefresh(): void {
    this.loadNotes()
  }

  private async loadNotes(): Promise<void> {
    this.notes = await PreferencesUtil.getNotes()
    this.filterNotes()
  }

  private filterNotes(): void {
    let type = this.tabTypes[this.currentTab]
    this.filteredNotes = this.notes.filter((n: FocusNote) => n.type === type)
    this.filteredNotes.sort((a: FocusNote, b: FocusNote) => b.createdAt - a.createdAt)
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
        duration: 600,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.tabScale = 1
        this.tabOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.listScale = 1
        this.listOpacity = 1
      })
    }, 400)
  }

  private switchTab(index: number): void {
    this.currentTab = index
    this.filterNotes()

    // 切换动画
    this.listScale = 0.9
    this.listOpacity = 0.5
    setTimeout(() => {
      animateTo({
        duration: 500,
        curve: curves.springCurve(0, 1, 320, 32)
      }, () => {
        this.listScale = 1
        this.listOpacity = 1
      })
    }, 50)
  }

  private getStatusText(status: string): string {
    if (status === 'pending') return '待开始'
    if (status === 'inprogress') return '进行中'
    if (status === 'completed') return '已完成'
    return ''
  }

  private getStatusColor(status: string): ResourceColor {
    if (status === 'pending') return $r('app.color.text_hint')
    if (status === 'inprogress') return $r('app.color.primary_blue')
    if (status === 'completed') return $r('app.color.success_green')
    return $r('app.color.text_hint')
  }

  private async deleteNote(noteId: string): Promise<void> {
    await PreferencesUtil.deleteNote(noteId)
    this.loadNotes()
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('智能记录本')
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
            router.pushUrl({
              url: 'pages/NoteCreatePage',
              params: { type: this.tabTypes[this.currentTab] }
            })
          })

        Button('分析')
          .height(36)
          .fontSize(14)
          .backgroundColor($r('app.color.primary_blue_light'))
          .fontColor($r('app.color.primary_blue'))
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/KeywordAnalysisPage' })
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })
      .scale({ x: this.headerScale, y: this.headerScale })
      .opacity(this.headerOpacity)

      // 三栏 Tab
      Row() {
        ForEach(this.tabNames, (name: string, index: number) => {
          Column() {
            Text(name)
              .fontSize(14)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.currentTab === index ?
                $r('app.color.primary_green') : $r('app.color.text_secondary'))

            Row()
              .width(24)
              .height(3)
              .borderRadius(1.5)
              .backgroundColor(this.currentTab === index ?
                $r('app.color.primary_green') : Color.Transparent)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 8 })
          .onClick(() => {
            if (index !== undefined) {
              this.switchTab(index)
            }
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .scale({ x: this.tabScale, y: this.tabScale })
      .opacity(this.tabOpacity)

      // 笔记列表
      Scroll() {
        Column() {
          if (this.filteredNotes.length === 0) {
            Column() {
              Text('暂无')
                .fontSize(48)
                .margin({ bottom: 12 })
              Text(`暂无${this.tabNames[this.currentTab]}`)
                .fontSize(16)
                .fontColor($r('app.color.text_hint'))
              Text('点击"+ 新建"添加')
                .fontSize(13)
                .fontColor($r('app.color.text_hint'))
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 60 })
          } else {
            ForEach(this.filteredNotes, (note: FocusNote) => {
              Column() {
                Row() {
                  Text(note.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 长期计划显示状态
                  if (note.type === 'longterm' && note.status) {
                    Text(this.getStatusText(note.status))
                      .fontSize(11)
                      .fontColor(this.getStatusColor(note.status))
                      .backgroundColor($r('app.color.bg_surface'))
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .borderRadius(8)
                  }
                }
                .width('100%')

                if (note.content !== '') {
                  Text(note.content)
                    .fontSize(13)
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ top: 8 })
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // 个人收藏显示链接
                if (note.type === 'favorite' && note.url !== '') {
                  Row() {
                    Text('链接')
                      .fontSize(12)
                    Text(note.url)
                      .fontSize(12)
                      .fontColor($r('app.color.primary_blue'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ left: 4 })
                  }
                  .margin({ top: 8 })
                }

                // 底部信息
                Row() {
                  Text(PreferencesUtil.formatDateTime(note.createdAt))
                    .fontSize(11)
                    .fontColor($r('app.color.text_hint'))
                  Blank()

                  // 长期计划显示目标日期
                  if (note.type === 'longterm' && note.targetDate > 0) {
                    Text(`目标: ${PreferencesUtil.getDateStr(new Date(note.targetDate))}`)
                      .fontSize(11)
                      .fontColor($r('app.color.accent_orange'))
                  }
                }
                .width('100%')
                .margin({ top: 12 })
              }
              .width('100%')
              .padding(16)
              .margin({ left: 16, right: 16, bottom: 10 })
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(16)
              .shadow({ radius: 6, color: $r('app.color.shadow_color'), offsetY: 2 })
              .gesture(
                LongPressGesture()
                  .onAction(() => {
                    this.deleteNote(note.id)
                  })
              )
            })
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .scale({ x: this.listScale, y: this.listScale })
      .opacity(this.listOpacity)
    }
    .width('100%')
    .height('100%')
  }
}
