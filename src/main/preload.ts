import { contextBridge, ipcRenderer } from 'electron';

// 暴露安全的 API 给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
  // 窗口控制
  minimizeWindow: () => ipcRenderer.send('window-minimize'),
  closeWindow: () => ipcRenderer.send('window-close'),
  maximizeWindow: () => ipcRenderer.send('window-maximize'),
  
  // 数据操作
  saveFocusSession: (duration: number, targetMinutes: number) => 
    ipcRenderer.invoke('save-focus-session', duration, targetMinutes),
  getTodayStats: () => 
    ipcRenderer.invoke('get-today-stats'),
  
  // 托盘状态更新
  updateTrayStatus: (status: 'idle' | 'focusing', todayMinutes: number) => 
    ipcRenderer.send('update-tray-status', status, todayMinutes),
  
  // 应用控制
  quitApp: () => ipcRenderer.send('app-quit'),
});
