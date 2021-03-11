// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';

///一个月有多少天
const List<int> _daysInMonth = <int>[
  31,
  -1,
  31,
  30,
  31,
  30,
  31,
  31,
  30,
  31,
  30,
  31
];

class RCalendarUtils {
  /// 获取一个月有多少天
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /// 获取第一天的偏移量,星期一
  static int computeFirstDayOffset(
      int year, int month, MaterialLocalizations? localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday =
        localizations?.firstDayOfWeekIndex ?? 0;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  /// 月份添加和减少
  static DateTime addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  /// 星期添加和减少
  static DateTime addWeeksToWeeksDate(
      DateTime weekDate, int weeksToAdd, MaterialLocalizations? localizations) {
    final firstDayOffset =
        computeFirstDayOffset(weekDate.year, weekDate.month, localizations);
    DateTime weekFirstDate = weekDate.subtract(Duration(days: firstDayOffset));
    return weekFirstDate.add(Duration(days: weeksToAdd * DateTime.daysPerWeek));
  }

  /// 月份总页数
  static int monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// 星期总页数
  static int weekDelta(DateTime startDate, DateTime endDate,
      MaterialLocalizations? localizations) {
    final int firstDayOffset =
        computeFirstDayOffset(startDate.year, startDate.month, localizations);
    Duration diff = DateTime(endDate.year, endDate.month, endDate.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day));
    int days = diff.inDays + firstDayOffset + 1;
    return (days / 7).ceil() - 1;
  }
}
