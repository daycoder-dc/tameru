import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/icon_registry.dart';
import '../../../../shared/painters/wave_painter.dart';
import '../../../../shared/widgets/animated_check_button.dart';
import '../../../transactions/presentation/cubit/transaction_form_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_form_state.dart';
import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';

class DebtDetailPage extends StatefulWidget {
  final int debtId;

  const DebtDetailPage({super.key, required this.debtId});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  late final DebtsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DebtsCubit>();
    _cubit.loadDebtDetail(widget.debtId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final scheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(
      locale: 'es',
      symbol: '\$',
      decimalDigits: 0,
    );
    final monthFormat = DateFormat('MMM yyyy', 'es');

    final isDark = theme.brightness == Brightness.dark;
    final headerPrimary = isDark
        ? scheme.primary.withAlpha(60)
        : scheme.primary;
    final headerSecondary = isDark
        ? scheme.primary.withAlpha(35)
        : scheme.primary.withAlpha(180);

    return Scaffold(
      body: BlocBuilder<DebtsCubit, DebtsState>(
        bloc: _cubit,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: WaveHeaderPainter(
                        color: headerPrimary,
                        secondaryColor: headerSecondary,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: TopographyPainter(
                        lineColor: Colors.white.withAlpha(isDark ? 12 : 25),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_rounded,
                                  color: isDark ? scheme.onSurface : Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                'Detalle del credito',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? scheme.onSurface : Colors.white,
                                ),
                              ),
                            ),
                            if (state is DebtDetailLoaded)
                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    color: isDark ? scheme.onSurface : Colors.white),
                                onPressed: () => _showEditSheet(context, state.debt),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state is DebtsLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is DebtsError)
                SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                )
              else if (state is DebtDetailLoaded)
                _buildDebtContent(state, theme, colors, scheme, currencyFormat, monthFormat, isDark)
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDebtContent(
    DebtDetailLoaded state,
    ThemeData theme,
    AppColors colors,
    ColorScheme scheme,
    NumberFormat currencyFormat,
    DateFormat monthFormat,
    bool isDark,
  ) {
    final debt = state.debt;
    final payments = state.payments;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverToBoxAdapter(
        child: Transform.translate(
          offset: const Offset(0, -20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.surfaceContainerHigh
                      : scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          resolveIcon(debt.categoryIconCodePoint),
                          color: Color(debt.categoryColor),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(debt.name,
                              style: theme.textTheme.titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.lg),
                    _InfoRow(
                      label: 'Monto total',
                      value: currencyFormat.format(debt.totalAmount),
                    ),
                    _InfoRow(
                      label: 'Tasa de interes',
                      value: '${debt.interestRate.toStringAsFixed(1)}% anual',
                    ),
                    _InfoRow(
                      label: 'Cuota mensual',
                      value: currencyFormat.format(debt.monthlyPayment),
                    ),
                    _InfoRow(
                      label: 'Total a pagar',
                      value: currencyFormat.format(debt.totalCost),
                    ),
                    _InfoRow(
                      label: 'Intereses totales',
                      value: currencyFormat.format(debt.totalInterest),
                      valueColor: scheme.error,
                    ),
                    const SizedBox(height: Spacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: debt.progress,
                        minHeight: 10,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          debt.progress >= 1.0
                              ? colors.success
                              : colors.income,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      '${debt.paidInstallments}/${debt.totalInstallments} cuotas pagadas  ·  ${(debt.progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Cuotas',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              ...payments.map((p) => _PaymentTile(
                    payment: p,
                    currencyFormat: currencyFormat,
                    monthFormat: monthFormat,
                    onToggle: (isPaid) => _cubit.togglePayment(
                        p.id, isPaid, widget.debtId),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, DebtEntity debt) {
    final nameController = TextEditingController(text: debt.name);
    int? selectedCategoryId = debt.categoryId;

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
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Editar credito',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<TransactionFormCubit, TransactionFormState>(
                    bloc: formCubit,
                    builder: (ctx, formState) {
                      if (formState is! TransactionFormReady) {
                        return const SizedBox.shrink();
                      }
                      return DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: formState.categories
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(c.iconData, color: c.displayColor, size: 20),
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
                      if (name.isEmpty || selectedCategoryId == null) return;
                      Navigator.pop(ctx);
                      _cubit.updateDebt(
                        id: debt.id,
                        name: name,
                        categoryId: selectedCategoryId!,
                      );
                    },
                    child: const Text('Guardar'),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final DebtPaymentEntity payment;
  final NumberFormat currencyFormat;
  final DateFormat monthFormat;
  final ValueChanged<bool> onToggle;

  const _PaymentTile({
    required this.payment,
    required this.currencyFormat,
    required this.monthFormat,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final date = DateTime(payment.year, payment.month);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: AnimatedCheckButton(
          isChecked: payment.isPaid,
          activeColor: colors.success,
          onChanged: onToggle,
        ),
        title: Text(
          '#${payment.installmentNumber}  ·  ${monthFormat.format(date)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: payment.isPaid
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        trailing: Text(
          currencyFormat.format(payment.amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: payment.isPaid
                ? colors.success
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
