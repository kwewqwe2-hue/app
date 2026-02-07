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
    // Get the correct path to sql.js WASM files
    // In development: node_modules is relative to dist/main
    // In production: node_modules is packaged alongside the app
    const wasmPath = app.isPackaged
      ? path.join(process.resourcesPath, 'app.asar.unpacked/node_modules/sql.js/dist')
      : path.join(__dirname, '../../node_modules/sql.js/dist');
    
    const SQL = await initSqlJs({
      locateFile: (file) => path.join(wasmPath, file)
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
      try {
        this.save();
        this.db.close();
      } catch (error) {
        console.error('Failed to close database:', error);
        // Still try to close even if save failed
        try {
          this.db.close();
        } catch (closeError) {
          console.error('Failed to close database connection:', closeError);
        }
      } finally {
        this.db = null;
      }
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
