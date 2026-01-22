import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';

export class ReminderService {

  // 发布提醒
  static async addReminder(title: string, targetTime: Date): Promise<number> {
    let reminder: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: {
        year: targetTime.getFullYear(),
        month: targetTime.getMonth() + 1,
        day: targetTime.getDate(),
        hour: targetTime.getHours(),
        minute: targetTime.getMinutes(),
        second: 0
      },
      title: '日程提醒',
      content: title,
      expiredContent: '您的日程已过期',
      actionButton: [
        {
          title: '关闭',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        }
      ],
      snoozeTimes: 0,
      ringDuration: 5,
    }

    try {
      const reminderId = await reminderAgentManager.publishReminder(reminder);
      console.info('提醒发布成功, ID: ' + reminderId);
      return reminderId;
    } catch (error) {
      console.error('提醒发布失败: ' + JSON.stringify(error));
      return -1;
    }
  }

  // 【👇👇👇 这里是补回来的代码 👇👇👇】
  // 取消提醒
  static async cancelReminder(reminderId: number) {
    if (reminderId >= 0) {
      try {
        await reminderAgentManager.cancelReminder(reminderId);
        console.info('提醒取消成功 ID:' + reminderId);
      } catch (error) {
        console.error('提醒取消失败: ' + JSON.stringify(error));
      }
    }
  }
}