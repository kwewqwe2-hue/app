/**
 * 数据持久化工具类
 * 使用 @ohos.data.preferences 进行本地数据存储
 */
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import { FocusSession, FocusProject, FocusNote, UserGrowth, DayRecord } from '../model/DataModels'

const STORE_NAME = 'focuszone_store'

// 存储键名
const KEY_SESSIONS = 'focus_sessions'
const KEY_PROJECTS = 'focus_projects'
const KEY_NOTES = 'focus_notes'
const KEY_GROWTH = 'user_growth'
const KEY_DAY_RECORDS = 'day_records'

export class PreferencesUtil {
  private static preferences: dataPreferences.Preferences | null = null

  // 初始化 Preferences
  static async init(context: common.UIAbilityContext): Promise<void> {
    if (!PreferencesUtil.preferences) {
      PreferencesUtil.preferences = await dataPreferences.getPreferences(context, STORE_NAME)
    }
  }

  // 通用写入方法
  private static async putString(key: string, value: string): Promise<void> {
    if (PreferencesUtil.preferences) {
      await PreferencesUtil.preferences.put(key, value)
      await PreferencesUtil.preferences.flush()
    }
  }

  // 通用读取方法
  private static async getString(key: string, defaultValue: string = '[]'): Promise<string> {
    if (PreferencesUtil.preferences) {
      let value = await PreferencesUtil.preferences.get(key, defaultValue)
      return value as string
    }
    return defaultValue
  }

  // =============== 专注会话操作 ===============

  // 保存专注会话
  static async saveFocusSession(session: FocusSession): Promise<void> {
    let sessions = await PreferencesUtil.getFocusSessions()
    sessions.push(session)
    await PreferencesUtil.putString(KEY_SESSIONS, JSON.stringify(sessions))
    // 同步更新日记录
    await PreferencesUtil.updateDayRecord(session)
  }

  // 获取所有专注会话
  static async getFocusSessions(): Promise<FocusSession[]> {
    let json = await PreferencesUtil.getString(KEY_SESSIONS, '[]')
    try {
      return JSON.parse(json) as FocusSession[]
    } catch (e) {
      return []
    }
  }

  // 获取指定日期的专注会话
  static async getSessionsByDate(date: string): Promise<FocusSession[]> {
    let sessions = await PreferencesUtil.getFocusSessions()
    return sessions.filter((s: FocusSession) => s.date === date)
  }

  // 获取指定项目的专注会话
  static async getSessionsByProject(projectId: string): Promise<FocusSession[]> {
    let sessions = await PreferencesUtil.getFocusSessions()
    return sessions.filter((s: FocusSession) => s.projectId === projectId)
  }

  // 获取今日累计专注时间（分钟）
  static async getTodayFocusMinutes(): Promise<number> {
    let today = PreferencesUtil.getDateStr(new Date())
    let sessions = await PreferencesUtil.getSessionsByDate(today)
    let total = 0
    sessions.forEach((s: FocusSession) => {
      total += s.duration
    })
    return total
  }

  // =============== 项目操作 ===============

  // 保存项目
  static async saveProject(project: FocusProject): Promise<void> {
    let projects = await PreferencesUtil.getProjects()
    let index = projects.findIndex((p: FocusProject) => p.id === project.id)
    if (index >= 0) {
      projects[index] = project
    } else {
      projects.push(project)
    }
    await PreferencesUtil.putString(KEY_PROJECTS, JSON.stringify(projects))
  }

  // 获取所有项目
  static async getProjects(): Promise<FocusProject[]> {
    let json = await PreferencesUtil.getString(KEY_PROJECTS, '[]')
    try {
      return JSON.parse(json) as FocusProject[]
    } catch (e) {
      return []
    }
  }

  // 删除项目
  static async deleteProject(projectId: string): Promise<void> {
    let projects = await PreferencesUtil.getProjects()
    projects = projects.filter((p: FocusProject) => p.id !== projectId)
    await PreferencesUtil.putString(KEY_PROJECTS, JSON.stringify(projects))
  }

  // =============== 笔记操作 ===============

  // 保存笔记
  static async saveNote(note: FocusNote): Promise<void> {
    let notes = await PreferencesUtil.getNotes()
    let index = notes.findIndex((n: FocusNote) => n.id === note.id)
    if (index >= 0) {
      notes[index] = note
    } else {
      notes.push(note)
    }
    await PreferencesUtil.putString(KEY_NOTES, JSON.stringify(notes))
  }

  // 获取所有笔记
  static async getNotes(): Promise<FocusNote[]> {
    let json = await PreferencesUtil.getString(KEY_NOTES, '[]')
    try {
      return JSON.parse(json) as FocusNote[]
    } catch (e) {
      return []
    }
  }

  // 按类型获取笔记
  static async getNotesByType(type: string): Promise<FocusNote[]> {
    let notes = await PreferencesUtil.getNotes()
    return notes.filter((n: FocusNote) => n.type === type)
  }

  // 删除笔记
  static async deleteNote(noteId: string): Promise<void> {
    let notes = await PreferencesUtil.getNotes()
    notes = notes.filter((n: FocusNote) => n.id !== noteId)
    await PreferencesUtil.putString(KEY_NOTES, JSON.stringify(notes))
  }

  // =============== 用户成长操作 ===============

  // 获取用户成长数据
  static async getUserGrowth(): Promise<UserGrowth> {
    let json = await PreferencesUtil.getString(KEY_GROWTH, '')
    if (json === '') {
      let defaultGrowth: UserGrowth = {
        totalPoints: 0,
        treeStage: 0,
        totalFocusMinutes: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: ''
      }
      return defaultGrowth
    }
    try {
      return JSON.parse(json) as UserGrowth
    } catch (e) {
      let defaultGrowth: UserGrowth = {
        totalPoints: 0,
        treeStage: 0,
        totalFocusMinutes: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: ''
      }
      return defaultGrowth
    }
  }

  // 更新用户成长数据
  static async updateUserGrowth(growth: UserGrowth): Promise<void> {
    await PreferencesUtil.putString(KEY_GROWTH, JSON.stringify(growth))
  }

  // 增加积分和更新成长
  static async addPointsAndUpdate(points: number, minutes: number): Promise<UserGrowth> {
    let growth = await PreferencesUtil.getUserGrowth()
    growth.totalPoints += points
    growth.totalFocusMinutes += minutes

    // 更新树的阶段
    let newStage = 0
    if (growth.totalPoints >= 15000) {
      newStage = 5
    } else if (growth.totalPoints >= 5000) {
      newStage = 4
    } else if (growth.totalPoints >= 2000) {
      newStage = 3
    } else if (growth.totalPoints >= 500) {
      newStage = 2
    } else if (growth.totalPoints >= 100) {
      newStage = 1
    }
    growth.treeStage = newStage

    // 更新连续打卡
    let today = PreferencesUtil.getDateStr(new Date())
    if (growth.lastActiveDate !== today) {
      let yesterday = PreferencesUtil.getDateStr(new Date(Date.now() - 86400000))
      if (growth.lastActiveDate === yesterday) {
        growth.currentStreak += 1
      } else if (growth.lastActiveDate === '') {
        growth.currentStreak = 1
      } else {
        growth.currentStreak = 1
      }
      if (growth.currentStreak > growth.longestStreak) {
        growth.longestStreak = growth.currentStreak
      }
      growth.lastActiveDate = today
    }

    await PreferencesUtil.updateUserGrowth(growth)
    return growth
  }

  // =============== 日记录操作 ===============

  // 获取所有日记录
  static async getDayRecords(): Promise<DayRecord[]> {
    let json = await PreferencesUtil.getString(KEY_DAY_RECORDS, '[]')
    try {
      return JSON.parse(json) as DayRecord[]
    } catch (e) {
      return []
    }
  }

  // 更新日记录
  static async updateDayRecord(session: FocusSession): Promise<void> {
    let records = await PreferencesUtil.getDayRecords()
    let index = records.findIndex((r: DayRecord) => r.date === session.date)
    if (index >= 0) {
      records[index].totalMinutes += session.duration
      records[index].totalPoints += session.points
      records[index].sessionCount += 1
    } else {
      let newRecord: DayRecord = {
        date: session.date,
        totalMinutes: session.duration,
        totalPoints: session.points,
        sessionCount: 1
      }
      records.push(newRecord)
    }
    await PreferencesUtil.putString(KEY_DAY_RECORDS, JSON.stringify(records))
  }

  // 获取指定日期的日记录
  static async getDayRecord(date: string): Promise<DayRecord | null> {
    let records = await PreferencesUtil.getDayRecords()
    let found = records.find((r: DayRecord) => r.date === date)
    return found ? found : null
  }

  // =============== 工具方法 ===============

  // 生成唯一 ID
  static generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8)
  }

  // 获取日期字符串 YYYY-MM-DD
  static getDateStr(date: Date): string {
    let year = date.getFullYear()
    let month = (date.getMonth() + 1).toString().padStart(2, '0')
    let day = date.getDate().toString().padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 格式化时间显示 (分钟 -> X小时X分钟)
  static formatDuration(minutes: number): string {
    if (minutes < 60) {
      return `${Math.floor(minutes)}分钟`
    }
    let hours = Math.floor(minutes / 60)
    let mins = Math.floor(minutes % 60)
    if (mins === 0) {
      return `${hours}小时`
    }
    return `${hours}小时${mins}分钟`
  }

  // 格式化时间戳为日期时间字符串
  static formatDateTime(timestamp: number): string {
    let date = new Date(timestamp)
    let year = date.getFullYear()
    let month = (date.getMonth() + 1).toString().padStart(2, '0')
    let day = date.getDate().toString().padStart(2, '0')
    let hour = date.getHours().toString().padStart(2, '0')
    let minute = date.getMinutes().toString().padStart(2, '0')
    return `${year}-${month}-${day} ${hour}:${minute}`
  }
}
