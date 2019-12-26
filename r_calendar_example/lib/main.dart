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
    controller = RCalendarController(selectedDate: DateTime.now());
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
