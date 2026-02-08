import React from 'react';

interface TimerProps {
  timeLeft: number; // 剩余秒数
  targetMinutes: number; // 目标分钟数
  isRunning: boolean;
}

// 格式化时间显示
const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
};

// 计时器显示组件
const Timer: React.FC<TimerProps> = ({ timeLeft, targetMinutes, isRunning }) => {
  // 使用实际目标时长计算进度，而非硬编码 25 分钟
  const totalSeconds = targetMinutes * 60;
  const progress = totalSeconds > 0 ? (timeLeft / totalSeconds) * 100 : 0;

  return (
    <div className="flex flex-col items-center justify-center py-12">
      {/* 圆形进度条 */}
      <div className="relative w-56 h-56">
        <svg className="w-full h-full transform -rotate-90">
          {/* 背景圆 */}
          <circle
            cx="112"
            cy="112"
            r="100"
            fill="none"
            stroke="#E5E7EB"
            strokeWidth="8"
          />
          {/* 进度圆 */}
          <circle
            cx="112"
            cy="112"
            r="100"
            fill="none"
            stroke="#5E9BFF"
            strokeWidth="8"
            strokeDasharray={`${2 * Math.PI * 100}`}
            strokeDashoffset={`${2 * Math.PI * 100 * (1 - progress / 100)}`}
            strokeLinecap="round"
            className="transition-all duration-1000"
          />
        </svg>

        {/* 中央时间显示 */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <div className="text-6xl font-bold text-gray-800 dark:text-gray-100 tabular-nums">
            {formatTime(timeLeft)}
          </div>
          <div className="mt-2 text-sm text-gray-500 dark:text-gray-400">
            {isRunning ? '专注中...' : '准备开始'}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Timer;
