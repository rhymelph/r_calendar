// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:r_calendar/r_calendar_utils.dart';

class RCalendarController extends ChangeNotifier {
  RCalendarController.single({DateTime selectedDate, bool isAutoSelect})
      : selectedDates = selectedDate != null ? [selectedDate] : [],
        _isMultiple = false,
        _isDispersion = true,
        _isAutoSelect = isAutoSelect ?? true;

  RCalendarController.multiple({this.selectedDates, bool isDispersion})
      : _isMultiple = true,
        _isDispersion = isDispersion ?? true,
        _isAutoSelect = false;

  //当前显示的月份
  DateTime displayedMonthDate;

  //page view 视图控制器
  PageController controller;

  DateTime firstDate;

  DateTime lastDate;

  //多选
  List<DateTime> selectedDates;

  //单选选中的日期
  DateTime get selectedDate =>
      selectedDates.isEmpty ? null : selectedDates.first;

  set selectedDate(DateTime selectedDate) {
    selectedDates.first = selectedDate;
  }

  //单选是否当切换月份时自动选
  bool _isAutoSelect;

  bool get isAutoSelect => _isAutoSelect;

  set isAutoSelect(bool isAutoSelect) {
    assert(isAutoSelect != null, 'is audo select not null');
    this._isAutoSelect = isAutoSelect;
    notifyListeners();
  }

  //是否为散选
  bool _isDispersion;

  bool get isDispersion => _isDispersion;

  set isDispersion(bool isDispersion) {
    assert(isDispersion != null, 'is dispersion not null');
    _isDispersion = isDispersion;
    if (selectedDates != null && selectedDates.length > 1 && !isDispersion) {
      selectedDates.sort((a, b) =>
          a.millisecondsSinceEpoch > b.millisecondsSinceEpoch ? 1 : 0);
      DateTime first = selectedDates.first;
      DateTime end = selectedDates.last;
      Duration duration = end.difference(first);
      selectedDates = List.generate(
              duration.inDays, (int index) => first.add(Duration(days: index)))
          .toList()
            ..add(end);
    }
    notifyListeners();
  }

  //是否为多选
  bool _isMultiple;

  bool get isMultiple => _isMultiple;

  set isMultiple(bool isMultiple) {
    assert(isMultiple != null, 'is Multiple not null');
    this._isMultiple = isMultiple;
    if (selectedDates != null &&
        selectedDates.length > 1 &&
        isMultiple == false) {
      selectedDates.removeRange(1, selectedDates.length);
    }
    notifyListeners();
  }

  void initial(DateTime firstDate, DateTime endDate) {
    this.firstDate = firstDate;
    this.lastDate = endDate;
    if (isMultiple) {
      selectedDates ??= [];
      if (selectedDates.length > 1) {
        selectedDates.sort((a, b) =>
            a.millisecondsSinceEpoch > b.millisecondsSinceEpoch ? 1 : 0);
      }
    } else {
      selectedDates ??= [DateTime.now()];
    }
    displayedMonthDate = selectedDate ?? DateTime.now();
    final int monthPage = _monthDelta(firstDate, displayedMonthDate);
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
    if (isMultiple) {
      if (selectedDates.contains(selectedDate)) {
        if (_isDispersion) {
          selectedDates.remove(selectedDate);
        } else {
//          //进行移除
//          selectedDates.sort((a, b) =>
//          a.millisecondsSinceEpoch > b.millisecondsSinceEpoch ? 0 : 1);
          if (selectedDate != selectedDates.first &&
              selectedDate != selectedDates.last) {
            final int index = selectedDates.indexOf(selectedDate);
            Duration duration1 = selectedDate.difference(selectedDates.first);
            Duration duration2 = selectedDates.last.difference(selectedDate);
            if (duration1.inMilliseconds < duration2.inMilliseconds) {
              selectedDates.removeRange(index + 1, selectedDates.length);
            } else {
              selectedDates.removeRange(0, index);
            }
          }
        }
      } else {
        if (_isDispersion || selectedDates.length < 1) {
          selectedDates.add(selectedDate);
        } else {
          DateTime first;
          DateTime last;

          if (selectedDates.length == 1) {
            first = selectedDates.first;
            if (first.isBefore(selectedDate)) {
              last = selectedDate;
            } else {
              last = first;
              first = last;
            }
          } else {
            first = selectedDates.first;
            last = selectedDates.last;
          }

          if (first.isAfter(selectedDate) &&
              (last.isAfter(selectedDate) || selectedDates.length == 1)) {
            Duration duration = first.difference(selectedDate);
            final List<DateTime> addList = List.generate(duration.inDays,
                (int index) => first.subtract(Duration(days: index)));
            addList.add(selectedDate);
            addList.forEach((dateTime) {
              if (!selectedDates.contains(dateTime)) {
                selectedDates.insert(0, dateTime);
              }
            });
          } else if (first.isBefore(selectedDate) &&
              (last.isBefore(selectedDate) || selectedDates.length == 1)) {
            Duration duration = selectedDate
                .difference(selectedDates.length == 1 ? first : last);
            final List<DateTime> addList = List.generate(
                duration.inDays,
                (int index) => selectedDates.length == 1
                    ? first.add(Duration(days: index))
                    : last.add(Duration(days: index)));
            addList.add(selectedDate);
            addList.forEach((dateTIme) {
              if (!selectedDates.contains(dateTIme)) {
                selectedDates.add(dateTIme);
              }
            });
          }
        }
      }
    } else {
      if (selectedDates.isEmpty) {
        selectedDates.add(selectedDate);
      } else {
        selectedDates.first = selectedDate;
      }
    }
    notifyListeners();
  }

  void updateDisplayedDate(int monthPage) {
    displayedMonthDate = _addMonthsToMonthDate(firstDate, monthPage);
    if (isAutoSelect && isMultiple == false) {
      int daysInMonth = RCalendarUtils.getDaysInMonth(
          displayedMonthDate.year, displayedMonthDate.month);
      int day = math.min(daysInMonth, this.selectedDate.day);
      this.selectedDate =
          DateTime(displayedMonthDate.year, displayedMonthDate.month, day);
    }
    notifyListeners();
  }

  //最大的页数
  int get maxPage => _monthDelta(firstDate, lastDate) + 1;

  //选中的页数
  int get selectedPage => _monthDelta(firstDate, selectedDates.first);

  //当前显示的页面
  int get displayedPage => _monthDelta(firstDate, displayedMonthDate);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
