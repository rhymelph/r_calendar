// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:r_calendar/r_calendar_utils.dart';
import 'r_calendar_controller.dart';
import 'r_calendar_custom_widget.dart';

class RCalendarWidgetItem extends StatelessWidget {
  //选中的日期
  final List<DateTime> selectedDates;

  final DateTime currentDate;

  // 最小日期
  final DateTime firstDate;

  // 最大日期
  final DateTime lastDate;

  // 控制器
  final RCalendarController controller;

  //自定义部件
  final RCalendarCustomWidget customWidget;

  //当前选中的日期事件
  final ValueChanged<DateTime> onChanged;

  //当前选中的月份
  final DateTime displayedMonth;

  const RCalendarWidgetItem(
      {Key key,
      this.selectedDates,
      this.currentDate,
      this.firstDate,
      this.lastDate,
      this.controller,
      this.customWidget,
      this.onChanged,
      this.displayedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //获取星期的第一天
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int dayInMonth = RCalendarUtils.getDaysInMonth(year, month);
    //第一天的偏移
    final int firstDayOffset =
        RCalendarUtils.computeFirstDayOffset(year, month, localizations);

    final List<Widget> labels = [];

    for (int i = 0; true; i += 1) {
      final int day = i - firstDayOffset + 1;

      if (day > dayInMonth && i % 7 == 0) break; // 大于当月最大日期和可以除以7
      if (day < 1) {
        //小于当月的日期
        List<RCalendarType> types = [RCalendarType.differentMonth];
        final DateTime dayToBuild =
            DateTime(year, month, 1).subtract(Duration(days: (day * -1) + 1));

        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (customWidget != null && !customWidget.isUnable(dayToBuild, false));
        if (disabled) {
          types.add(RCalendarType.disable);
        }

        if (!disabled) {
          labels.add(GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await customWidget.clickInterceptor(dayToBuild)) {
                return;
              }
              onChanged(dayToBuild);
            },
            child: customWidget.buildDateTime(dayToBuild, types),
          ));
        } else {
          labels.add(customWidget.buildDateTime(dayToBuild, types));
        }
      } else if (day > dayInMonth) {
        //大于当月的日期
        List<RCalendarType> types = [RCalendarType.differentMonth];
        final DateTime dayToBuild = DateTime(year, month, dayInMonth)
            .add(Duration(days: day - dayInMonth));

        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (customWidget != null && !customWidget.isUnable(dayToBuild, false));
        if (disabled) {
          types.add(RCalendarType.disable);
        }

        if (!disabled) {
          labels.add(GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await customWidget.clickInterceptor(dayToBuild)) {
                return;
              }
              onChanged(dayToBuild);
            },
            child: customWidget.buildDateTime(dayToBuild, types),
          ));
        } else {
          labels.add(customWidget.buildDateTime(dayToBuild, types));
        }
      } else {
        List<RCalendarType> types = [RCalendarType.disable];
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (customWidget != null && !customWidget.isUnable(dayToBuild, true));
        if (disabled) {
          types.add(RCalendarType.disable);
        }
        bool isSelectedDay = false;
        try {
          isSelectedDay = selectedDates
                  .where((selectedDate) =>
                      selectedDate.year == year &&
                      selectedDate.month == month &&
                      selectedDate.day == day)
                  .length !=
              0;
        } catch (_) {}
        if (isSelectedDay) {
          types.add(RCalendarType.selected);
        }
        final bool isToday = currentDate.year == year &&
            currentDate.month == month &&
            currentDate.day == day;
        if (isToday) {
          types.add(RCalendarType.today);
        }
        if (!disabled && !isSelectedDay && !isToday) {
          types.add(RCalendarType.normal);
        }

        if (!disabled) {
          labels.add(GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await customWidget.clickInterceptor(dayToBuild)) {
                return;
              }
              onChanged(dayToBuild);
            },
            child: customWidget.buildDateTime(dayToBuild, types),
          ));
        } else {
          labels.add(customWidget.buildDateTime(dayToBuild, types));
        }
      }
    }
    return GridView.custom(
      key: ValueKey<int>(month),
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: _DayPickerGridDelegate(customWidget.childHeight ?? 42),
      childrenDelegate:
          SliverChildListDelegate(labels, addRepaintBoundaries: true),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  final double childHeight;

  const _DayPickerGridDelegate(this.childHeight);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: childHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}
