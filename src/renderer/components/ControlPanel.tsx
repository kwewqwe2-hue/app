import React from 'react';

interface ControlPanelProps {
  isRunning: boolean;
  isPaused: boolean;
  targetMinutes: number;
  onStart: () => void;
  onPause: () => void;
  onReset: () => void;
  onTargetChange: (minutes: number) => void;
}

// 控制面板组件
const ControlPanel: React.FC<ControlPanelProps> = ({
  isRunning,
  isPaused,
  targetMinutes,
  onStart,
  onPause,
  onReset,
  onTargetChange,
}) => {
  const presetTimes = [15, 25, 45, 60];

  return (
    <div className="px-8 pb-8 space-y-6">
      {/* 预设时间选择 */}
      <div>
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          目标时长
        </label>
        <div className="grid grid-cols-4 gap-2">
          {presetTimes.map((minutes) => (
            <button
              key={minutes}
              onClick={() => !isRunning && !isPaused && onTargetChange(minutes)}
              disabled={isRunning || isPaused}
              className={`
                py-2 px-3 rounded-lg font-medium text-sm transition-all
                ${
                  targetMinutes === minutes
                    ? 'bg-primary text-white shadow-md'
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                }
                ${isRunning || isPaused ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
              `}
            >
              {minutes}分
            </button>
          ))}
        </div>
      </div>

      {/* 自定义时长输入 */}
      <div>
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          自定义时长（分钟）
        </label>
        <input
          type="number"
          min="1"
          max="120"
          value={targetMinutes}
          onChange={(e) => !isRunning && !isPaused && onTargetChange(Number(e.target.value))}
          disabled={isRunning || isPaused}
          className={`
            w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600
            bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100
            focus:outline-none focus:ring-2 focus:ring-primary
            ${isRunning || isPaused ? 'opacity-50 cursor-not-allowed' : ''}
          `}
        />
      </div>

      {/* 控制按钮 */}
      <div className="flex space-x-3">
        {!isRunning && !isPaused ? (
          // 未开始状态：显示"开始专注"
          <button
            onClick={onStart}
            className="flex-1 bg-primary hover:bg-primary-dark text-white font-medium py-3 px-6 rounded-lg transition-colors shadow-lg hover:shadow-xl"
          >
            开始专注
          </button>
        ) : !isRunning && isPaused ? (
          // 已暂停状态：显示"继续"和"结束"
          <>
            <button
              onClick={onStart}
              className="flex-1 bg-green-500 hover:bg-green-600 text-white font-medium py-3 px-6 rounded-lg transition-colors shadow-lg hover:shadow-xl"
            >
              继续
            </button>
            <button
              onClick={onReset}
              className="flex-1 bg-red-500 hover:bg-red-600 text-white font-medium py-3 px-6 rounded-lg transition-colors shadow-lg hover:shadow-xl"
            >
              结束
            </button>
          </>
        ) : (
          // 运行中状态：显示"暂停"和"结束"
          <>
            <button
              onClick={onPause}
              className="flex-1 bg-yellow-500 hover:bg-yellow-600 text-white font-medium py-3 px-6 rounded-lg transition-colors shadow-lg hover:shadow-xl"
            >
              暂停
            </button>
            <button
              onClick={onReset}
              className="flex-1 bg-red-500 hover:bg-red-600 text-white font-medium py-3 px-6 rounded-lg transition-colors shadow-lg hover:shadow-xl"
            >
              结束
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default ControlPanel;
