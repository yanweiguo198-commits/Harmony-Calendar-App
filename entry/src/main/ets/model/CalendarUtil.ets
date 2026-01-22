export class CalendarUtil {
  // 获取某年某月的天数
  static getDaysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate();
  }

  // 获取某年某月1号是星期几 (0-6, 0代表周日)
  static getFirstWeekDay(year: number, month: number): number {
    return new Date(year, month - 1, 1).getDay();
  }

  // 生成用于Grid展示的数据数组（包含空位填充）
  static getMonthViewDays(year: number, month: number): number[] {
    let days: number[] = [];


    let firstDay = CalendarUtil.getFirstWeekDay(year, month);


    let totalDays = CalendarUtil.getDaysInMonth(year, month);

    // 填充月初的空白
    for (let i = 0; i < firstDay; i++) {
      days.push(0);
    }
    // 填充日期
    for (let i = 1; i <= totalDays; i++) {
      days.push(i);
    }
    return days;
  }

  // 获取指定日期所在周的7天日期对象
  static getWeekDays(currentDate: Date): Date[] {
    let days: Date[] = [];
    let currentDayOfWeek = currentDate.getDay(); // 0-6

    // 计算本周第一天(周日)
    let startOfWeek = new Date(currentDate);
    startOfWeek.setDate(currentDate.getDate() - currentDayOfWeek);

    for (let i = 0; i < 7; i++) {
      let tempDate = new Date(startOfWeek);
      tempDate.setDate(startOfWeek.getDate() + i);
      days.push(tempDate);
    }
    return days;
  }
}