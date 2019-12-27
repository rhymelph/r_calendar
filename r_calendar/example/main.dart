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
    print('build');
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
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: controller.isMultiple
            ? <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      controller.isMultiple = !controller.isMultiple;
                    });
                  },
                  child: Text(
                    controller.isMultiple ? '多' : '单',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      controller.isDispersion = !controller.isDispersion;
                    });
                  },
                  child: Text(
                    controller.isDispersion ? '散' : '聚',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ]
            : <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      controller.isMultiple = !controller.isMultiple;
                    });
                  },
                  child: Text(
                    controller.isMultiple ? '多' : '单',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      controller.isAutoSelect = !controller.isAutoSelect;
                    });
                  },
                  child: Text(
                    controller.isAutoSelect ? '自' : '手',
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
                  child: Icon(Icons.remove),
                )
              ],
      ),
    );
  }
}
