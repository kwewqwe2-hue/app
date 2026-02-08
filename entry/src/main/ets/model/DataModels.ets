/**
 * FocusZone 数据模型定义
 * 所有数据模型用于本地存储和页面间数据传递
 */

// 专注会话记录
export interface FocusSession {
  id: string
  projectId: string
  projectName: string
  startTime: number
  endTime: number
  duration: number // 分钟
  points: number
  date: string // YYYY-MM-DD 格式
}

// 项目/计划
export interface FocusProject {
  id: string
  name: string
  description: string
  totalGoalHours: number
  dailyGoalHours: number
  totalGoalDays: number
  completedMinutes: number
  completedDays: number
  createdAt: number
  isActive: boolean
}

// 笔记类型
export type NoteType = 'longterm' | 'shortterm' | 'favorite'

// 笔记状态
export type NoteStatus = 'pending' | 'inprogress' | 'completed'

// 笔记
export interface FocusNote {
  id: string
  type: NoteType
  title: string
  content: string
  targetDate: number
  status: NoteStatus
  url: string
  createdAt: number
  updatedAt: number
}

// 用户成长数据
export interface UserGrowth {
  totalPoints: number
  treeStage: number // 0-5: 种子/嫩芽/小树/茂盛树/开花树/参天大树
  totalFocusMinutes: number
  currentStreak: number // 连续打卡天数
  longestStreak: number
  lastActiveDate: string
}

// 日历日数据
export interface DayRecord {
  date: string // YYYY-MM-DD
  totalMinutes: number
  totalPoints: number
  sessionCount: number
}

// 关键词分析结果
export interface KeywordItem {
  word: string
  count: number
}

// 生命之树成长阶段定义
export class TreeStageInfo {
  static readonly STAGES: TreeStageConfig[] = [
    { stage: 0, name: '种子', minPoints: 0, description: '播下希望的种子' },
    { stage: 1, name: '嫩芽', minPoints: 100, description: '破土而出的生机' },
    { stage: 2, name: '小树', minPoints: 500, description: '茁壮成长的力量' },
    { stage: 3, name: '茂盛树', minPoints: 2000, description: '枝繁叶茂的坚持' },
    { stage: 4, name: '开花树', minPoints: 5000, description: '绽放美丽的花朵' },
    { stage: 5, name: '参天大树', minPoints: 15000, description: '顶天立地的伟岸' }
  ]

  static getStage(totalPoints: number): number {
    let stage = 0
    for (let i = TreeStageInfo.STAGES.length - 1; i >= 0; i--) {
      if (totalPoints >= TreeStageInfo.STAGES[i].minPoints) {
        stage = i
        break
      }
    }
    return stage
  }

  static getStageConfig(stage: number): TreeStageConfig {
    if (stage >= 0 && stage < TreeStageInfo.STAGES.length) {
      return TreeStageInfo.STAGES[stage]
    }
    return TreeStageInfo.STAGES[0]
  }

  static getProgress(totalPoints: number): number {
    let currentStage = TreeStageInfo.getStage(totalPoints)
    if (currentStage >= TreeStageInfo.STAGES.length - 1) {
      return 1.0
    }
    let currentMin = TreeStageInfo.STAGES[currentStage].minPoints
    let nextMin = TreeStageInfo.STAGES[currentStage + 1].minPoints
    return (totalPoints - currentMin) / (nextMin - currentMin)
  }
}

export interface TreeStageConfig {
  stage: number
  name: string
  minPoints: number
  description: string
}
