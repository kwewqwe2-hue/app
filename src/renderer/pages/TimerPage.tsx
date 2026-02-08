import React, { useState, useEffect, useRef } from 'react';
import Timer from '../components/Timer';
import ControlPanel from '../components/ControlPanel';

// 计时器页面
const TimerPage: React.FC = () => {
  const [targetMinutes, setTargetMinutes] = useState<number>(25);
  const [timeLeft, setTimeLeft] = useState<number>(25 * 60);
  const [isRunning, setIsRunning] = useState<boolean>(false);
  const [todayMinutes, setTodayMinutes] = useState<number>(0);
  const [sessionCount, setSessionCount] = useState<number>(0);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const startTimeRef = useRef<number>(0);

  // 加载今日统计
  useEffect(() => {
    loadTodayStats();
  }, []);

  // 定时器逻辑
  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            handleTimerComplete();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      // 更新托盘状态
      window.electronAPI?.updateTrayStatus('focusing', todayMinutes);
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
      
      // 更新托盘状态
      window.electronAPI?.updateTrayStatus('idle', todayMinutes);
    }

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [isRunning, todayMinutes]);

  // 加载今日统计
  const loadTodayStats = async () => {
    try {
      const stats = await window.electronAPI?.getTodayStats();
      if (stats) {
        setTodayMinutes(stats.totalMinutes);
        setSessionCount(stats.sessionCount);
      }
    } catch (error) {
      console.error('Failed to load today stats:', error);
    }
  };

  // 计时完成处理
  const handleTimerComplete = async () => {
    setIsRunning(false);
    
    // 计算实际专注时长
    const elapsedSeconds = targetMinutes * 60;
    
    // 保存专注会话
    try {
      await window.electronAPI?.saveFocusSession(elapsedSeconds, targetMinutes);
      
      // 重新加载统计
      await loadTodayStats();
      
      // 显示完成通知（可选）
      if ('Notification' in window && Notification.permission === 'granted') {
        new Notification('专注完成！', {
          body: `恭喜！你刚刚完成了 ${targetMinutes} 分钟的专注时间。`,
        });
      }
    } catch (error) {
      console.error('Failed to save session:', error);
    }
  };

  // 开始计时
  const handleStart = () => {
    setTimeLeft(targetMinutes * 60);
    setIsRunning(true);
    startTimeRef.current = Date.now();
    
    // 请求通知权限
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  };

  // 暂停计时
  const handlePause = () => {
    setIsRunning(false);
  };

  // 重置/结束计时
  const handleReset = async () => {
    setIsRunning(false);
    
    // 计算已专注时长
    const totalSeconds = targetMinutes * 60 - timeLeft;
    
    // 如果专注时长超过1分钟，则保存记录
    if (totalSeconds >= 60) {
      try {
        await window.electronAPI?.saveFocusSession(totalSeconds, targetMinutes);
        await loadTodayStats();
      } catch (error) {
        console.error('Failed to save session:', error);
      }
    }
    
    setTimeLeft(targetMinutes * 60);
  };

  // 修改目标时长
  const handleTargetChange = (minutes: number) => {
    if (minutes > 0 && minutes <= 120) {
      setTargetMinutes(minutes);
      setTimeLeft(minutes * 60);
    }
  };

  // 格式化今日时长显示
  const formatTodayTime = (): string => {
    const hours = Math.floor(todayMinutes / 60);
    const mins = todayMinutes % 60;
    if (hours > 0) {
      return `${hours}小时${mins}分钟`;
    }
    return `${mins}分钟`;
  };

  return (
    <div className="flex flex-col h-full bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800">
      {/* 计时器显示 */}
      <div className="flex-1 flex flex-col justify-center">
        <Timer timeLeft={timeLeft} isRunning={isRunning} />
        
        {/* 今日统计 */}
        <div className="text-center pb-6">
          <div className="text-sm text-gray-600 dark:text-gray-400">
            今日已专注
          </div>
          <div className="text-2xl font-bold text-primary mt-1">
            {formatTodayTime()}
          </div>
          <div className="text-xs text-gray-500 dark:text-gray-500 mt-1">
            共 {sessionCount} 次专注
          </div>
        </div>
      </div>

      {/* 控制面板 */}
      <ControlPanel
        isRunning={isRunning}
        targetMinutes={targetMinutes}
        onStart={handleStart}
        onPause={handlePause}
        onReset={handleReset}
        onTargetChange={handleTargetChange}
      />
    </div>
  );
};

export default TimerPage;
