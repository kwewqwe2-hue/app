/**
 * 关键词分析页（二级页面）
 * 不使用自定义组件，所有 UI 在 ArkUI 中直接构建
 * 对长期计划和短期备忘进行分词分析，展示关键词热度表
 */
import router from '@ohos.router'
import curves from '@ohos.curves'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { FocusNote } from '../model/DataModels'
import { PointsCalculator, KeywordResult } from '../utils/PointsCalculator'

@Entry
@Component
struct KeywordAnalysisPage {
  @State keywords: KeywordResult[] = []
  @State maxCount: number = 1
  @State totalNotes: number = 0
  @State totalWords: number = 0

  // 动画状态
  @State headerScale: number = 0
  @State headerOpacity: number = 0
  @State summaryScale: number = 0
  @State summaryOpacity: number = 0
  @State chartScale: number = 0
  @State chartOpacity: number = 0
  @State barScales: number[] = []

  aboutToAppear(): void {
    this.analyzeKeywords()
    this.playEntranceAnimation()
  }

  private async analyzeKeywords(): Promise<void> {
    let notes = await PreferencesUtil.getNotes()
    let relevantNotes = notes.filter((n: FocusNote) =>
      n.type === 'longterm' || n.type === 'shortterm'
    )
    this.totalNotes = relevantNotes.length

    let texts: string[] = []
    for (let note of relevantNotes) {
      if (note.title !== '') texts.push(note.title)
      if (note.content !== '') texts.push(note.content)
    }

    this.keywords = PointsCalculator.analyzeKeywords(texts)
    if (this.keywords.length > 0) {
      this.maxCount = this.keywords[0].count
    }

    // 统计总词数
    this.totalWords = 0
    for (let kw of this.keywords) {
      this.totalWords += kw.count
    }

    // 初始化柱状图动画
    this.barScales = []
    for (let i = 0; i < this.keywords.length; i++) {
      this.barScales.push(0)
    }

    // 逐个柱子弹性入场
    for (let i = 0; i < this.keywords.length; i++) {
      let delay = 600 + i * 60
      setTimeout(() => {
        animateTo({
          duration: 800,
          curve: curves.springCurve(0, 1, 260, 24)
        }, () => {
          if (i < this.barScales.length) {
            this.barScales[i] = 1
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

    setTimeout(() => {
      animateTo({
        duration: 700,
        curve: curves.springCurve(0, 1, 300, 30)
      }, () => {
        this.summaryScale = 1
        this.summaryOpacity = 1
      })
    }, 250)

    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: curves.springCurve(0, 1, 280, 28)
      }, () => {
        this.chartScale = 1
        this.chartOpacity = 1
      })
    }, 400)
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

        Text('关键词分析')
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
          // 分析概要
          Column() {
            Text('分析概要')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text(`${this.totalNotes}`)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_blue'))
                Text('分析笔记数')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(`${this.keywords.length}`)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_green'))
                Text('提取关键词')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text(`${this.totalWords}`)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.accent_orange'))
                Text('关键词总频次')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')

            Text('* 分析范围：长期计划 + 短期备忘中的文本内容')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 12 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 12 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.summaryScale, y: this.summaryScale })
          .opacity(this.summaryOpacity)

          // 关键词热度表 - 条形图
          Column() {
            Text('关键词热度表')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            if (this.keywords.length === 0) {
              Column() {
                Text('暂无')
                  .fontSize(48)
                  .margin({ bottom: 12 })
                Text('暂无足够数据进行分析')
                  .fontSize(14)
                  .fontColor($r('app.color.text_hint'))
                Text('添加更多长期计划或短期备忘后再来查看')
                  .fontSize(13)
                  .fontColor($r('app.color.text_hint'))
                  .margin({ top: 8 })
              }
              .width('100%')
              .padding({ top: 24, bottom: 24 })
            } else {
              ForEach(this.keywords, (kw: KeywordResult, index: number) => {
                Column() {
                  Row() {
                    // 排名
                    Text(`${(index !== undefined ? index : 0) + 1}`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_hint'))
                      .width(24)
                      .textAlign(TextAlign.Center)

                    // 关键词
                    Text(kw.word)
                      .fontSize(14)
                      .fontColor($r('app.color.text_primary'))
                      .fontWeight(FontWeight.Medium)
                      .width(80)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    // 条形图
                    Stack({ alignContent: Alignment.Start }) {
                      // 背景条
                      Row()
                        .width('100%')
                        .height(20)
                        .borderRadius(10)
                        .backgroundColor($r('app.color.bg_surface'))

                      // 数据条
                      Row()
                        .width(`${(kw.count / this.maxCount * 100)}%`)
                        .height(20)
                        .borderRadius(10)
                        .backgroundColor(
                          (index !== undefined ? index : 0) < 3 ? $r('app.color.primary_green') :
                            (index !== undefined ? index : 0) < 7 ? $r('app.color.primary_blue') :
                            $r('app.color.accent_orange')
                        )
                        .scale({
                          x: index !== undefined && index < this.barScales.length ? this.barScales[index] : 1
                        })
                    }
                    .layoutWeight(1)
                    .margin({ left: 8, right: 8 })

                    // 频次
                    Text(`${kw.count}`)
                      .fontSize(13)
                      .fontColor($r('app.color.text_secondary'))
                      .fontWeight(FontWeight.Bold)
                      .width(30)
                      .textAlign(TextAlign.End)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .margin({ bottom: 8 })
              })
            }
          }
          .width('100%')
          .padding(20)
          .margin({ left: 16, right: 16, bottom: 40 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(20)
          .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetY: 2 })
          .scale({ x: this.chartScale, y: this.chartScale })
          .opacity(this.chartOpacity)
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
}
