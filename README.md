# FocusZone - 专注时间管理桌面应用

一款基于 Electron + React + Tailwind CSS 开发的跨平台桌面应用，采用番茄工作法帮助用户管理专注时间。

## ✨ 功能特性

### 🎯 核心功能
- **番茄计时器**：可自定义专注时长（15/25/45/60分钟或自定义）
- **实时倒计时**：优雅的圆形进度条显示
- **今日统计**：自动记录和统计每日专注时长
- **本地存储**：使用 SQLite 持久化专注记录

### 🖥️ 界面特性
- **自定义标题栏**：左侧 Logo + 应用名，右侧最小化/关闭按钮
- **紧凑设计**：360x640px 竖屏比例，适合放在屏幕一侧
- **系统托盘**：最小化到托盘，随时查看专注状态
- **主题色**：#5E9BFF 蓝色主题，圆角设计风格

### ⚙️ 系统托盘功能
- 显示当前状态（专注中/空闲中）
- 悬停显示今日累计专注时长
- 右键菜单：查看今日时长、打开主界面、退出应用

## 📁 项目结构

```
focuszone/
├── src/
│   ├── main/              # Electron 主进程
│   │   ├── main.ts        # 主进程入口，窗口管理
│   │   ├── tray.ts        # 系统托盘逻辑
│   │   ├── database.ts    # SQLite 数据库封装
│   │   └── preload.ts     # 预加载脚本，IPC 通信
│   └── renderer/          # React 前端
│       ├── components/    # React 组件
│       │   ├── TitleBar.tsx      # 自定义标题栏
│       │   ├── Timer.tsx         # 计时器显示
│       │   └── ControlPanel.tsx  # 控制面板
│       ├── pages/         # 页面组件
│       │   └── TimerPage.tsx     # 主计时器页面
│       ├── App.tsx        # 应用根组件
│       ├── main.tsx       # 前端入口
│       ├── index.css      # 全局样式
│       └── types.ts       # TypeScript 类型定义
├── index.html             # HTML 入口
├── package.json           # 项目配置
├── tsconfig.json          # TypeScript 配置（前端）
├── tsconfig.main.json     # TypeScript 配置（主进程）
├── vite.config.ts         # Vite 构建配置
├── tailwind.config.js     # Tailwind CSS 配置
├── postcss.config.js      # PostCSS 配置
└── electron-builder.yml   # Electron 打包配置
```

## 🚀 快速开始

### 环境要求
- Node.js >= 18.x
- npm >= 9.x

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

这将启动：
1. Vite 开发服务器（前端热重载）
2. Electron 应用（自动连接到开发服务器）

### 构建应用

```bash
# 构建前端和主进程
npm run build

# 打包为可执行文件
npm run package

# 针对特定平台打包
npm run package:win    # Windows
npm run package:mac    # macOS
npm run package:linux  # Linux
```

打包后的文件位于 `release/` 目录。

## 🛠️ 技术栈

- **Electron 28**: 跨平台桌面应用框架
- **React 18**: 前端 UI 框架
- **TypeScript 5**: 类型安全的 JavaScript
- **Tailwind CSS 3**: 实用优先的 CSS 框架
- **Vite 5**: 快速的前端构建工具
- **better-sqlite3**: 高性能 SQLite 数据库

## 📝 使用说明

### 基础使用

1. **启动应用**：双击打开 FocusZone
2. **设置时长**：选择预设时长或自定义分钟数
3. **开始专注**：点击"开始专注"按钮
4. **暂停/结束**：可随时暂停或提前结束
5. **查看统计**：应用会自动记录今日专注时长

### 系统托盘

- **单击托盘图标**：显示/隐藏主窗口
- **右键托盘图标**：打开菜单，查看今日统计或退出应用
- **托盘颜色**：蓝色表示空闲，红色表示专注中

### 数据存储

所有专注记录保存在本地数据库中，位置：
- Windows: `%APPDATA%/focuszone/focuszone.db`
- macOS: `~/Library/Application Support/focuszone/focuszone.db`
- Linux: `~/.config/focuszone/focuszone.db`

## 🎨 自定义

### 修改主题色

编辑 `tailwind.config.js`：

```javascript
theme: {
  extend: {
    colors: {
      primary: '#5E9BFF',        // 修改为你喜欢的颜色
      'primary-dark': '#4A7DD9',
      'primary-light': '#7AADFF',
    },
  },
}
```

### 修改窗口尺寸

编辑 `src/main/main.ts`：

```typescript
mainWindow = new BrowserWindow({
  width: 360,    // 修改宽度
  height: 640,   // 修改高度
  // ...
});
```

## 🔧 开发指南

### 添加新功能

1. **前端功能**：在 `src/renderer/` 目录添加组件或页面
2. **主进程功能**：在 `src/main/` 目录修改主进程逻辑
3. **IPC 通信**：通过 `preload.ts` 暴露安全的 API

### 调试

- **前端调试**：开发模式自动打开 DevTools
- **主进程调试**：查看终端输出的日志
- **数据库调试**：使用 SQLite 工具查看数据库文件

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## ⚠️ 注意事项

1. 首次运行可能需要授予通知权限
2. 关闭窗口会最小化到托盘，不会退出应用
3. 要完全退出，请右键托盘图标选择"退出"
4. 数据库文件会自动创建，无需手动设置

## 📮 联系方式

如有问题或建议，欢迎通过 GitHub Issues 联系我们。