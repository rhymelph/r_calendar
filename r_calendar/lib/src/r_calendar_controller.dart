// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:r_calendar/src/r_calendar_utils.dart';

enum RCalendarMode {
  week,
  month,
}

/// you can use [RCalendarMarker.of(context).notifier] get it.
class RCalendarController<T> extends ChangeNotifier {
  RCalendarController.single(
      {RCalendarMode mode,
      DateTime selectedDate,
      bool isAutoSelect,
      T initialData})
      : _selectedDates = selectedDate != null
            ? SplayTreeSet.of([selectedDate])
            : SplayTreeSet(),
        _isMultiple = false,
        _isDispersion = true,
        _isAutoSelect = isAutoSelect ?? true,
        _data = initialData,
        _mode = mode ?? RCalendarMode.month;

  RCalendarController.multiple(
      {RCalendarMode mode,
      List<DateTime> selectedDates,
      bool isDispersion,
      T initialData})
      : _isMultiple = true,
        _isDispersion = isDispersion ?? true,
        _isAutoSelect = false,
        _selectedDates = SplayTreeSet.of(selectedDates),
        _data = initialData,
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
  SplayTreeSet<DateTime> _selectedDates;

  List<DateTime> get selectedDates {
//    _selectedDates.sort(_sortSelectDates);
    return _selectedDates.toList();
  }

  set selectedDates(List<DateTime> selectedDates) {
    _selectedDates = SplayTreeSet.of(selectedDates);
  }

  //单选选中的日期
  DateTime get selectedDate =>
      _selectedDates.isEmpty ? null : _selectedDates.first;

  set selectedDate(DateTime selectedDate) {
    _selectedDates.remove(_selectedDates.first);
    _selectedDates.add(selectedDate);
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
    if (_selectedDates != null && _selectedDates.length > 1 && !isDispersion) {
      DateTime first = _selectedDates.first;
      DateTime end = _selectedDates.last;
      Duration duration = end.difference(first);
      _selectedDates.clear();
      _selectedDates.addAll(List.generate(
              duration.inDays, (int index) => first.add(Duration(days: index)))
          .toList()
            ..add(end));
    }
    notifyListeners();
  }

  //是否为多选
  bool _isMultiple;

  bool get isMultiple => _isMultiple;

  set isMultiple(bool isMultiple) {
    assert(isMultiple != null, 'is Multiple not null');
    this._isMultiple = isMultiple;
    if (_selectedDates != null &&
        _selectedDates.length > 1 &&
        isMultiple == false) {
      DateTime firstDateTime = _selectedDates.first;
      _selectedDates.clear();
      _selectedDates.add(firstDateTime);
    }
    notifyListeners();
  }

  //日历模式，支持周视图，月视图
  RCalendarMode _mode;

  RCalendarMode get mode => _mode;

  set mode(RCalendarMode mode) {
    if (_mode == null) {
      _mode = mode;
    } else {
      if (_mode != mode) {
        _mode = mode;
        jumpTo(selectedDate ?? displayedMonthDate);
        notifyListeners();
      }
    }
  }

  bool get isMonthMode => _mode == RCalendarMode.month;

  //拓展数据
  T _data;
  T get data => _data;

  set data(T data) {
    _data = data;
    notifyListeners();
  }

  MaterialLocalizations _localizations;

  void initial(BuildContext context, DateTime firstDate, DateTime endDate) {
    this.firstDate = firstDate;
    this.lastDate = endDate;
    if (isMultiple) {
      _selectedDates ??= SplayTreeSet();
    } else {
      _selectedDates ??= SplayTreeSet.of([
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
      ]);
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
//    _selectedDates.sort(_sortSelectDates);
    if (isMultiple) {
      // multiple select
      if (_selectedDates.contains(selectedDate)) {
        // your select dateTime in your selectedDates
        if (_isDispersion) {
          // dispersion select only remove
          _selectedDates.remove(selectedDate);
        } else {
//          //进行移除
//          selectedDates.sort((a, b) =>
//          a.millisecondsSinceEpoch > b.millisecondsSinceEpoch ? 0 : 1);
          if (selectedDate != _selectedDates.first &&
              selectedDate != _selectedDates.last) {
            List<DateTime> dateTimes = _selectedDates.toList();

            final int index = dateTimes.indexOf(selectedDate);
            Duration duration1 = selectedDate.difference(_selectedDates.first);
            Duration duration2 = _selectedDates.last.difference(selectedDate);
            if (duration1.inMilliseconds < duration2.inMilliseconds) {
              dateTimes.removeRange(index + 1, _selectedDates.length);
            } else {
              dateTimes.removeRange(0, index);
            }
            _selectedDates.clear();
            _selectedDates.addAll(dateTimes);
          }
        }
      } else {
        if (_isDispersion || _selectedDates.length < 1) {
          _selectedDates.add(selectedDate);
        } else {
          DateTime first;
          DateTime last;

          if (_selectedDates.length == 1) {
            first = _selectedDates.first;
            if (first.isBefore(selectedDate)) {
              last = selectedDate;
            } else {
              last = first;
              first = last;
            }
          } else {
            first = _selectedDates.first;
            last = _selectedDates.last;
          }

          if (first.isAfter(selectedDate) &&
              (last.isAfter(selectedDate) || _selectedDates.length == 1)) {
            Duration duration = first.difference(selectedDate);
            final List<DateTime> addList = List.generate(duration.inDays,
                (int index) => first.subtract(Duration(days: index)));
            addList.add(selectedDate);
            addList.forEach((dateTime) {
              if (!_selectedDates.contains(dateTime)) {
//                _selectedDates.insert(0, dateTime);
                _selectedDates..add(dateTime);
              }
            });
          } else if (first.isBefore(selectedDate) &&
              (last.isBefore(selectedDate) || _selectedDates.length == 1)) {
            Duration duration = selectedDate
                .difference(_selectedDates.length == 1 ? first : last);
            final List<DateTime> addList = List.generate(
                duration.inDays,
                (int index) => _selectedDates.length == 1
                    ? first.add(Duration(days: index))
                    : last.add(Duration(days: index)));
            addList.add(selectedDate);
            addList.forEach((dateTIme) {
              if (!_selectedDates.contains(dateTIme)) {
                _selectedDates.add(dateTIme);
              }
            });
          }
        }
      }
    } else {
      if (_selectedDates.isEmpty) {
        _selectedDates.add(selectedDate);
      } else {
        _selectedDates.remove(_selectedDates.first);
        _selectedDates.add(selectedDate);
      }
    }
    notifyListeners();
  }

  //更新display日期
  void updateDisplayedDate(int page, RCalendarMode mode) {
    if (mode != _mode) return;

    if (isMonthMode) {
      displayedMonthDate = RCalendarUtils.addMonthsToMonthDate(firstDate, page);
      if (isAutoSelect && isMultiple == false && selectedDate != null) {
        int daysInMonth = RCalendarUtils.getDaysInMonth(
            displayedMonthDate.year, displayedMonthDate.month);
        int day = math.min(daysInMonth, this.selectedDate.day);
        this.selectedDate =
            DateTime(displayedMonthDate.year, displayedMonthDate.month, day);
      }
    } else {
      displayedMonthDate =
          RCalendarUtils.addWeeksToWeeksDate(firstDate, page, _localizations);
      if (isAutoSelect && isMultiple == false && selectedDate != null) {
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

  int _sortSelectDates(DateTime a, DateTime b) {
    return a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch);
  }
}
