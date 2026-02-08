/**
 * 积分计算器
 * 根据专注时长计算积分，采用非线性增长，后期递减
 */
export class PointsCalculator {

  /**
   * 计算专注积分
   * 规则：
   * - 前 25 分钟：每分钟 1.2 分（鼓励完成一个番茄钟）
   * - 25-50 分钟：每分钟 1.0 分
   * - 50-90 分钟：每分钟 0.8 分
   * - 90-120 分钟：每分钟 0.6 分
   * - 120 分钟以上：每分钟 0.4 分（递减）
   * @param minutes 专注时长（分钟）
   * @returns 获得的积分
   */
  static calculatePoints(minutes: number): number {
    if (minutes <= 0) {
      return 0
    }

    let points = 0

    // 不足1分钟：保底1分，鼓励每一次尝试
    if (minutes < 1) {
      points = Math.max(1, minutes * 2)
    } else if (minutes <= 25) {
      points = minutes * 1.2
    } else if (minutes <= 50) {
      points = 25 * 1.2 + (minutes - 25) * 1.0
    } else if (minutes <= 90) {
      points = 25 * 1.2 + 25 * 1.0 + (minutes - 50) * 0.8
    } else if (minutes <= 120) {
      points = 25 * 1.2 + 25 * 1.0 + 40 * 0.8 + (minutes - 90) * 0.6
    } else {
      points = 25 * 1.2 + 25 * 1.0 + 40 * 0.8 + 30 * 0.6 + (minutes - 120) * 0.4
    }

    return Math.round(points)
  }

  /**
   * 获取积分等级描述
   * @param points 单次积分
   * @returns 等级描述
   */
  static getPointsRank(points: number): string {
    if (points >= 100) {
      return '超级专注'
    } else if (points >= 60) {
      return '深度专注'
    } else if (points >= 30) {
      return '高效专注'
    } else if (points >= 10) {
      return '良好专注'
    } else {
      return '初步尝试'
    }
  }

  /**
   * 分析关键词频率
   * 对文本内容进行简单分词，统计词频
   * @param texts 文本数组
   * @returns 关键词频率列表，按频率降序
   */
  static analyzeKeywords(texts: string[]): KeywordResult[] {
    let wordMap = new Map<string, number>()

    // 停用词列表
    let stopWords: Set<string> = new Set([
      '的', '了', '在', '是', '我', '有', '和', '就', '不', '人',
      '都', '一', '一个', '上', '也', '很', '到', '说', '要', '去',
      '你', '会', '着', '没有', '看', '好', '自己', '这', '他', '她',
      '它', '们', '那', '些', '么', '什么', '吗', '吧', '呢', '啊',
      '把', '被', '从', '而', '对', '又', '为', '但', '与', '及',
      'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been',
      'and', 'or', 'not', 'no', 'to', 'of', 'in', 'on', 'at', 'for'
    ])

    for (let text of texts) {
      // 简单分词：按标点和空格分割
      let words = text.split(/[\s,，。.!！?？;；:：、\n\r\t()（）【】\[\]{}""''\"\']+/)
      for (let word of words) {
        let trimmed = word.trim()
        if (trimmed.length >= 2 && !stopWords.has(trimmed)) {
          let current = wordMap.get(trimmed) || 0
          wordMap.set(trimmed, current + 1)
        }
      }
    }

    // 转换为数组并排序
    let results: KeywordResult[] = []
    wordMap.forEach((count: number, word: string) => {
      results.push({ word: word, count: count })
    })

    results.sort((a: KeywordResult, b: KeywordResult) => b.count - a.count)

    // 返回前 20 个
    return results.slice(0, 20)
  }
}

export interface KeywordResult {
  word: string
  count: number
}
