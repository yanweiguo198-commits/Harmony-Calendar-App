# 📅 HarmonyOS Calendar App (鸿蒙日历)

> 这是一个基于 HarmonyOS (ArkTS) 开发的个人日历应用。
> 包含月/周/日视图切换、日程增删改查以及后台提醒功能。

## ✨ 功能特性 (Features)

* **多视图切换**：
    * 🗓️ **月视图**：查看整月日期分布，高亮选中日期。
    * 📅 **周视图**：直观展示本周 7 天的日期。
    * 🕒 **日视图**：以 24 小时时间轴展示当天日程详情。
* **日程管理**：
    * ➕ **添加日程**：支持设置标题、开始/结束时间、是否开启提醒。
    * ✏️ **编辑日程**：点击日视图中的日程条，可修改现有日程。
    * 💾 **数据联动**：修改数据后，所有视图自动同步刷新。
* **🔔 智能提醒**：
    * 集成 `ReminderAgent` 后台代理提醒。
    * 日程到期时，系统会自动弹出通知（即使应用在后台）。

## 🛠️ 技术栈 (Tech Stack)

* **开发语言**：ArkTS (TypeScript)
* **UI 框架**：ArkUI (声明式开发范式)
* **开发工具**：DevEco Studio
* **核心 API**：
    * `@ohos.reminderAgentManager` (后台代理提醒)
    * `CustomDialogController` (自定义弹窗)
    * `Tabs` & `Grid` & `List` (核心布局组件)

## 📂 项目结构 (Project Structure)

```text
ets
├── entryability
│   └── EntryAbility.ets        // 应用入口
├── pages
│   └── Index.ets               // 主页面 (包含 Tab 切换逻辑)
├── components
│   └── AddEventDialog.ets      // 添加/编辑日程的弹窗组件
├── model
│   ├── EventModel.ets          // 数据模型 (CalendarEvent 类)
│   └── CalendarUtil.ets        // 日期计算工具类
└── service
    └── ReminderService.ets     // 后台提醒服务封装
