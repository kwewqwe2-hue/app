import React from 'react';

interface TitleBarProps {
  title?: string;
}

// 自定义标题栏组件
const TitleBar: React.FC<TitleBarProps> = ({ title = 'FocusZone' }) => {
  const handleMinimize = () => {
    window.electronAPI?.minimizeWindow();
  };

  const handleClose = () => {
    window.electronAPI?.closeWindow();
  };

  return (
    <div className="h-8 bg-gradient-to-r from-primary to-primary-dark flex items-center justify-between px-3 select-none drag-region">
      {/* Logo 和应用名 */}
      <div className="flex items-center space-x-2">
        <div className="w-5 h-5 bg-white rounded-full flex items-center justify-center">
          <span className="text-primary text-xs font-bold">F</span>
        </div>
        <span className="text-white text-sm font-medium">{title}</span>
      </div>

      {/* 窗口控制按钮 */}
      <div className="flex space-x-1 no-drag">
        <button
          onClick={handleMinimize}
          className="w-8 h-6 hover:bg-white/20 rounded flex items-center justify-center transition-colors"
          title="最小化"
        >
          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
          </svg>
        </button>
        <button
          onClick={handleClose}
          className="w-8 h-6 hover:bg-red-500/80 rounded flex items-center justify-center transition-colors"
          title="关闭到托盘"
        >
          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
  );
};

export default TitleBar;
