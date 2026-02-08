import UIAbility from '@ohos.app.ability.UIAbility'
import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import Want from '@ohos.app.ability.Want'
import window from '@ohos.window'
import hilog from '@ohos.hilog'
import { PreferencesUtil } from '../utils/PreferencesUtil'

const TAG = 'EntryAbility'
const DOMAIN = 0xFF00

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'FocusZone onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'FocusZone onDestroy')
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, TAG, 'FocusZone onWindowStageCreate')

    // 初始化数据存储
    await PreferencesUtil.init(this.context)

    // 将 context 存入 AppStorage，便于全局访问
    AppStorage.setOrCreate('context', this.context)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content. Cause: %{public}s', JSON.stringify(err) ?? '')
        return
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content.')
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'FocusZone onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'FocusZone onForeground')
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'FocusZone onBackground')
  }
}
