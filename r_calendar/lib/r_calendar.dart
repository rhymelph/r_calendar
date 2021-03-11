// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library r_calendar;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_calendar/src/r_calendar_utils.dart';
import 'package:r_calendar/src/r_calendar_widget_item.dart';

import 'src/r_calendar_controller.dart';
import 'src/r_calendar_custom_widget.dart';
export 'src/r_calendar_controller.dart';
export 'src/r_calendar_custom_widget.dart';
export 'src/r_calendar_widget_item.dart';
export 'src/r_calendar_extension.dart';

class RCalendarWidget extends StatefulWidget {
  // 最小日期
  final DateTime? firstDate;

  // 最大日期
  final DateTime? lastDate;

  // 控制器
  final RCalendarController? controller;

  //自定义部件
  final RCalendarCustomWidget? customWidget;

  const RCalendarWidget(
      {Key? key,
      this.firstDate,
      this.lastDate,
      this.controller,
      this.customWidget})
      : super(key: key);

  @override
  _RCalendarWidgetState createState() => _RCalendarWidgetState();
}

class _RCalendarWidgetState extends State<RCalendarWidget> {
  //今天的日期
  DateTime? _toDayDate;

  //用于更新今天
  Timer? _timer;

  ///选中日期更改
  void _handleDayChanged(DateTime value) {
    setState(() {
      widget.controller!.updateSelected(value);
    });
  }

  /// 更新当前日期
  void _updateCurrentDate() {
    _toDayDate = DateTime.now();
    final DateTime tomorrow =
        DateTime(_toDayDate!.year, _toDayDate!.month, _toDayDate!.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_toDayDate!);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  ///处理月份页改变
  void _handlePageChanged(int page, RCalendarMode mode) {
    setState(() {
      widget.controller!.updateDisplayedDate(page, mode);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller!.initial(context, widget.firstDate!, widget.lastDate);
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(RCalendarWidget oldWidget) {
    if (widget.controller!.isMultiple == false) {
      DateTime? firstDate = widget.controller!.selectedDate;
      if (firstDate != null) {
        if (firstDate.month != widget.controller!.displayedMonthDate!.month ||
            firstDate.year != widget.controller!.displayedMonthDate!.year) {
          if (widget.controller!.isMonthMode) {
            widget.controller!.monthController!
                .jumpToPage(widget.controller!.selectedPage);
          } else {
            widget.controller!.weekController!
                .jumpToPage(widget.controller!.selectedPage);
          }
        }
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  int _getSelectRowCount() {
    if (!widget.controller!.isMonthMode) return 1;
    int rowCount = 4;
    int maxDay = RCalendarUtils.getDaysInMonth(
        widget.controller!.displayedMonthDate!.year,
        widget.controller!.displayedMonthDate!.month);
    int labelCount = maxDay +
        RCalendarUtils.computeFirstDayOffset(
            widget.controller!.displayedMonthDate!.year,
            widget.controller!.displayedMonthDate!.month,
            MaterialLocalizations.of(context));
    if (labelCount <= 7 * 4) {
      rowCount = 4;
    } else if (labelCount <= 7 * 5) {
      rowCount = 5;
    } else if (labelCount <= 7 * 6) {
      rowCount = 6;
    }
    return rowCount;
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight =
        widget.customWidget!.childHeight * _getSelectRowCount() + 1;
    //获取星期的第一天
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return RCalendarMarker(
      customWidget: widget.customWidget,
      toDayDate: _toDayDate,
      onChanged: _handleDayChanged,
      controller: widget.controller!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.customWidget?.buildTopWidget(context, widget.controller) ??
              Container(),
          Row(
            children:
                widget.customWidget!.buildWeekListWidget(context, localizations),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: maxHeight,
            child: IndexedStack(
              index: widget.controller!.isMonthMode ? 1 : 0,
              children: <Widget>[
                PageView.builder(
                  key: ValueKey("week_view"),
                  controller: widget.controller!.weekController,
                  itemBuilder: _builderWeekItems,
                  onPageChanged: (int page) {
                    _handlePageChanged(page, RCalendarMode.week);
                  },
                  itemCount: widget.controller!.maxWeekPage,
                  allowImplicitScrolling: true,
                ),
                PageView.builder(
                  key: ValueKey("month_view"),
                  controller: widget.controller!.monthController,
                  itemBuilder: _builderMonthItems,
                  onPageChanged: (int page) {
                    _handlePageChanged(page, RCalendarMode.month);
                  },
                  itemCount: widget.controller!.maxMonthPage,
                  allowImplicitScrolling: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _builderMonthItems(BuildContext context, int index) {
    final DateTime month =
        RCalendarUtils.addMonthsToMonthDate(widget.firstDate!, index);
    return RCalendarMonthItem(
      monthDate: month,
    );
  }

  Widget _builderWeekItems(BuildContext context, int index) {
    DateTime week = RCalendarUtils.addWeeksToWeeksDate(
        widget.firstDate!, index, MaterialLocalizations.of(context));
    return AutoKeepAliveWidget(
      child: RCalendarWeekItem(
        weekDate: week,
      ),
    );
  }
}

class AutoKeepAliveWidget extends StatefulWidget {
  final Widget? child;

  const AutoKeepAliveWidget({Key? key, this.child}) : super(key: key);

  @override
  _AutoKeepAliveWidgetState createState() => _AutoKeepAliveWidgetState();
}

class _AutoKeepAliveWidgetState extends State<AutoKeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child!;
  }

  @override
  bool get wantKeepAlive => true;
}

class RCalendarMarker extends InheritedNotifier<RCalendarController> {
  //部件
  final RCalendarCustomWidget? customWidget;

  //今天
  final DateTime? toDayDate;

  //当前选中的日期事件
  final ValueChanged<DateTime> onChanged;

  const RCalendarMarker({
    required this.onChanged,
    required this.toDayDate,
    required this.customWidget,
    required RCalendarController controller,
    required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(notifier: controller, child: child);

  static RCalendarMarker? of(BuildContext context, {bool nullOk: false}) {
    assert(context != null);
    final RCalendarMarker? inherited =
        context.dependOnInheritedWidgetOfExactType<RCalendarMarker>();
    assert(() {
      if (nullOk) {
        return true;
      }
      if (inherited == null) {
        throw FlutterError(
            'Unable to find a $RCalendarMarker widget in the context.\n'
            '$RCalendarMarker.of() was called with a context that does not contain a '
            '$RCalendarMarker widget.\n'
            'No $RCalendarMarker ancestor could be found starting from the context that was '
            'passed to $RCalendarMarker.of().\n'
            'The context used was:\n'
            '  $context');
      }
      return true;
    }());
    return inherited;
  }

  @override
  bool updateShouldNotify(RCalendarMarker oldWidget) {
    return this.notifier != oldWidget.notifier ||
        this.toDayDate != toDayDate ||
        this.customWidget != customWidget ||
        this.onChanged != onChanged;
  }
}
