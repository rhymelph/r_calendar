// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';

class RCalendarController extends ChangeNotifier {
  RCalendarController({this.selectedDate});

  DateTime selectedDate;

  DateTime displayedMonthDate;

  PageController controller;

  DateTime firstDate;

  DateTime lastDate;

  void initial(DateTime firstDate, DateTime endDate) {
    this.firstDate = firstDate;
    this.lastDate = endDate;
    displayedMonthDate = selectedDate;
    final int monthPage =
        _monthDelta(firstDate, selectedDate ?? DateTime.now());
    controller = PageController(initialPage: monthPage);
//    controller.addListener(() {
//      displayMonth = _addMonthsToMonthDate(firstDate, controller.page ~/ 1);
//      notifyListeners();
//    });
  }

  //下一页
  void nextPage({Duration duration, Curve curve}) {
    controller?.nextPage(
        duration: duration ?? Duration(milliseconds: 300),
        curve: curve ?? Curves.linear);
  }

  //上一页
  void previousPage({Duration duration, Curve curve}) {
    controller?.previousPage(
        duration: duration ?? Duration(milliseconds: 300),
        curve: curve ?? Curves.linear);
  }

  //跳转到DateTIme
  void jumpTo(DateTime dateTime) {
    final int monthPage = _monthDelta(firstDate, dateTime);

    controller.jumpToPage(monthPage);
  }

  //计算页数
  int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// 月份添加和减少
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  void updateSelected(DateTime selectedDate) {
    this.selectedDate = selectedDate;
    notifyListeners();
  }

  void updateDisplayedDate(int monthPage) {
    displayedMonthDate = _addMonthsToMonthDate(firstDate, monthPage);
    notifyListeners();
  }

  //最大的页数
  int get maxPage => _monthDelta(firstDate, lastDate) + 1;

  //选中的页数
  int get selectedPage => _monthDelta(firstDate, selectedDate);

  int get displayedPage => _monthDelta(firstDate, displayedMonthDate);
}
