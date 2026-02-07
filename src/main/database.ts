import initSqlJs, { Database } from 'sql.js';
import * as path from 'path';
import * as fs from 'fs';
import { app } from 'electron';

// 获取数据库路径（用户文档目录）
function getDatabasePath(): string {
  const userDataPath = app.getPath('userData');
  return path.join(userDataPath, 'focuszone.db');
}

// 数据库包装类
export class FocusDatabase {
  private db: Database | null = null;
  private dbPath: string;

  constructor() {
    this.dbPath = getDatabasePath();
  }

  async initialize(): Promise<void> {
    const SQL = await initSqlJs({
      // Point to the wasm file in node_modules
      locateFile: (file) => path.join(__dirname, '../../node_modules/sql.js/dist', file)
    });
    
    // 尝试从文件加载现有数据库
    try {
      if (fs.existsSync(this.dbPath)) {
        const buffer = fs.readFileSync(this.dbPath);
        this.db = new SQL.Database(buffer);
      } else {
        this.db = new SQL.Database();
      }
    } catch (error) {
      console.error('Failed to load database, creating new one:', error);
      this.db = new SQL.Database();
    }
    
    // 创建专注会话表
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        duration INTEGER NOT NULL,
        target_minutes INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // 保存数据库到文件
    this.save();
  }

  getDb(): Database {
    if (!this.db) {
      throw new Error('Database not initialized. Call initialize() first.');
    }
    return this.db;
  }

  save(): void {
    if (!this.db) return;
    
    try {
      const data = this.db.export();
      const buffer = Buffer.from(data);
      fs.writeFileSync(this.dbPath, buffer);
    } catch (error) {
      console.error('Failed to save database:', error);
    }
  }

  close() {
    if (this.db) {
      this.save();
      this.db.close();
      this.db = null;
    }
  }
}

// 保存专注会话
export function saveFocusSession(db: FocusDatabase, duration: number, targetMinutes: number) {
  db.getDb().run(`
    INSERT INTO focus_sessions (duration, target_minutes)
    VALUES (?, ?)
  `, [duration, targetMinutes]);
  
  // sql.js 需要手动保存到文件
  db.save();
}

// 获取今日专注统计
export function getFocusSessionStats(db: FocusDatabase): { totalMinutes: number; sessionCount: number } {
  const today = new Date().toISOString().split('T')[0];
  
  const result = db.getDb().exec(`
    SELECT 
      COALESCE(SUM(duration), 0) as total_seconds,
      COUNT(*) as session_count
    FROM focus_sessions
    WHERE DATE(created_at) = DATE(?)
  `, [today]);
  
  if (result.length === 0 || result[0].values.length === 0) {
    return { totalMinutes: 0, sessionCount: 0 };
  }
  
  const row = result[0].values[0];
  return {
    totalMinutes: Math.floor(Number(row[0]) / 60),
    sessionCount: Number(row[1]),
  };
}

// 获取历史会话列表
export function getFocusSessions(db: FocusDatabase, limit: number = 100) {
  const result = db.getDb().exec(`
    SELECT 
      id,
      duration,
      target_minutes,
      created_at
    FROM focus_sessions
    ORDER BY created_at DESC
    LIMIT ?
  `, [limit]);
  
  if (result.length === 0) {
    return [];
  }
  
  const columns = result[0].columns;
  return result[0].values.map((row: any) => {
    const obj: any = {};
    columns.forEach((col: string, index: number) => {
      obj[col] = row[index];
    });
    return obj;
  });
}
