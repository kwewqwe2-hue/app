import { app, BrowserWindow, ipcMain } from 'electron';
import * as path from 'path';
import { createTray, updateTrayStatus } from './tray';
import { Database, getFocusSessionStats, saveFocusSession } from './database';

let mainWindow: BrowserWindow | null = null;
let db: Database | null = null;

// 创建主窗口
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 360,
    height: 640,
    minWidth: 320,
    minHeight: 580,
    frame: false, // 无边框窗口，使用自定义标题栏
    resizable: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  // 开发环境加载 Vite 开发服务器
  if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    // 生产环境加载打包后的文件
    mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  }

  // 窗口关闭时最小化到托盘而不是退出
  mainWindow.on('close', (event) => {
    if (!app.isQuitting) {
      event.preventDefault();
      mainWindow?.hide();
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// 应用程序准备就绪
app.whenReady().then(() => {
  // 初始化数据库
  db = new Database();
  
  // 创建主窗口
  createWindow();
  
  // 创建系统托盘
  createTray(mainWindow);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// 所有窗口关闭时退出应用（Windows & Linux）
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// IPC 事件处理：窗口控制
ipcMain.on('window-minimize', () => {
  mainWindow?.minimize();
});

ipcMain.on('window-close', () => {
  mainWindow?.hide();
});

ipcMain.on('window-maximize', () => {
  if (mainWindow?.isMaximized()) {
    mainWindow.unmaximize();
  } else {
    mainWindow?.maximize();
  }
});

// IPC 事件处理：专注会话保存
ipcMain.handle('save-focus-session', async (event, duration: number, targetMinutes: number) => {
  if (!db) return { success: false, error: 'Database not initialized' };
  
  try {
    saveFocusSession(db, duration, targetMinutes);
    return { success: true };
  } catch (error) {
    console.error('Failed to save focus session:', error);
    return { success: false, error: String(error) };
  }
});

// IPC 事件处理：获取今日统计
ipcMain.handle('get-today-stats', async () => {
  if (!db) return { totalMinutes: 0, sessionCount: 0 };
  
  try {
    return getFocusSessionStats(db);
  } catch (error) {
    console.error('Failed to get stats:', error);
    return { totalMinutes: 0, sessionCount: 0 };
  }
});

// IPC 事件处理：更新托盘状态
ipcMain.on('update-tray-status', (event, status: 'idle' | 'focusing', todayMinutes: number) => {
  updateTrayStatus(status, todayMinutes);
});

// 退出应用
ipcMain.on('app-quit', () => {
  app.isQuitting = true;
  app.quit();
});
