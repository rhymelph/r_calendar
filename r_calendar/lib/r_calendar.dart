// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library r_calendar;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_calendar/r_calendar_utils.dart';
import 'package:r_calendar/r_calendar_widget_item.dart';

import 'r_calendar_controller.dart';
import 'r_calendar_custom_widget.dart';
export 'r_calendar_controller.dart';
export 'r_calendar_custom_widget.dart';
export 'r_calendar_widget_item.dart';

class RCalendarWidget extends StatefulWidget {
  // 最小日期
  final DateTime firstDate;

  // 最大日期
  final DateTime lastDate;

  // 控制器
  final RCalendarController controller;

  //自定义部件
  final RCalendarCustomWidget customWidget;

  const RCalendarWidget({Key key,
    this.firstDate,
    this.lastDate,
    this.controller,
    this.customWidget})
      : super(key: key);

  @override
  _RCalendarWidgetState createState() => _RCalendarWidgetState();
}

class _RCalendarWidgetState extends State<RCalendarWidget> {
  DateTime _toDayDate;
  DateTime _previousMonthDate;
  DateTime _currentDisplayedMonthDate;
  DateTime _nextMonthDate;

  Timer _timer;

  ///选中日期更改
  void _handleDayChanged(DateTime value) {
    setState(() {
      widget.controller.selectedDate = value;
    });
  }

  /// 月份添加和减少
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  /// 更新当前日期
  void _updateCurrentDate() {
    _toDayDate = DateTime.now();
    final DateTime tomorrow =
    DateTime(_toDayDate.year, _toDayDate.month, _toDayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_toDayDate);
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
  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.initial(widget.firstDate, widget.lastDate);

    final int monthPage = widget.controller.selectedPage;
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(RCalendarWidget oldWidget) {
    if (widget.controller.selectedDate.month !=
        _currentDisplayedMonthDate.month ||
        widget.controller.selectedDate.year !=
            _currentDisplayedMonthDate.year) {
      widget.controller.controller.jumpToPage(widget.controller.selectedPage);
    }
    super.didUpdateWidget(oldWidget);
  }

  int _getSelectRowCount() {
    int rowCount = 4;
    int maxDay = RCalendarUtils.getDaysInMonth(
        _currentDisplayedMonthDate.year,
        _currentDisplayedMonthDate.month);
    int labelCount = maxDay +
        RCalendarUtils.computeFirstDayOffset(
            _currentDisplayedMonthDate.year,
            _currentDisplayedMonthDate.month,
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
    double maxHeight = widget.customWidget.childHeight * _getSelectRowCount() +
        1;
    //获取星期的第一天
    final MaterialLocalizations localizations =
    MaterialLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: widget.customWidget.buildLeftIndicator(),
              onPressed: () {
                widget.controller.previousPage();
              },
            ),
            SizedBox(
              width: 16,
            ),
            widget.customWidget.buildMonthYear(_currentDisplayedMonthDate),
            SizedBox(
              width: 16,
            ),
            IconButton(
              icon: widget.customWidget.buildRightIndicator(),
              onPressed: () {
                widget.controller.nextPage();
              },
            ),
          ],
        ),
        Row(
          children: widget.customWidget.buildWeekListWidget(localizations),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: maxHeight,
          child: PageView.builder(
            controller: widget.controller.controller,
            itemBuilder: _builderItems,
            onPageChanged: _handleMonthPageChanged,
            itemCount: widget.controller.maxPage,
          ),
        ),
      ],
    );
  }

  Widget _builderItems(BuildContext context, int index) {
    final DateTime month = _addMonthsToMonthDate(widget.firstDate, index);
    return RCalendarWidgetItem(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.controller.selectedDate,
      customWidget: widget.customWidget,
      currentDate: _toDayDate,
      onChanged: _handleDayChanged,
      displayedMonth: month,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      controller: widget.controller,
    );
  }
}
