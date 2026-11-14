import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/utils/date_formatter.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final Color? foregroundColor;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onMonthChanged,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormatter.monthYear(currentMonth);
    final color = foregroundColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft, color: color),
          onPressed: () => onMonthChanged(
            DateTime(currentMonth.year, currentMonth.month - 1),
          ),
        ),
        GestureDetector(
          onTap: () => _pickMonth(context),
          child: Text(
            label[0].toUpperCase() + label.substring(1),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        IconButton(
          icon: Icon(PhosphorIconsRegular.caretRight, color: color),
          onPressed: () => onMonthChanged(
            DateTime(currentMonth.year, currentMonth.month + 1),
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      onMonthChanged(DateTime(picked.year, picked.month));
    }
  }
}
