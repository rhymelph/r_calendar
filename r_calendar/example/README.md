# r_calendar_example

## English Language

### 1.RCalendarController

value controller

```dart
import 'package:r_calendar/r_calendar.dart';

/// radio select
///
/// [selectedDate] will default selected one
/// [isAutoSelect] when the page view change will change month to auto select same day.

    RCalendarController controller= RCalendarController.single(
                    selectedDate: DateTime.now(),
                    isAutoSelect: true,);


/// check select
///
/// [selectedDates] will default selected more.
/// [isDispersion] will selected continuity dateTime.
    RCalendarController controller = RCalendarController.multiple(
                    selectedDates: [
                        DateTime(2019, 12, 1),
                        DateTime(2019, 12, 2),
                        DateTime(2019, 12, 3),
                    ],
                    isDispersion: true);

/// addListener to observe value change
    RCalendarController controller = RCalendarController.multiple(...)
    addListener((){
    // controller.isMultiple

    // single selected
    // controller.isAutoSelect
    // controller.selectedDate;

    // multiple selected
    // controller.selectedDates;
    // controller.isDispersion;
    });
```

### 2.RCalendarCustomWidget

custom your widget

```dart

class MyRCalendarCustomWidget extends RCalendarCustomWidget {

  // If you want to change first day is Monday ,you can change [MaterialLocalizations.firstDayOfWeekIndex]
  // SUM MON TUE WED THU FRI SUT
  //build your week header
  @override
  List<Widget> buildWeekListWidget(MaterialLocalizations localizations){...};

  // 1 2 3 4 5 6 7
  //build normal dateTime
  @override
  Widget buildDateTime(DateTime time, List<RCalendarType> types){...};

  //   <  2019 year 11 month >
  //build year and month and left 、 right Indicator
  @override
  Widget buildTopWidget(RCalendarController controller){...};

  //is unable will not have tap events
  @override
  bool isUnable(DateTime time, bool isSameMonth){...};

  //Click intercept. When it returns true to intercept, the selected date will not be changed
  @override
  FutureOr<bool> clickInterceptor(DateTime dateTime){...};

  //Height of child view
  @override
  double get childHeight=>{...};
}

```
### 3.Use the widget.

```dart
import 'package:flutter/material.dart';
import 'package:r_calendar/r_calendar.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  RCalendarController controller;

  @override
  void initState() {
    super.initState();
    controller = RCalendarController.multiple(selectedDates: [
      DateTime(2019, 12, 1),
      DateTime(2019, 12, 2),
      DateTime(2019, 12, 3),
    ]);
//    controller = RCalendarController.single(selectedDate: DateTime.now(),isAutoSelect: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RCalendarWidget(
               controller: controller,
               customWidget: DefaultRCalendarCustomWidget(),
               firstDate: DateTime(1970, 1, 1),
               lastDate: DateTime(2055, 12, 31),
             ),
    );
  }
}

```

## Chinese Language

### 1.RCalendarController

值的控制器

```dart
import 'package:r_calendar/r_calendar.dart';

/// 单选
///
/// [selectedDate] 默认选中的那天
/// [isAutoSelect] 当月份改变时，是否自动选中对应的月份的同一天

    RCalendarController controller= RCalendarController.single(
                    selectedDate: DateTime.now(),
                    isAutoSelect: true,);


/// 多选
///
/// [selectedDates] 默认选中的日期数组
/// [isDispersion] 是否散选，否则为连续选中

    RCalendarController controller = RCalendarController.multiple(
                    selectedDates: [
                        DateTime(2019, 12, 1),
                        DateTime(2019, 12, 2),
                        DateTime(2019, 12, 3),
                    ],
                    isDispersion: true);

/// 添加监听器观察值的变化
    RCalendarController controller = RCalendarController.multiple(...)
    addListener((){
    // 是否为多选
    // controller.isMultiple

    // 单选下
    // 当月份改变时，是否自动选中对应的月份的同一天
    // controller.isAutoSelect
    // 当前选中的日期
    // controller.selectedDate;

    // 多选
    // 是否散选，否则为连续选中
    // controller.isDispersion;
    // 当前选中的日期列表
    // controller.selectedDates;
    });
```

### 2.RCalendarCustomWidget

自定义 日历小部件

```dart

class MyRCalendarCustomWidget extends RCalendarCustomWidget {
  // 如果你想设置第一天是星期一，请更改MaterialLocalizations 的firstDayOfWeekIndex
  // 日 一 二 三 四 五 六
  //构建头部
  @override
  List<Widget> buildWeekListWidget(MaterialLocalizations localizations){...};

  // 1 2 3 4 5 6 7
  //构建普通的日期
  @override
  Widget buildDateTime(DateTime time, List<RCalendarType> types){...};

  //   <  2019年 11月 >
  //构建年份和月份 左指示器、右指示器，返回null就没有
  @override
  Widget buildTopWidget(RCalendarController controller){...};

  //是否不可用,不可用时，无点击事件
  @override
  bool isUnable(DateTime time, bool isSameMonth){...};

  //点击拦截，当返回true时进行拦截，就不会改变选中日期
  @override
  FutureOr<bool> clickInterceptor(DateTime dateTime){...};

  //子view的高度
  @override
  double get childHeight=>{...};
}

```

## 3.使用小部件

### 3.Use the widget.

```dart
import 'package:flutter/material.dart';
import 'package:r_calendar/r_calendar.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  RCalendarController controller;

  @override
  void initState() {
    super.initState();
    controller = RCalendarController.multiple(selectedDates: [
      DateTime(2019, 12, 1),
      DateTime(2019, 12, 2),
      DateTime(2019, 12, 3),
    ]);
//    controller = RCalendarController.single(selectedDate: DateTime.now(),isAutoSelect: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RCalendarWidget(
               controller: controller,
               customWidget: DefaultRCalendarCustomWidget(),
               firstDate: DateTime(1970, 1, 1), //当前日历的最小日期
               lastDate: DateTime(2055, 12, 31),//当前日历的最大日期
             ),
    );
  }
}

```