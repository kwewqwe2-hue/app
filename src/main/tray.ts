import { app, Tray, Menu, BrowserWindow, nativeImage, NativeImage } from 'electron';
import * as path from 'path';
import './types';

let tray: Tray | null = null;
let mainWindow: BrowserWindow | null = null;

// 创建系统托盘图标（简单的圆形图标）
function createTrayIcon(color: string = '#5E9BFF'): NativeImage {
  const size = 16;
  const canvas = `
    <svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
      <circle cx="${size/2}" cy="${size/2}" r="${size/2 - 1}" fill="${color}" stroke="#333" stroke-width="1"/>
    </svg>
  `;
  return nativeImage.createFromDataURL(`data:image/svg+xml;base64,${Buffer.from(canvas).toString('base64')}`);
}

// 创建系统托盘
export function createTray(window: BrowserWindow | null) {
  mainWindow = window;
  
  // 创建托盘图标
  const icon = createTrayIcon();
  tray = new Tray(icon);
  
  // 设置托盘提示文本
  tray.setToolTip('FocusZone - 空闲中');
  
  // 创建托盘右键菜单
  updateTrayMenu('idle', 0);
  
  // 单击托盘图标显示主窗口
  tray.on('click', () => {
    if (mainWindow) {
      if (mainWindow.isVisible()) {
        mainWindow.hide();
      } else {
        mainWindow.show();
        mainWindow.focus();
      }
    }
  });
}

// 更新托盘菜单
function updateTrayMenu(status: 'idle' | 'focusing', todayMinutes: number) {
  if (!tray) return;
  
  const hours = Math.floor(todayMinutes / 60);
  const minutes = todayMinutes % 60;
  const timeStr = hours > 0 ? `${hours}小时${minutes}分钟` : `${minutes}分钟`;
  
  const contextMenu = Menu.buildFromTemplate([
    { 
      label: `今日专注: ${timeStr}`, 
      enabled: false 
    },
    { 
      label: status === 'focusing' ? '专注中...' : '空闲中', 
      enabled: false 
    },
    { type: 'separator' },
    { 
      label: '打开主界面', 
      click: () => {
        if (mainWindow) {
          mainWindow.show();
          mainWindow.focus();
        }
      }
    },
    { type: 'separator' },
    { 
      label: '退出', 
      click: () => {
        app.isQuitting = true;
        app.quit();
      }
    },
  ]);
  
  tray.setContextMenu(contextMenu);
}

// 更新托盘状态
export function updateTrayStatus(status: 'idle' | 'focusing', todayMinutes: number) {
  if (!tray) return;
  
  // 更新图标颜色
  const color = status === 'focusing' ? '#FF5E5E' : '#5E9BFF';
  const icon = createTrayIcon(color);
  tray.setImage(icon);
  
  // 更新提示文本
  const statusText = status === 'focusing' ? '专注中' : '空闲中';
  const hours = Math.floor(todayMinutes / 60);
  const minutes = todayMinutes % 60;
  const timeStr = hours > 0 ? `${hours}小时${minutes}分钟` : `${minutes}分钟`;
  tray.setToolTip(`FocusZone - ${statusText}\n今日专注: ${timeStr}`);
  
  // 更新菜单
  updateTrayMenu(status, todayMinutes);
}
