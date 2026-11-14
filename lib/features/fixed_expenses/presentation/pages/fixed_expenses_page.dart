import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/icon_registry.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousand_separator_formatter.dart';
import '../../../../shared/painters/wave_painter.dart';
import '../../../../shared/widgets/animated_check_button.dart';
import '../../../../shared/widgets/breathing_icon.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../transactions/presentation/cubit/transaction_form_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_form_state.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/entities/fixed_expenses_summary.dart';
import '../cubit/fixed_expenses_cubit.dart';
import '../cubit/fixed_expenses_state.dart';

class FixedExpensesPage extends StatefulWidget {
  const FixedExpensesPage({super.key});

  @override
  State<FixedExpensesPage> createState() => _FixedExpensesPageState();
}

class _FixedExpensesPageState extends State<FixedExpensesPage> {
  late final FixedExpensesCubit _cubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _cubit = sl<FixedExpensesCubit>();
    _loadMonth();
  }

  void _loadMonth() {
    _cubit.loadMonth(_currentMonth.month, _currentMonth.year);
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _currentMonth = month);
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final headerPrimary = isDark
        ? scheme.primary.withAlpha(60)
        : scheme.primary;
    final headerSecondary = isDark
        ? scheme.primary.withAlpha(35)
        : scheme.primary.withAlpha(180);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: Icon(PhosphorIconsBold.plus),
      ),
      body: BlocBuilder<FixedExpensesCubit, FixedExpensesState>(
        bloc: _cubit,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _loadMonth(),
            edgeOffset: 200,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 220),
                        painter: WaveHeaderPainter(
                          color: headerPrimary,
                          secondaryColor: headerSecondary,
                        ),
                      ),
                      CustomPaint(
                        size: const Size(double.infinity, 220),
                        painter: TopographyPainter(
                          lineColor: Colors.white.withAlpha(isDark ? 12 : 25),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                'Gastos Fijos',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? scheme.onSurface : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              MonthSelector(
                                currentMonth: _currentMonth,
                                onMonthChanged: _onMonthChanged,
                                foregroundColor: isDark ? null : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is FixedExpensesLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is FixedExpensesError)
                  SliverFillRemaining(
                    child: Center(child: Text('Error: ${state.message}')),
                  )
                else if (state is FixedExpensesLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -30),
                        child: _buildLoadedContent(context, state.summary),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, FixedExpensesSummary summary) {
    final theme = Theme.of(context);

    if (summary.expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BreathingIcon(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(80),
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIconsDuotone.clipboardText,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sin gastos fijos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agrega tus gastos mensuales recurrentes\npara llevar control de lo que pagas',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildKpiGrid(summary),
        const SizedBox(height: 16),
        _buildProgressBar(summary, theme),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Gastos del mes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${summary.paidCount}/${summary.totalCount} pagados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...summary.expenses.map(
            (expense) => _buildExpenseTile(context, expense, theme)),
      ],
    );
  }

  Widget _buildKpiGrid(FixedExpensesSummary summary) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        KpiCard(
          title: 'Gastos Total',
          value: _currencyFormatter.format(summary.totalExpenses),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.arrowUp,
            size: 18,
            color: theme.colorScheme.error,
          ),
          valueColor: theme.colorScheme.error,
        ),
        KpiCard(
          title: 'Gasto Restante',
          value: _currencyFormatter.format(summary.totalRemaining),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.warning,
            size: 18,
            color: theme.appColors.warning,
          ),
          valueColor: theme.appColors.warning,
        ),
        KpiCard(
          title: 'Salario',
          value: _currencyFormatter.format(summary.salary),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.currencyDollar,
            size: 18,
            color: theme.appColors.success,
          ),
          valueColor: theme.appColors.success,
        ),
        KpiCard(
          title: 'Saldo Restante',
          value: _currencyFormatter.format(summary.salaryRemaining),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.wallet,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          valueColor: summary.salaryRemaining >= 0
              ? theme.appColors.success
              : theme.colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildProgressBar(FixedExpensesSummary summary, ThemeData theme) {
    final progress = summary.totalExpenses > 0
        ? summary.totalPaid / summary.totalExpenses
        : 0.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            color: theme.appColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pagado: ${_currencyFormatter.format(summary.totalPaid)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.appColors.success,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseTile(
      BuildContext context, FixedExpenseEntity expense, ThemeData theme) {
    final color = Color(expense.categoryColor);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: expense.isDebtPayment
              ? null
              : () => _showAddEditDialog(context, expense: expense),
          onLongPress: expense.isDebtPayment
              ? null
              : () => _showDeleteDialog(context, expense),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  resolveIcon(expense.categoryIconCodePoint),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: expense.isPaidThisMonth
                            ? TextDecoration.lineThrough
                            : null,
                        color: expense.isPaidThisMonth
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    Text(
                      expense.isDebtPayment
                          ? '${expense.categoryName} · Cuota ${expense.installmentNumber}/${expense.totalInstallments}'
                          : expense.categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currencyFormatter.format(expense.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedCheckButton(
                isChecked: expense.isPaidThisMonth,
                activeColor: theme.appColors.success,
                onChanged: (value) {
                  if (expense.isDebtPayment) {
                    _cubit.toggleDebtPayment(
                      expense.debtPaymentId!,
                      _currentMonth.month,
                      _currentMonth.year,
                      value,
                    );
                  } else {
                    _cubit.togglePayment(
                      expense.id,
                      _currentMonth.month,
                      _currentMonth.year,
                      value,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FixedExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto fijo'),
        content: Text(
            '¿Eliminar "${expense.name}" de tus gastos fijos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteFixedExpense(
                expense.id,
                _currentMonth.month,
                _currentMonth.year,
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context,
      {FixedExpenseEntity? expense}) {
    final isEdit = expense != null;
    final nameController =
        TextEditingController(text: isEdit ? expense.name : '');
    final amountController = TextEditingController(
        text: isEdit ? ThousandSeparatorFormatter.format(expense.amount) : '');
    int? selectedCategoryId = isEdit ? expense.categoryId : null;

    final formCubit = sl<TransactionFormCubit>();
    formCubit.loadCategories(TransactionType.expense);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Editar gasto fijo' : 'Nuevo gasto fijo',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Hipoteca, Internet...',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto mensual',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandSeparatorFormatter()],
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<TransactionFormCubit, TransactionFormState>(
                    bloc: formCubit,
                    builder: (ctx, formState) {
                      if (formState is! TransactionFormReady) {
                        return const SizedBox.shrink();
                      }
                      final categories = formState.categories;
                      return DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        c.iconData,
                                        color: c.displayColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(c.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setSheetState(() => selectedCategoryId = v);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final amount =
                          ThousandSeparatorFormatter.parse(amountController.text.trim());
                      if (name.isEmpty ||
                          amount == null ||
                          selectedCategoryId == null) {
                        return;
                      }
                      Navigator.pop(ctx);
                      if (isEdit) {
                        _cubit.updateFixedExpense(
                          id: expense.id,
                          name: name,
                          amount: amount,
                          categoryId: selectedCategoryId!,
                          currentMonth: _currentMonth.month,
                          currentYear: _currentMonth.year,
                        );
                      } else {
                        _cubit.createFixedExpense(
                          name: name,
                          amount: amount,
                          categoryId: selectedCategoryId!,
                          currentMonth: _currentMonth.month,
                          currentYear: _currentMonth.year,
                        );
                      }
                    },
                    child: Text(isEdit ? 'Guardar' : 'Agregar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => formCubit.close());
  }
}
