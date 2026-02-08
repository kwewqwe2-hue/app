/**
 * 生命之树组件
 * 根据用户积分展示不同成长阶段的树
 * 阶段: 种子(0) -> 嫩芽(1) -> 小树(2) -> 茂盛树(3) -> 开花树(4) -> 参天大树(5)
 */
import curves from '@ohos.curves'

@Component
export struct TreeView {
  @Prop treeStage: number = 0
  @Prop totalPoints: number = 0

  @State trunkScale: number = 0
  @State leafScale: number = 0
  @State flowerScale: number = 0
  @State rootOpacity: number = 0
  @State swayAngle: number = 0

  aboutToAppear(): void {
    // 树干弹性入场
    setTimeout(() => {
      animateTo({
        duration: 1000,
        curve: curves.springCurve(0, 1, 200, 28)
      }, () => {
        this.trunkScale = 1
        this.rootOpacity = 1
      })
    }, 300)

    // 树叶弹性入场
    setTimeout(() => {
      animateTo({
        duration: 1200,
        curve: curves.springCurve(0, 1, 180, 22)
      }, () => {
        this.leafScale = 1
      })
    }, 600)

    // 花朵/果实弹性入场
    setTimeout(() => {
      animateTo({
        duration: 1000,
        curve: curves.springCurve(0, 1, 160, 20)
      }, () => {
        this.flowerScale = 1
      })
    }, 900)
  }

  // 获取树干高度
  private getTrunkHeight(): number {
    let heights: number[] = [0, 20, 60, 100, 120, 160]
    return this.treeStage < heights.length ? heights[this.treeStage] : 160
  }

  // 获取树干宽度
  private getTrunkWidth(): number {
    let widths: number[] = [0, 6, 12, 18, 22, 28]
    return this.treeStage < widths.length ? widths[this.treeStage] : 28
  }

  // 获取树冠大小
  private getCanopySize(): number {
    let sizes: number[] = [0, 0, 60, 100, 120, 160]
    return this.treeStage < sizes.length ? sizes[this.treeStage] : 160
  }

  build() {
    Column() {
      // 树冠区域
      Stack() {
        if (this.treeStage === 0) {
          // 种子阶段
          this.buildSeed()
        } else if (this.treeStage === 1) {
          // 嫩芽阶段
          this.buildSprout()
        } else if (this.treeStage === 2) {
          // 小树阶段
          this.buildSmallTree()
        } else if (this.treeStage === 3) {
          // 茂盛树阶段
          this.buildLushTree()
        } else if (this.treeStage === 4) {
          // 开花树阶段
          this.buildFloweringTree()
        } else {
          // 参天大树阶段
          this.buildGrandTree()
        }
      }
      .width('100%')
      .height(260)
      .alignContent(Alignment.Bottom)

      // 地面
      Row()
        .width('80%')
        .height(4)
        .borderRadius(2)
        .backgroundColor($r('app.color.tree_trunk'))
        .opacity(this.rootOpacity * 0.5)
        .margin({ top: -2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildSeed() {
    Column() {
      // 种子
      Stack() {
        Circle()
          .width(36)
          .height(36)
          .fill($r('app.color.tree_trunk'))
          .scale({ x: this.trunkScale, y: this.trunkScale })

        // 种子裂缝线
        Row()
          .width(1)
          .height(20)
          .backgroundColor('#5D4037')
          .opacity(0.6)
          .scale({ y: this.trunkScale })
      }
      .margin({ bottom: 10 })

      // 土壤
      Row()
        .width(80)
        .height(8)
        .borderRadius(4)
        .backgroundColor('#8D6E63')
        .opacity(this.rootOpacity)
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  buildSprout() {
    Column() {
      // 叶子
      Row() {
        // 左叶
        Circle()
          .width(20)
          .height(28)
          .fill($r('app.color.tree_leaf'))
          .scale({ x: this.leafScale, y: this.leafScale })
          .rotate({ angle: -30 })
          .margin({ right: -4 })
        // 右叶
        Circle()
          .width(20)
          .height(28)
          .fill($r('app.color.tree_leaf'))
          .scale({ x: this.leafScale, y: this.leafScale })
          .rotate({ angle: 30 })
          .margin({ left: -4 })
      }
      .margin({ bottom: -6 })

      // 茎
      Row()
        .width(4)
        .height(30)
        .backgroundColor($r('app.color.primary_green'))
        .scale({ y: this.trunkScale })

      // 土壤
      Row()
        .width(80)
        .height(8)
        .borderRadius(4)
        .backgroundColor('#8D6E63')
        .opacity(this.rootOpacity)
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  buildSmallTree() {
    Column() {
      // 树冠
      Circle()
        .width(60)
        .height(60)
        .fill($r('app.color.tree_leaf'))
        .scale({ x: this.leafScale, y: this.leafScale })
        .shadow({ radius: 8, color: '#2000000', offsetY: 4 })
        .margin({ bottom: -12 })

      // 树干
      Row()
        .width(12)
        .height(60)
        .borderRadius(6)
        .backgroundColor($r('app.color.tree_trunk'))
        .scale({ y: this.trunkScale })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  buildLushTree() {
    Column() {
      // 三层树冠
      Stack() {
        Circle()
          .width(110)
          .height(110)
          .fill($r('app.color.tree_leaf'))
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.7)

        Circle()
          .width(80)
          .height(80)
          .fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -15 })

        Circle()
          .width(50)
          .height(50)
          .fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -30 })
      }
      .margin({ bottom: -20 })
      .shadow({ radius: 12, color: '#2000000', offsetY: 6 })

      // 树干
      Row()
        .width(18)
        .height(100)
        .borderRadius(9)
        .backgroundColor($r('app.color.tree_trunk'))
        .scale({ y: this.trunkScale })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  buildFloweringTree() {
    Column() {
      Stack() {
        // 大树冠
        Circle()
          .width(130)
          .height(130)
          .fill($r('app.color.tree_leaf'))
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.7)

        Circle()
          .width(95)
          .height(95)
          .fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -15 })

        Circle()
          .width(60)
          .height(60)
          .fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -32 })

        // 花朵
        Circle()
          .width(14)
          .height(14)
          .fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -35, y: -20 })

        Circle()
          .width(12)
          .height(12)
          .fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 30, y: -15 })

        Circle()
          .width(10)
          .height(10)
          .fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -15, y: -45 })

        Circle()
          .width(12)
          .height(12)
          .fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 20, y: -40 })

        Circle()
          .width(10)
          .height(10)
          .fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -40, y: 5 })

        Circle()
          .width(11)
          .height(11)
          .fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 40, y: 10 })
      }
      .margin({ bottom: -22 })
      .shadow({ radius: 16, color: '#2000000', offsetY: 6 })

      // 树干
      Row()
        .width(22)
        .height(120)
        .borderRadius(11)
        .backgroundColor($r('app.color.tree_trunk'))
        .scale({ y: this.trunkScale })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  buildGrandTree() {
    Column() {
      Stack() {
        // 巨大树冠
        Circle()
          .width(170)
          .height(170)
          .fill($r('app.color.tree_leaf'))
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.6)

        Circle()
          .width(130)
          .height(130)
          .fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -15 })

        Circle()
          .width(90)
          .height(90)
          .fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -35 })

        Circle()
          .width(50)
          .height(50)
          .fill('#A5D6A7')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -55 })

        // 花朵
        Circle().width(14).height(14).fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -50, y: -20 })
        Circle().width(12).height(12).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 45, y: -15 })
        Circle().width(10).height(10).fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -20, y: -55 })
        Circle().width(13).height(13).fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 30, y: -50 })
        Circle().width(11).height(11).fill($r('app.color.tree_flower'))
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -55, y: 10 })
        Circle().width(10).height(10).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 55, y: 15 })

        // 果实
        Circle().width(16).height(16).fill($r('app.color.tree_fruit'))
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -30, y: 15 })
        Circle().width(14).height(14).fill('#FFA726')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 35, y: 20 })
        Circle().width(15).height(15).fill($r('app.color.tree_fruit'))
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 0, y: -65 })
        Circle().width(13).height(13).fill('#FFB74D')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -45, y: -35 })
      }
      .margin({ bottom: -28 })
      .shadow({ radius: 20, color: '#2000000', offsetY: 8 })

      // 粗壮树干
      Row()
        .width(28)
        .height(160)
        .borderRadius(14)
        .backgroundColor($r('app.color.tree_trunk'))
        .scale({ y: this.trunkScale })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
    .padding({ bottom: 10 })
  }
}
