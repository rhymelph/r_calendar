import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:r_calendar/r_calendar.dart';
import 'package:r_calendar_example/l10n/s.dart';

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
  RCalendarController controller;

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
        RCalendarController.single(
      isAutoSelect: true,
//      selectedDate: DateTime.now(),
    )..addListener(() {
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
          customWidget: DefaultRCalendarCustomWidget(),
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
