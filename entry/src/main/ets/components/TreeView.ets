/**
 * 生命之树组件（精致版）
 * 根据用户积分展示不同成长阶段的树
 * 阶段: 种子(0) -> 嫩芽(1) -> 小树(2) -> 茂盛树(3) -> 开花树(4) -> 参天大树(5)
 * 包含：渐变天空背景、星光粒子、草地、光晕、阴影等视觉效果
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
  @State glowOpacity: number = 0
  @State particle1Y: number = 0
  @State particle2Y: number = 0
  @State particle3Y: number = 0
  @State bgOpacity: number = 0

  aboutToAppear(): void {
    // 背景淡入
    setTimeout(() => {
      animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.bgOpacity = 1
      })
    }, 100)

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

    // 光晕呼吸动画
    setTimeout(() => {
      animateTo({
        duration: 2000,
        curve: Curve.EaseInOut,
        iterations: -1,
        playMode: PlayMode.Alternate
      }, () => {
        this.glowOpacity = 0.6
      })
    }, 1200)

    // 粒子上浮动画
    setTimeout(() => {
      animateTo({
        duration: 3000,
        curve: Curve.EaseInOut,
        iterations: -1,
        playMode: PlayMode.Alternate
      }, () => {
        this.particle1Y = -20
        this.particle2Y = -15
        this.particle3Y = -25
      })
    }, 800)
  }

  build() {
    Stack() {
      // ===== 背景层 =====
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(20)
        .linearGradient({
          angle: 180,
          colors: [
            [this.treeStage >= 4 ? '#1A237E' : '#E8F5E9', 0],
            [this.treeStage >= 4 ? '#283593' : '#C8E6C9', 0.4],
            [this.treeStage >= 4 ? '#1B5E20' : '#A5D6A7', 0.85],
            ['#33691E', 1]
          ]
        })
        .opacity(this.bgOpacity)

      // ===== 星光粒子（高阶段才有） =====
      if (this.treeStage >= 3) {
        // 粒子1
        Circle()
          .width(4).height(4).fill('#FFFFFF')
          .opacity(0.7)
          .offset({ x: -60, y: 30 + this.particle1Y })
          .shadow({ radius: 6, color: '#FFFFFF' })

        Circle()
          .width(3).height(3).fill('#FFFFFF')
          .opacity(0.5)
          .offset({ x: 50, y: 50 + this.particle2Y })
          .shadow({ radius: 4, color: '#FFFFFF' })

        Circle()
          .width(3).height(3).fill('#FFD54F')
          .opacity(0.6)
          .offset({ x: -30, y: 20 + this.particle3Y })
          .shadow({ radius: 5, color: '#FFD54F' })

        Circle()
          .width(2).height(2).fill('#FFFFFF')
          .opacity(0.4)
          .offset({ x: 70, y: 15 + this.particle1Y })

        Circle()
          .width(3).height(3).fill('#FFD54F')
          .opacity(0.5)
          .offset({ x: -70, y: 60 + this.particle2Y })
          .shadow({ radius: 4, color: '#FFD54F' })
      }

      // ===== 光晕效果 =====
      if (this.treeStage >= 2) {
        Circle()
          .width(this.treeStage >= 4 ? 180 : 120)
          .height(this.treeStage >= 4 ? 180 : 120)
          .fill(this.treeStage >= 4 ? '#FFD54F' : '#81C784')
          .opacity(this.glowOpacity * 0.15)
          .offset({ y: -20 })
          .shadow({ radius: 40, color: this.treeStage >= 4 ? '#FFD54F' : '#81C784' })
      }

      // ===== 树本体 =====
      Column() {
        Stack() {
          if (this.treeStage === 0) {
            this.buildSeed()
          } else if (this.treeStage === 1) {
            this.buildSprout()
          } else if (this.treeStage === 2) {
            this.buildSmallTree()
          } else if (this.treeStage === 3) {
            this.buildLushTree()
          } else if (this.treeStage === 4) {
            this.buildFloweringTree()
          } else {
            this.buildGrandTree()
          }
        }
        .width('100%')
        .height(220)
        .alignContent(Alignment.Bottom)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 36 })

      // ===== 草地层 =====
      Column() {
        Row() {
          // 左侧草丛
          Circle().width(8).height(14).fill('#43A047').offset({ y: 2 })
            .opacity(this.rootOpacity)
          Circle().width(6).height(18).fill('#388E3C').offset({ x: 4, y: -2 })
            .opacity(this.rootOpacity)
          Circle().width(7).height(12).fill('#66BB6A').offset({ x: 8, y: 3 })
            .opacity(this.rootOpacity)

          Blank()

          // 右侧草丛
          Circle().width(7).height(13).fill('#43A047').offset({ y: 2 })
            .opacity(this.rootOpacity)
          Circle().width(6).height(16).fill('#388E3C').offset({ x: 4, y: -1 })
            .opacity(this.rootOpacity)
          Circle().width(8).height(11).fill('#66BB6A').offset({ x: 8, y: 3 })
            .opacity(this.rootOpacity)
        }
        .width('70%')
        .padding({ left: 10, right: 10 })

        // 地面
        Row()
          .width('85%')
          .height(6)
          .borderRadius(3)
          .linearGradient({
            angle: 0,
            colors: [['#5D4037', 0], ['#795548', 0.5], ['#5D4037', 1]]
          })
          .opacity(this.rootOpacity)
          .shadow({ radius: 4, color: '#3E2723', offsetY: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .position({ bottom: 16 })
    }
    .width('100%')
    .height(300)
    .borderRadius(20)
    .clip(true)
  }

  @Builder
  buildSeed() {
    Column() {
      // 希望之光 — 柔和的金色光点
      Circle()
        .width(8).height(8)
        .fill('#FFD54F')
        .opacity(this.glowOpacity * 0.8)
        .offset({ y: -8 })

      // 种子主体 — 椭圆形，更像真实种子
      Stack({ alignContent: Alignment.Center }) {
        // 种子外壳
        Circle()
          .width(44).height(38)
          .fill('#6D4C41')
          .scale({ x: this.trunkScale, y: this.trunkScale })

        // 种子内层（深色纹理）
        Circle()
          .width(36).height(30)
          .fill('#5D4037')
          .scale({ x: this.trunkScale, y: this.trunkScale })

        // 种子高光（自然光泽）
        Circle()
          .width(16).height(10)
          .fill('#8D6E63')
          .offset({ x: -6, y: -8 })
          .scale({ x: this.trunkScale, y: this.trunkScale })
          .opacity(0.7)

        // 种子裂缝 — 暗示生命
        Row()
          .width(1.5)
          .height(16)
          .backgroundColor('#4E342E')
          .opacity(0.6)
          .scale({ y: this.trunkScale })
          .borderRadius(1)

        // 裂缝中的绿色微光
        Circle()
          .width(4).height(4)
          .fill('#81C784')
          .offset({ y: -10 })
          .opacity(this.glowOpacity * 0.7)
          .scale({ x: this.trunkScale, y: this.trunkScale })
      }
      .margin({ bottom: 4 })

      // 土壤丘 — 柔和的弧形
      Stack({ alignContent: Alignment.Top }) {
        // 土壤主体
        Circle()
          .width(100).height(24)
          .fill('#795548')
          .opacity(this.rootOpacity * 0.8)

        // 土壤高光
        Circle()
          .width(70).height(14)
          .fill('#8D6E63')
          .opacity(this.rootOpacity * 0.5)
          .offset({ y: 2 })

        // 小土粒装饰
        Circle().width(5).height(5).fill('#6D4C41')
          .offset({ x: -35, y: 6 }).opacity(this.rootOpacity * 0.6)
        Circle().width(4).height(4).fill('#5D4037')
          .offset({ x: 30, y: 8 }).opacity(this.rootOpacity * 0.5)
        Circle().width(3).height(3).fill('#6D4C41')
          .offset({ x: -20, y: 10 }).opacity(this.rootOpacity * 0.4)
      }
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }

  @Builder
  buildSprout() {
    Column() {
      // 叶子
      Row() {
        Circle()
          .width(22).height(32).fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .rotate({ angle: -30 })
          .margin({ right: -5 })
          .shadow({ radius: 4, color: '#388E3C', offsetY: 2 })
        Circle()
          .width(22).height(32).fill('#43A047')
          .scale({ x: this.leafScale, y: this.leafScale })
          .rotate({ angle: 30 })
          .margin({ left: -5 })
          .shadow({ radius: 4, color: '#2E7D32', offsetY: 2 })
      }
      .margin({ bottom: -8 })

      // 茎
      Row()
        .width(5)
        .height(40)
        .borderRadius(2.5)
        .linearGradient({
          angle: 180,
          colors: [['#66BB6A', 0], ['#43A047', 1]]
        })
        .scale({ y: this.trunkScale })
        .shadow({ radius: 2, color: '#2E7D32', offsetY: 2 })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }

  @Builder
  buildSmallTree() {
    Column() {
      // 树冠
      Stack() {
        Circle()
          .width(70).height(70).fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .shadow({ radius: 12, color: '#2E7D32', offsetY: 4 })

        Circle()
          .width(45).height(45).fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -10 })

        // 高光
        Circle()
          .width(20).height(14).fill('#A5D6A7')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ x: -8, y: -18 })
          .opacity(0.7)
      }
      .margin({ bottom: -14 })

      // 树干
      Row()
        .width(14).height(70).borderRadius(7)
        .linearGradient({
          angle: 0,
          colors: [['#5D4037', 0], ['#795548', 0.5], ['#5D4037', 1]]
        })
        .scale({ y: this.trunkScale })
        .shadow({ radius: 4, color: '#3E2723', offsetY: 3 })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }

  @Builder
  buildLushTree() {
    Column() {
      Stack() {
        // 三层树冠 + 立体感
        Circle()
          .width(120).height(120).fill('#43A047')
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.8)
          .shadow({ radius: 16, color: '#1B5E20', offsetY: 6 })

        Circle()
          .width(90).height(90).fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -14 })

        Circle()
          .width(55).height(55).fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -30 })

        // 高光
        Circle()
          .width(30).height(18).fill('#A5D6A7')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ x: -15, y: -35 })
          .opacity(0.6)
      }
      .margin({ bottom: -22 })

      // 树干
      Row()
        .width(20).height(110).borderRadius(10)
        .linearGradient({
          angle: 0,
          colors: [['#4E342E', 0], ['#795548', 0.4], ['#5D4037', 0.7], ['#4E342E', 1]]
        })
        .scale({ y: this.trunkScale })
        .shadow({ radius: 6, color: '#3E2723', offsetY: 4 })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }

  @Builder
  buildFloweringTree() {
    Column() {
      Stack() {
        // 大树冠
        Circle()
          .width(140).height(140).fill('#43A047')
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.8)
          .shadow({ radius: 20, color: '#1B5E20', offsetY: 6 })

        Circle()
          .width(105).height(105).fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -14 })

        Circle()
          .width(68).height(68).fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -32 })

        Circle()
          .width(35).height(22).fill('#A5D6A7')
          .offset({ x: -12, y: -40 })
          .opacity(0.5)
          .scale({ x: this.leafScale, y: this.leafScale })

        // 花朵（带光晕）
        Circle().width(16).height(16).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -38, y: -18 })
          .shadow({ radius: 6, color: '#F06292' })
        Circle().width(14).height(14).fill('#EC407A')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 35, y: -12 })
          .shadow({ radius: 5, color: '#EC407A' })
        Circle().width(12).height(12).fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -18, y: -48 })
          .shadow({ radius: 4, color: '#F48FB1' })
        Circle().width(14).height(14).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 24, y: -42 })
          .shadow({ radius: 5, color: '#F06292' })
        Circle().width(11).height(11).fill('#EC407A')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -45, y: 8 })
          .shadow({ radius: 4, color: '#EC407A' })
        Circle().width(13).height(13).fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 45, y: 12 })
          .shadow({ radius: 5, color: '#F48FB1' })

        // 花芯（小黄点）
        Circle().width(5).height(5).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -38, y: -18 })
        Circle().width(4).height(4).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 35, y: -12 })
        Circle().width(4).height(4).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -18, y: -48 })
      }
      .margin({ bottom: -24 })

      // 树干
      Row()
        .width(24).height(130).borderRadius(12)
        .linearGradient({
          angle: 0,
          colors: [['#3E2723', 0], ['#5D4037', 0.3], ['#795548', 0.5], ['#5D4037', 0.7], ['#3E2723', 1]]
        })
        .scale({ y: this.trunkScale })
        .shadow({ radius: 8, color: '#3E2723', offsetY: 4 })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }

  @Builder
  buildGrandTree() {
    Column() {
      Stack() {
        // 巨大树冠（四层渐变）
        Circle()
          .width(180).height(180).fill('#2E7D32')
          .scale({ x: this.leafScale, y: this.leafScale })
          .opacity(0.7)
          .shadow({ radius: 24, color: '#1B5E20', offsetY: 8 })

        Circle()
          .width(140).height(140).fill('#43A047')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -14 })

        Circle()
          .width(100).height(100).fill('#66BB6A')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -32 })

        Circle()
          .width(60).height(60).fill('#81C784')
          .scale({ x: this.leafScale, y: this.leafScale })
          .offset({ y: -50 })

        // 高光
        Circle()
          .width(35).height(22).fill('#A5D6A7')
          .offset({ x: -18, y: -55 })
          .opacity(0.5)
          .scale({ x: this.leafScale, y: this.leafScale })

        // 花朵（带光晕）
        Circle().width(16).height(16).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -55, y: -18 }).shadow({ radius: 6, color: '#F06292' })
        Circle().width(14).height(14).fill('#EC407A')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 50, y: -12 }).shadow({ radius: 5, color: '#EC407A' })
        Circle().width(12).height(12).fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -25, y: -58 }).shadow({ radius: 4, color: '#F48FB1' })
        Circle().width(15).height(15).fill('#F06292')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 35, y: -52 }).shadow({ radius: 6, color: '#F06292' })
        Circle().width(11).height(11).fill('#EC407A')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -60, y: 12 }).shadow({ radius: 4, color: '#EC407A' })
        Circle().width(13).height(13).fill('#F48FB1')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 60, y: 16 }).shadow({ radius: 5, color: '#F48FB1' })

        // 花芯
        Circle().width(5).height(5).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: -55, y: -18 })
        Circle().width(4).height(4).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 50, y: -12 })
        Circle().width(5).height(5).fill('#FFD54F')
          .scale({ x: this.flowerScale, y: this.flowerScale }).offset({ x: 35, y: -52 })

        // 金色果实（带光晕）
        Circle().width(18).height(18).fill('#FF9800')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -35, y: 18 }).shadow({ radius: 8, color: '#FF9800' })
        Circle().width(16).height(16).fill('#FFA726')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 40, y: 22 }).shadow({ radius: 6, color: '#FFA726' })
        Circle().width(17).height(17).fill('#FF9800')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 5, y: -68 }).shadow({ radius: 7, color: '#FF9800' })
        Circle().width(14).height(14).fill('#FFB74D')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: -50, y: -38 }).shadow({ radius: 5, color: '#FFB74D' })
        Circle().width(15).height(15).fill('#FF9800')
          .scale({ x: this.flowerScale, y: this.flowerScale })
          .offset({ x: 55, y: -35 }).shadow({ radius: 6, color: '#FF9800' })

        // 果实高光点
        Circle().width(5).height(5).fill('#FFFFFF')
          .offset({ x: -38, y: 14 }).opacity(0.6)
          .scale({ x: this.flowerScale, y: this.flowerScale })
        Circle().width(4).height(4).fill('#FFFFFF')
          .offset({ x: 37, y: 18 }).opacity(0.6)
          .scale({ x: this.flowerScale, y: this.flowerScale })
      }
      .margin({ bottom: -30 })

      // 粗壮树干（渐变纹理）
      Row()
        .width(30).height(170).borderRadius(15)
        .linearGradient({
          angle: 0,
          colors: [['#3E2723', 0], ['#4E342E', 0.2], ['#6D4C41', 0.4],
            ['#795548', 0.5], ['#6D4C41', 0.6], ['#4E342E', 0.8], ['#3E2723', 1]]
        })
        .scale({ y: this.trunkScale })
        .shadow({ radius: 10, color: '#3E2723', offsetY: 5 })
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }
}
