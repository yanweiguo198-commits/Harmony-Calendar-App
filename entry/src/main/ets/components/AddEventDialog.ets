import { CalendarEvent } from '../model/EventModel';

@CustomDialog
export struct AddEventDialog {
  controller: CustomDialogController;
  // 1. 新增：接收一个可选的旧事件（如果是编辑模式，这个会有值）
  editEvent?: CalendarEvent;

  selectedDate: Date = new Date();
  onSave: (event: CalendarEvent) => void = () => {};

  @State title: string = '';
  @State startTime: Date = new Date();
  @State endTime: Date = new Date();
  @State isRemind: boolean = false;

  aboutToAppear() {
    // 2. 判断：如果是编辑模式，把旧数据填入输入框
    if (this.editEvent) {
      this.title = this.editEvent.title;
      this.startTime = new Date(this.editEvent.startTime);
      this.endTime = new Date(this.editEvent.endTime);
      this.isRemind = this.editEvent.isReminded;
    } else {
      // 新建模式：使用默认时间
      this.startTime = new Date(this.selectedDate);
      this.endTime = new Date(this.selectedDate);
      this.endTime.setHours(this.endTime.getHours() + 1);
    }
  }

  formatTime(date: Date): string {
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 标题根据模式变化
      Text(this.editEvent ? '编辑日程' : '新建日程')
        .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })

      Column({ space: 15 }) {
        TextInput({ text: this.title, placeholder: '请输入日程标题' }) // 绑定 text
          .onChange((value) => { this.title = value })
          .width('90%').height(50).backgroundColor('#F5F5F5').borderRadius(10)

        // 开始时间
        Row() {
          Text('开始时间').fontSize(16)
          Text(this.formatTime(this.startTime)).fontSize(16).fontColor('#007DFF')
            .onClick(() => {
              TimePickerDialog.show({
                selected: this.startTime,
                useMilitaryTime: true,
                onAccept: (value: TimePickerResult) => {
                  this.startTime.setHours(value.hour, value.minute);
                  this.startTime = new Date(this.startTime);
                }
              })
            })
        }.width('90%').justifyContent(FlexAlign.SpaceBetween).padding(10).backgroundColor('#F5F5F5').borderRadius(10)

        // 提醒开关
        Row() {
          Text('开启提醒').fontSize(16)
          Toggle({ type: ToggleType.Switch, isOn: this.isRemind })
            .onChange((isOn: boolean) => { this.isRemind = isOn; })
        }.width('90%').justifyContent(FlexAlign.SpaceBetween).padding(5)
      }.width('100%')

      Row() {
        Button('取消').backgroundColor('#E5E5E5').fontColor(Color.Black).width('40%')
          .onClick(() => { this.controller.close(); })

        Button('保存').width('40%')
          .onClick(() => {
            if (this.title === '') return;

            // 3. 构建对象
            let newEvent = new CalendarEvent(this.title, this.startTime.getTime(), this.endTime.getTime());
            newEvent.isReminded = this.isRemind;

            // 如果是编辑模式，保持原来的 ID 不变！这点很重要
            if (this.editEvent) {
              newEvent.id = this.editEvent.id;
              newEvent.reminderId = this.editEvent.reminderId; // 保持原来的提醒ID
            }

            this.onSave(newEvent);
            this.controller.close();
          })
      }.justifyContent(FlexAlign.SpaceEvenly).width('100%').margin({ top: 30, bottom: 20 })
    }.backgroundColor(Color.White).borderRadius(20).width('90%')
  }
}