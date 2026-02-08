// 类型定义文件
declare global {
  interface Window {
    electronAPI: {
      minimizeWindow: () => void;
      closeWindow: () => void;
      maximizeWindow: () => void;
      saveFocusSession: (duration: number, targetMinutes: number) => Promise<{ success: boolean; error?: string }>;
      getTodayStats: () => Promise<{ totalMinutes: number; sessionCount: number }>;
      updateTrayStatus: (status: 'idle' | 'focusing', todayMinutes: number) => void;
      quitApp: () => void;
    };
  }
}

export {};
