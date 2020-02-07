// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:r_calendar/src/r_calendar_utils.dart';

enum RCalendarMode {
  week,
  month,
}

class RCalendarController extends ChangeNotifier {
  RCalendarController.single(
      {RCalendarMode mode, DateTime selectedDate, bool isAutoSelect})
      : selectedDates = selectedDate != null ? [selectedDate] : [],
        _isMultiple = false,
        _isDispersion = true,
        _isAutoSelect = isAutoSelect ?? true,
        _mode = mode ?? RCalendarMode.month;

  RCalendarController.multiple(
      {RCalendarMode mode, this.selectedDates, bool isDispersion})
      : _isMultiple = true,
        _isDispersion = isDispersion ?? true,
        _isAutoSelect = false,
        _mode = mode ?? RCalendarMode.month;

  //当前显示的月份
  DateTime displayedMonthDate;

  // 月视图控制器
  PageController monthController;

  // 星期视图控制器
  PageController weekController;

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

  RCalendarMode _mode;

  RCalendarMode get mode => _mode;

  set mode(RCalendarMode mode) {
    if (_mode == null) {
      _mode = mode;
    } else {
      if (_mode != mode) {
        _mode = mode;
        jumpTo(selectedDate);
        notifyListeners();
      }
    }
  }

  bool get isMonthMode => _mode == RCalendarMode.month;

  MaterialLocalizations _localizations;

  void initial(BuildContext context, DateTime firstDate, DateTime endDate) {
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
    final int monthPage =
        RCalendarUtils.monthDelta(firstDate, displayedMonthDate);
    monthController = PageController(initialPage: monthPage);
    _localizations = DefaultMaterialLocalizations();

    final int weekPage =
        RCalendarUtils.weekDelta(firstDate, displayedMonthDate, _localizations);
    weekController = PageController(initialPage: weekPage);
//    controller.addListener(() {
//      displayMonth = _addMonthsToMonthDate(firstDate, controller.page ~/ 1);
//      notifyListeners();
//    });
  }

  //下一页
  void nextPage({Duration duration, Curve curve}) {
    if (isMonthMode) {
      monthController?.nextPage(
          duration: duration ?? Duration(milliseconds: 300),
          curve: curve ?? Curves.linear);
    } else {
      weekController?.nextPage(
          duration: duration ?? Duration(milliseconds: 300),
          curve: curve ?? Curves.linear);
    }
  }

  //上一页
  void previousPage({Duration duration, Curve curve}) {
    if (isMonthMode) {
      monthController?.previousPage(
          duration: duration ?? Duration(milliseconds: 300),
          curve: curve ?? Curves.linear);
    } else {
      weekController?.previousPage(
          duration: duration ?? Duration(milliseconds: 300),
          curve: curve ?? Curves.linear);
    }
  }

  //跳转到DateTime
  void jumpTo(DateTime dateTime) {
    if (isMonthMode) {
      final int monthPage = RCalendarUtils.monthDelta(firstDate, dateTime);
      monthController?.jumpToPage(monthPage);
    } else {
      final int monthPage =
          RCalendarUtils.weekDelta(firstDate, dateTime, _localizations);
      weekController?.jumpToPage(monthPage);
    }
  }

  /// when you select the dateTime ,will use this method
  ///
  /// [selectedDate] your select dateTime
  ///
  void updateSelected(DateTime selectedDate) {
    if (isMultiple) {
      // multiple select
      if (selectedDates.contains(selectedDate)) {
        // your select dateTime in your selectedDates
        if (_isDispersion) {
          // dispersion select only remove
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

  //更新display日期
  void updateDisplayedDate(int page,RCalendarMode mode) {
    if(mode!=_mode) return;

    if (isMonthMode) {
      displayedMonthDate = RCalendarUtils.addMonthsToMonthDate(firstDate, page);
      if (isAutoSelect && isMultiple == false) {
        int daysInMonth = RCalendarUtils.getDaysInMonth(
            displayedMonthDate.year, displayedMonthDate.month);
        int day = math.min(daysInMonth, this.selectedDate.day);
        this.selectedDate =
            DateTime(displayedMonthDate.year, displayedMonthDate.month, day);
      }
    } else {
      displayedMonthDate =
          RCalendarUtils.addWeeksToWeeksDate(firstDate, page, _localizations);
      if (isAutoSelect && isMultiple == false) {
        bool isBefore = this.selectedDate.isBefore(displayedMonthDate);
        bool isAfter = this
            .selectedDate
            .isAfter(displayedMonthDate.add(Duration(days: 7)));
        if (isBefore || isAfter) {
//        this.selectedDate = displayedMonthDate.add(Duration(days: oldIndex));
          this.selectedDate =
              this.selectedDate.add(Duration(days: isBefore ? 7 : -7));
        }
      }
    }
    notifyListeners();
  }

  //最大的页数
  int get maxPage => isMonthMode
      ? RCalendarUtils.monthDelta(firstDate, lastDate) + 1
      : RCalendarUtils.weekDelta(firstDate, lastDate, _localizations) + 1;

  //选中的页数
  int get selectedPage => isMonthMode
      ? RCalendarUtils.monthDelta(firstDate, selectedDate ?? displayedMonthDate)
      : RCalendarUtils.weekDelta(
          firstDate, selectedDate ?? displayedMonthDate, _localizations);

  //当前显示的页面
  int get displayedPage => isMonthMode
      ? RCalendarUtils.monthDelta(firstDate, displayedMonthDate)
      : RCalendarUtils.weekDelta(firstDate, displayedMonthDate, _localizations);

  @override
  void dispose() {
    monthController?.dispose();
    weekController?.dispose();
    super.dispose();
  }
}
