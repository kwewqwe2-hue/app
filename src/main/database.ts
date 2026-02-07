import DatabaseConstructor from 'better-sqlite3';
import * as path from 'path';
import { app } from 'electron';

export type Database = DatabaseConstructor.Database;

// 获取数据库路径（用户文档目录）
function getDatabasePath(): string {
  const userDataPath = app.getPath('userData');
  return path.join(userDataPath, 'focuszone.db');
}

// 初始化数据库
export class Database {
  private db: DatabaseConstructor.Database;

  constructor() {
    const dbPath = getDatabasePath();
    this.db = new DatabaseConstructor(dbPath);
    
    // 创建专注会话表
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        duration INTEGER NOT NULL,
        target_minutes INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
  }

  getDb(): DatabaseConstructor.Database {
    return this.db;
  }

  close() {
    this.db.close();
  }
}

// 保存专注会话
export function saveFocusSession(db: Database, duration: number, targetMinutes: number) {
  const stmt = db.getDb().prepare(`
    INSERT INTO focus_sessions (duration, target_minutes)
    VALUES (?, ?)
  `);
  
  stmt.run(duration, targetMinutes);
}

// 获取今日专注统计
export function getFocusSessionStats(db: Database): { totalMinutes: number; sessionCount: number } {
  const today = new Date().toISOString().split('T')[0];
  
  const result = db.getDb().prepare(`
    SELECT 
      COALESCE(SUM(duration), 0) as total_seconds,
      COUNT(*) as session_count
    FROM focus_sessions
    WHERE DATE(created_at) = DATE(?)
  `).get(today) as { total_seconds: number; session_count: number };
  
  return {
    totalMinutes: Math.floor(result.total_seconds / 60),
    sessionCount: result.session_count,
  };
}

// 获取历史会话列表
export function getFocusSessions(db: Database, limit: number = 100) {
  return db.getDb().prepare(`
    SELECT 
      id,
      duration,
      target_minutes,
      created_at
    FROM focus_sessions
    ORDER BY created_at DESC
    LIMIT ?
  `).all(limit);
}
