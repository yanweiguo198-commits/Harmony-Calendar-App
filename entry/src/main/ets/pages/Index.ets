import { CalendarUtil } from '../model/CalendarUtil';
import { CalendarEvent } from '../model/EventModel';
import { AddEventDialog } from '../components/AddEventDialog';
import { ReminderService } from '../service/ReminderService';

@Entry
@Component
struct Index {
  @State currentDate: Date = new Date();
  @State currentIndex: number = 0;
  @State eventList: CalendarEvent[] = [];

  // 临时存储当前正在编辑的事件
  @State editingEvent: CalendarEvent | undefined = undefined;

  // --- 1. 弹窗控制器 ---
  // 注意：我们需要通过 open() 方法里的 params 或者重新初始化来传递数据，
  // 但 ArkUI 的 CustomDialog 传参比较特殊。
  // 最简单的做法是：每次打开前，我们根据 editingEvent 的状态来决定弹窗的行为。

  dialogController: CustomDialogController | null = null;

  // 打开弹窗的方法
  openDialog(event?: CalendarEvent) {
    this.editingEvent = event; // 如果 event 有值就是编辑，没值就是新建

    this.dialogController = new CustomDialogController({
      builder: AddEventDialog({
        selectedDate: this.currentDate,
        editEvent: this.editingEvent, // 把要编辑的事件传进去
        onSave: (savedEvent: CalendarEvent) => {
          this.handleSaveEvent(savedEvent);
        }
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true,
      autoCancel: true
    });

    this.dialogController.open();
  }

  // --- 2. 保存/更新逻辑 ---
  async handleSaveEvent(event: CalendarEvent) {
    // 提醒逻辑
    if (event.isReminded && event.startTime > new Date().getTime()) {
      // 简单处理：先取消旧提醒（如果有），再加新提醒
      if (event.reminderId !== -1) {
        await ReminderService.cancelReminder(event.reminderId);
      }
      let targetDate = new Date(event.startTime);
      event.reminderId = await ReminderService.addReminder(event.title, targetDate);
    }

    // 查找是否存在同 ID 的事件
    const index = this.eventList.findIndex(e => e.id === event.id);

    if (index !== -1) {
      // 存在 -> 更新 (编辑模式)
      this.eventList[index] = event;
      // 强制刷新：ArkTS 数组元素替换有时需要触发通知
      this.eventList = [...this.eventList];
      console.info(`更新日程: ${event.title}`);
    } else {
      // 不存在 -> 新增
      this.eventList.push(event);
      console.info(`新增日程: ${event.title}`);
    }
  }

  build() {
    Stack() {
      Column() {
        Text(`${this.currentDate.getFullYear()}年 ${this.currentDate.getMonth() + 1}月 ${this.currentDate.getDate()}日`)
          .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 10 })

        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
          TabContent() { MonthView({ currentDate: $currentDate }) }.tabBar("月视图")
          TabContent() { WeekView({ currentDate: $currentDate }) }.tabBar("周视图")

          TabContent() {
            DayView({
              currentDate: $currentDate,
              eventList: $eventList,
              // 3. 传入一个回调函数，处理点击事件
              onEventClick: (event: CalendarEvent) => {
                this.openDialog(event); // 点击已有日程 -> 编辑
              }
            })
          }
          .tabBar("日视图")
        }
        .onChange((index: number) => { this.currentIndex = index; })
        .barMode(BarMode.Fixed).width('100%').layoutWeight(1)
      }.width('100%').height('100%')

      Button('+').width(60).height(60).fontSize(40).fontColor(Color.White)
        .backgroundColor('#007DFF').borderRadius(30)
        .shadow({ radius: 10, color: Color.Gray, offsetX: 5, offsetY: 5 })
        .position({ x: '78%', y: '85%' })
        .onClick(() => {
          this.openDialog(undefined); // 点击 + 号 -> 新建 (传 undefined)
        })
    }.width('100%').height('100%')
  }
}

// ... MonthView 和 WeekView 代码保持不变 (请保留原来的代码) ...
// 这里为了篇幅，我只贴需要修改的 DayView，
// 你需要把下面 DayView 覆盖掉你原来的 DayView，
// 但 MonthView 和 WeekView 别删了！

@Component
struct MonthView {
  @Link @Watch('refreshData') currentDate: Date;
  @State daysInGrid: number[] = [];
  aboutToAppear() { this.refreshData(); }
  refreshData() { this.daysInGrid = CalendarUtil.getMonthViewDays(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1); }

  build() {
    Column() {
      Grid() { ForEach(['日', '一', '二', '三', '四', '五', '六'], (item: string) => { GridItem() { Text(item).fontColor(Color.Gray) } }) }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr').height(40)
      Grid() {
        ForEach(this.daysInGrid, (day: number) => {
          GridItem() {
            if (day !== 0) {
              Column() { Text(`${day}`).fontSize(16).fontColor(day === this.currentDate.getDate() ? Color.White : Color.Black) }
              .width(36).height(36).justifyContent(FlexAlign.Center).borderRadius(18)
              .backgroundColor(day === this.currentDate.getDate() ? '#007DFF' : Color.Transparent)
              .onClick(() => { let newDate = new Date(this.currentDate); newDate.setDate(day); this.currentDate = newDate; })
            }
          }
        })
      }.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr').rowsGap(10)
    }.padding(10)
  }
}

@Component
struct WeekView {
  @Link @Watch('refreshData') currentDate: Date;
  @State weekDays: Date[] = [];
  aboutToAppear() { this.refreshData(); }
  refreshData() { this.weekDays = CalendarUtil.getWeekDays(this.currentDate); }
  build() {
    Column() {
      Row() {
        ForEach(this.weekDays, (date: Date) => {
          Column() {
            Text(["日", "一", "二", "三", "四", "五", "六"][date.getDay()]).fontSize(12).fontColor(Color.Gray).margin({bottom: 5})
            Text(`${date.getDate()}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(date.getDate() === this.currentDate.getDate() ? '#007DFF' : Color.Black)
          }.layoutWeight(1).onClick(() => { this.currentDate = date; })
        })
      }.width('100%').padding({top: 10, bottom: 20})
      Divider()
      List() {
        ForEach([9, 10, 11, 12, 13, 14, 15, 16], (hour: number) => {
          ListItem() { Row() { Text(`${hour}:00`).width(50).fontColor(Color.Gray); Divider().vertical(false).layoutWeight(1).color('#f0f0f0') }.height(60).width('100%') }
        })
      }.layoutWeight(1)
    }
  }
}

// ==========================================
// 修改后的 DayView (增加了点击编辑功能)
// ==========================================
@Component
struct DayView {
  @Link currentDate: Date;
  @Link eventList: CalendarEvent[];

  // 新增：点击回调
  onEventClick: (event: CalendarEvent) => void = () => {};

  private hours: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];

  getEventForHour(hour: number): CalendarEvent | undefined {
    return this.eventList.find(event => {
      let eventDate = new Date(event.startTime);
      return eventDate.getDate() === this.currentDate.getDate() &&
        eventDate.getMonth() === this.currentDate.getMonth() &&
        eventDate.getHours() === hour;
    });
  }

  build() {
    Column() {
      Text("今日详情").fontSize(14).fontColor(Color.Gray).alignSelf(ItemAlign.Start).padding(10)

      List() {
        ForEach(this.hours, (hour: number) => {
          ListItem() {
            Row() {
              Column() { Text(`${hour.toString().padStart(2, '0')}:00`).fontSize(14).fontColor(Color.Gray) }.width(60).alignItems(HorizontalAlign.Center)

              Stack({ alignContent: Alignment.TopStart }) {
                Divider().vertical(false).color('#F0F0F0').width('100%')

                // 如果有日程
                if (this.getEventForHour(hour)) {
                  Column() {
                    Text(this.getEventForHour(hour)?.title).fontSize(14).fontColor(Color.White)
                  }
                  .width('90%').height(50)
                  .backgroundColor('#007DFF')
                  .borderRadius(5)
                  .margin({ top: 5, left: 10 })
                  .justifyContent(FlexAlign.Center)
                  // 【新增】点击这个日程块，触发编辑
                  .onClick(() => {
                    let event = this.getEventForHour(hour);
                    if (event) {
                      this.onEventClick(event);
                    }
                  })
                }
              }.layoutWeight(1).height(60).border({ width: { left: 1 }, color: '#EEEEEE' })
            }
          }
        })
      }.layoutWeight(1)
    }
  }
}