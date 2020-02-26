import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:r_calendar/r_calendar.dart';
import 'package:r_calendar_example/l10n/s.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [Locale('zh', ''), Locale('en', '')],
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RCalendarController<List<DateTime>> controller;

  @override
  void initState() {
    super.initState();
    controller =
//    RCalendarController.multiple(
//      selectedDates: [
//        DateTime(2019, 12, 1),
//        DateTime(2019, 12, 2),
//        DateTime(2019, 12, 3),
//      ],
//      isDispersion: false,
//    )
        RCalendarController.single(isAutoSelect: true,
            //mark day
            initialData: [
          DateTime.now(),
          DateTime.now().add(Duration(days: 1)),
          DateTime.now().add(Duration(days: 2)),
        ]
//      selectedDate: DateTime.now(),
            )
          ..addListener(() {
            // controller.isMultiple

            // single selected
            // controller.isAutoSelect
            // controller.selectedDate;

            // multiple selected
            // controller.selectedDates;
            // controller.isDispersion;
          });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: RCalendarWidget(
          controller: controller,
          customWidget: MyRCalendarCustomWidget(),
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime(2055, 12, 31),
        ),
//        child: RecordDatePicker(
//          selectedDate: DateTime.now(),
//          firstDate: DateTime(1970, 1, 1),
//          lastDate: DateTime(2055, 12, 31),
//          children: List.generate(20, (index)=>ListTile(
//            title: Text('data $index'),
//          )),
//        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (controller.isMonthMode) {
                  controller.mode = RCalendarMode.week;
                } else {
                  controller.mode = RCalendarMode.month;
                }
              });
            },
            tooltip: controller.isMonthMode
                ? S.of(context).month
                : S.of(context).week,
            child: Text(
              controller.isMonthMode ? S.of(context).month : S.of(context).week,
              style: TextStyle(
                color: Colors.white,
              ),
              maxLines: 1,
              semanticsLabel: controller.isMonthMode
                  ? S.of(context).month
                  : S.of(context).week,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                controller.isMultiple = !controller.isMultiple;
              });
            },
            tooltip: controller.isMultiple
                ? S.of(context).more
                : S.of(context).single,
            child: Text(
              controller.isMultiple ? S.of(context).more : S.of(context).single,
              style: TextStyle(
                color: Colors.white,
              ),
              maxLines: 1,
              semanticsLabel: controller.isMultiple
                  ? S.of(context).more
                  : S.of(context).single,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          ...controller.isMultiple
              ? [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        controller.isDispersion = !controller.isDispersion;
                      });
                    },
                    tooltip: controller.isDispersion
                        ? S.of(context).alone
                        : S.of(context).together,
                    child: Text(
                      controller.isDispersion
                          ? S.of(context).alone
                          : S.of(context).together,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      semanticsLabel: controller.isDispersion
                          ? S.of(context).alone
                          : S.of(context).together,
                    ),
                  ),
                ]
              : [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        controller.isAutoSelect = !controller.isAutoSelect;
                      });
                    },
                    tooltip: controller.isAutoSelect
                        ? S.of(context).automatic
                        : S.of(context).manual,
                    child: Text(
                      controller.isAutoSelect
                          ? S.of(context).automatic
                          : S.of(context).manual,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      semanticsLabel: controller.isAutoSelect
                          ? S.of(context).automatic
                          : S.of(context).manual,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        controller.selectedDate =
                            controller.selectedDate.add(Duration(days: 1));
                      });
                    },
                    tooltip: S.of(context).add,
                    child: Icon(Icons.add),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        controller.selectedDate =
                            controller.selectedDate.subtract(Duration(days: 1));
                      });
                    },
                    tooltip: S.of(context).reduce,
                    child: Icon(Icons.remove),
                  )
                ],
        ],
      ),
    );
  }
}

class MyRCalendarCustomWidget extends RCalendarCustomWidget {
  @override
  Widget buildDateTime(
      BuildContext context, DateTime time, List<RCalendarType> types) {
    // new
    RCalendarController<List<DateTime>> controller =
        RCalendarMarker.of(context).notifier;
    // new
    TextStyle childStyle;
    BoxDecoration decoration;
    if (types.contains(RCalendarType.disable) ||
        types.contains(RCalendarType.differentMonth)) {
      childStyle = TextStyle(
        color: Colors.grey[400],
        fontSize: 18,
      );
      decoration = BoxDecoration();
    }
    if (types.contains(RCalendarType.normal)) {
      childStyle = TextStyle(
        color: Colors.black,
        fontSize: 18,
      );
      decoration = BoxDecoration();
    }

    if (types.contains(RCalendarType.today)) {
      childStyle = TextStyle(
        color: Colors.blue,
        fontSize: 18,
      );
    }

    if (types.contains(RCalendarType.selected)) {
      childStyle = TextStyle(
        color: Colors.white,
        fontSize: 18,
      );
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      );
    }
    Widget child = Container(
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          time.day.toString(),
          style: childStyle,
        ));
    //get mark day
    if (controller.data
        .where((m) =>
            time.year == m.year && time.month == m.month && time.day == m.day)
        .isNotEmpty) {
      child = Stack(
        children: <Widget>[
          child,
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Icon(
                Icons.star,
                size: 14,
                color: Colors.grey,
              )),
        ],
      );
    }
    return Tooltip(
      message: MaterialLocalizations.of(context).formatFullDate(time),
      child: child,
    );
  }

  @override
  List<Widget> buildWeekListWidget(
      BuildContext context, MaterialLocalizations localizations) {
    return localizations.narrowWeekdays
        .map(
          (d) => Expanded(
            child: ExcludeSemantics(
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  d,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  double get childHeight => 50;

  @override
  FutureOr<bool> clickInterceptor(BuildContext context, DateTime dateTime) {
    return false;
  }

  @override
  bool isUnable(BuildContext context, DateTime time, bool isSameMonth) {
    return isSameMonth;
  }

  @override
  Widget buildTopWidget(BuildContext context, RCalendarController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            controller.previousPage();
          },
        ),
        SizedBox(
          width: 16,
        ),
        Text(
          DateFormat('yyyy-MM').format(controller.displayedMonthDate),
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
        SizedBox(
          width: 16,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            controller.nextPage();
          },
        ),
      ],
    );
  }
}
