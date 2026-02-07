import React from 'react';
import TitleBar from './components/TitleBar';
import TimerPage from './pages/TimerPage';
import './types';

// 主应用组件
const App: React.FC = () => {
  return (
    <div className="h-screen flex flex-col overflow-hidden">
      {/* 自定义标题栏 */}
      <TitleBar />
      
      {/* 主内容区域 */}
      <div className="flex-1 overflow-auto">
        <TimerPage />
      </div>
    </div>
  );
};

export default App;
