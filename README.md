# FocusZone - 专注力管理与激励工具

一个集番茄时钟、习惯追踪、进度可视化、游戏化激励和轻量笔记于一体的综合性专注力辅助工具。

## 目标平台

- **HarmonyOS 6.0.2(22)** 及以上版本
- 支持设备：手机、平板

## 功能模块

### 1. 专注计时器（主页）
- 预设/手动双模式计时
- 快捷时间选择（15/25/45/60/90分钟）
- 暂停、继续、结束控制
- 今日累计专注时间显示
- 专注完成积分结算

### 2. 计划与目标
- 创建专注项目（名称、描述、目标时长/天数）
- 进度条可视化
- 项目详情页

### 3. 游戏化成长系统
- 积分计算（非线性增长，后期递减）
- 生命之树六阶段成长：种子 → 嫩芽 → 小树 → 茂盛树 → 开花树 → 参天大树
- 连续打卡追踪
- 历史记录

### 4. 专注日历
- 月历展示
- 颜色深浅标记专注时长
- 点击查看日详情

### 5. 智能记录本
- 三栏式：长期计划 / 短期备忘 / 个人收藏
- 模板化输入
- 卡片列表展示

### 6. 关键词分析
- 对长期计划和短期备忘的文本进行分词分析
- 关键词热度条形图展示

## 技术特性

- **深色模式适配**：通过资源目录 `dark/` 定义深色主题颜色，系统自动切换
- **弹性动画**：使用 `curves.springCurve()` 弹簧曲线，每个元素加载后有回弹效果
- **本地数据存储**：使用 `@ohos.data.preferences` 保证数据隐私
- **ArkTS / ArkUI** 开发框架
- **Index页面**使用 Tab + 自定义组件
- **二级页面**不使用自定义组件，全部在 ArkUI 中直接构建

## 项目结构

```
├── AppScope/                   # 应用级配置
│   ├── app.json5
│   └── resources/
├── entry/                      # 主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/   # Ability
│   │   │   ├── pages/          # 页面
│   │   │   │   ├── Index.ets           # 主页 (Tab导航)
│   │   │   │   ├── ProjectDetailPage   # 项目详情
│   │   │   │   ├── DayDetailPage       # 日详情
│   │   │   │   ├── NoteCreatePage      # 笔记创建
│   │   │   │   ├── KeywordAnalysisPage # 关键词分析
│   │   │   │   └── SettingsPage        # 设置
│   │   │   ├── components/     # 自定义组件 (仅Index使用)
│   │   │   │   ├── FocusTimerTab.ets   # 专注计时器
│   │   │   │   ├── PlansTab.ets        # 计划与目标
│   │   │   │   ├── CalendarTab.ets     # 专注日历
│   │   │   │   ├── NotebookTab.ets     # 智能记录本
│   │   │   │   ├── GrowthTab.ets       # 成长系统
│   │   │   │   └── TreeView.ets        # 生命之树
│   │   │   ├── model/          # 数据模型
│   │   │   └── utils/          # 工具类
│   │   ├── resources/          # 资源文件
│   │   └── module.json5
│   └── oh-package.json5
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

## 构建说明

### 环境要求
- HarmonyOS SDK 版本 20+
- hvigorw 6.0.6+
- ohpm 5.3.2+

### 构建命令
```bash
# 安装依赖
ohpm install

# 构建 debug 版本
hvigorw assembleHap -p buildMode=debug

# 构建 release 版本
hvigorw assembleApp -p buildMode=release

# 清理并构建
hvigorw clean && hvigorw assembleHap -p buildMode=debug
```

## 注意事项

1. 需要在 `entry/src/main/resources/base/media/` 目录下添加应用图标资源文件：
   - `app_icon.png` - 应用图标
   - `startIcon.png` - 启动页图标
   - `layered_image.json` - 分层图标配置
2. 所有用户数据本地存储，保证隐私安全
3. 深色模式自动适配，无需手动切换
