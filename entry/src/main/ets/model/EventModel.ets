export class CalendarEvent {
  id: number;
  title: string;
  startTime: number;
  endTime: number;
  isReminded: boolean;
  reminderId: number = -1; // 存储系统返回的提醒ID

  constructor(title: string, startTime: number, endTime: number) {
    this.id = new Date().getTime();
    this.title = title;
    this.startTime = startTime;
    this.endTime = endTime;
    this.isReminded = false;
  }
}