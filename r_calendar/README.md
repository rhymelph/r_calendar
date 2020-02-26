# r_calendar

[![pub package](https://img.shields.io/pub/v/r_calendar.svg)](https://pub.dartlang.org/packages/r_calendar)

A new Flutter package about calendar,you can use this design the calendar and support single or multiple selected.


## [中文点此](README_ZH.md)

## 1.Getting Started.

- use plugin:
add this code in `pubspec.yaml`
```yaml
dependencies:
  r_calendar: last version
```
- add the packages to your file.
```dart
import 'package:r_calendar/r_calendar.dart';

```
- radio select
```dart
///
/// [selectedDate] will default selected one
/// [isAutoSelect] when the page view change will change month to auto select same day.
    RCalendarController controller= RCalendarController.single(
                    selectedDate: DateTime.now(),
                    isAutoSelect: true,);
```
- check select
```dart
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
```
- value change listener
```dart
///
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

    // mode month/week
    // controller.mode
    });
```
- custom your widget
```dart

class MyRCalendarCustomWidget extends RCalendarCustomWidget {

  // If you want to change first day is Monday ,you can change [MaterialLocalizations.firstDayOfWeekIndex]
  // SUM MON TUE WED THU FRI SUT
  //build your week header
  @override
  List<Widget> buildWeekListWidget(BuildContext context,MaterialLocalizations localizations){...};

  // 1 2 3 4 5 6 7
  //build normal dateTime
  @override
  Widget buildDateTime(BuildContext context, DateTime time, List<RCalendarType> types){...};

  //   <  2019 year 11 month >
  //build year and month and left 、 right Indicator
  @override
  Widget buildTopWidget(BuildContext context, RCalendarController controller){...};


  //is unable will not have tap events
  @override
  bool isUnable(DateTime time, bool isSameMonth){...};

  //Click intercept. When it returns true to intercept, the selected date will not be changed
  @override
  FutureOr<bool> clickInterceptor(BuildContext context, DateTime dateTime){...};

  //Height of child view
  @override
  double get childHeight=>{...};
}
```

## 2.Use this
```dart
import 'package:flutter/material.dart';
import 'package:r_calendar/r_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
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
## 3.Expand Data(update by v0.1.6 )
```dart
/// initial
    RCalendarController<List<DateTime>> controller =  RCalendarController.single(
    initialData: [
            DateTime.now(),
            DateTime.now().add(Duration(days: 1)),
            DateTime.now().add(Duration(days: 2)),
          ]
    );

/// if you want to update expand data ,use it.
    controller.data = [....];

/// you can use it get the controller in RCalendarCustomWidget

class MyRCalendarCustomWidget extends RCalendarCustomWidget {
///...
  @override
  Widget buildDateTime(
      BuildContext context, DateTime time, List<RCalendarType> types) {

    // new
    RCalendarController<List<DateTime>> controller =RCalendarMarker.of(context).notifier;
    // new

    //...
   }
///...
```