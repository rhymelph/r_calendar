// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:r_calendar/r_calendar.dart';
import 'package:r_calendar/src/r_calendar_utils.dart';
import 'r_calendar_controller.dart';
import 'r_calendar_custom_widget.dart';

class RCalendarMonthItem extends StatelessWidget {
  final DateTime? monthDate;

  const RCalendarMonthItem({Key? key, this.monthDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RCalendarMarker data = RCalendarMarker.of(context)!;
    RCalendarController? controller = data.notifier;
    //获取星期的第一天
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = monthDate!.year;
    final int month = monthDate!.month;
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

        final bool disabled = dayToBuild.isAfter(controller!.lastDate!) ||
            dayToBuild.isBefore(controller.firstDate) ||
            (data.customWidget != null &&
                !data.customWidget!.isUnable(context, dayToBuild, false));
        if (disabled) {
          types.add(RCalendarType.disable);
        }

        if (!disabled) {
          labels.add(GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await data.customWidget!
                  .clickInterceptor(context, dayToBuild)) {
                return;
              }
              data.onChanged(dayToBuild);
            },
            child: data.customWidget!.buildDateTime(context, dayToBuild, types),
          ));
        } else {
          labels
              .add(data.customWidget!.buildDateTime(context, dayToBuild, types));
        }
      } else if (day > dayInMonth) {
        //大于当月的日期
        List<RCalendarType> types = [RCalendarType.differentMonth];
        final DateTime dayToBuild = DateTime(year, month, dayInMonth)
            .add(Duration(days: day - dayInMonth));

        final bool disabled = dayToBuild.isAfter(controller!.lastDate!) ||
            dayToBuild.isBefore(controller.firstDate) ||
            (data.customWidget != null &&
                !data.customWidget!.isUnable(context, dayToBuild, false));
        if (disabled) {
          types.add(RCalendarType.disable);
        }

        if (!disabled) {
          labels.add(GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await data.customWidget!
                  .clickInterceptor(context, dayToBuild)) {
                return;
              }
              data.onChanged(dayToBuild);
            },
            child: data.customWidget!.buildDateTime(context, dayToBuild, types),
          ));
        } else {
          labels
              .add(data.customWidget!.buildDateTime(context, dayToBuild, types));
        }
      } else {
        List<RCalendarType> types = [RCalendarType.disable];
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(controller!.lastDate!) ||
            dayToBuild.isBefore(controller.firstDate) ||
            (data.customWidget != null &&
                !data.customWidget!.isUnable(context, dayToBuild, true));
        if (disabled) {
          types.add(RCalendarType.disable);
        }
        bool isSelectedDay = false;
        try {
          isSelectedDay = controller.selectedDates
                  .where((selectedDate) =>
                      selectedDate!.year == year &&
                      selectedDate.month == month &&
                      selectedDate.day == day)
                  .length !=
              0;
        } catch (_) {}
        if (isSelectedDay) {
          types.add(RCalendarType.selected);
        }
        final bool isToday = data.toDayDate!.year == year &&
            data.toDayDate!.month == month &&
            data.toDayDate!.day == day;
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
              if (await data.customWidget!
                  .clickInterceptor(context, dayToBuild)) {
                return;
              }
              data.onChanged(dayToBuild);
            },
            child: Semantics(
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child:
                  data.customWidget!.buildDateTime(context, dayToBuild, types),
            ),
          ));
        } else {
          labels.add(ExcludeSemantics(
            child: data.customWidget!.buildDateTime(context, dayToBuild, types),
          ));
        }
      }
    }

    return GridView.custom(
      key: ValueKey<int>(month),
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: _DayPickerGridDelegate(data.customWidget?.childHeight ?? 42),
      childrenDelegate:
          SliverChildListDelegate(labels, addRepaintBoundaries: false),
    );
  }
}

class RCalendarWeekItem extends StatelessWidget {
  final DateTime? weekDate;

  const RCalendarWeekItem({Key? key, this.weekDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RCalendarMarker data = RCalendarMarker.of(context)!;
    RCalendarController? controller = data.notifier;

    final List<Widget> labels = [];
    for (int i = 0; i < 7; i += 1) {
      final DateTime dayToBuild =
          DateTime(weekDate!.year, weekDate!.month, weekDate!.day + i);
      final int year = dayToBuild.year;
      final int month = dayToBuild.month;
      final int day = dayToBuild.day;
      List<RCalendarType> types = [];
      final bool disabled = dayToBuild.isAfter(controller!.lastDate!) ||
          dayToBuild.isBefore(controller.firstDate) ||
          (data.customWidget != null &&
              !data.customWidget!.isUnable(context, dayToBuild, true));
      if (disabled) {
        types.add(RCalendarType.disable);
      }
      bool isSelectedDay = false;
      try {
        isSelectedDay = controller.selectedDates
                .where((selectedDate) =>
                    selectedDate!.year == year &&
                    selectedDate.month == month &&
                    selectedDate.day == day)
                .length !=
            0;
      } catch (_) {}
      if (isSelectedDay) {
        types.add(RCalendarType.selected);
      }
      final bool isToday = data.toDayDate!.year == year &&
          data.toDayDate!.month == month &&
          data.toDayDate!.day == day;
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
            if (await data.customWidget!.clickInterceptor(context, dayToBuild)) {
              return;
            }
            data.onChanged(dayToBuild);
          },
          child: data.customWidget!.buildDateTime(context, dayToBuild, types),
        ));
      } else {
        labels.add(data.customWidget!.buildDateTime(context, dayToBuild, types));
      }
    }
    return GridView.custom(
      key: ValueKey<String>(weekDate!.toIso8601String()),
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: _DayPickerGridDelegate(data.customWidget?.childHeight ?? 42),
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
