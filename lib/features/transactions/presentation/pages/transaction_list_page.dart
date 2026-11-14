import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/painters/wave_painter.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../cubit/transaction_list_cubit.dart';
import '../cubit/transaction_list_state.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TransactionListCubit _cubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _cubit = sl<TransactionListCubit>();
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
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final headerPrimary = isDark
        ? scheme.primary.withAlpha(60)
        : scheme.primary;
    final headerSecondary = isDark
        ? scheme.primary.withAlpha(35)
        : scheme.primary.withAlpha(180);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'txn_fab',
        onPressed: () => context.pushNamed('addTransaction'),
        child: Icon(PhosphorIconsBold.plus),
      ),
      body: CustomScrollView(
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
                          'Transacciones',
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
          BlocBuilder<TransactionListCubit, TransactionListState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state is TransactionListLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is TransactionListError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.message}')),
                );
              }
              if (state is TransactionListLoaded) {
                final transactions = state.transactions;
                if (transactions.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withAlpha(80),
                              shape: BoxShape.circle,
                            ),
                            child: PhosphorIcon(
                              PhosphorIconsDuotone.receipt,
                              size: 36,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin movimientos este mes',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Registra tus gastos e ingresos\npara llevar el control',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () =>
                                context.pushNamed('addTransaction'),
                            icon: Icon(PhosphorIconsBold.plus, size: 18),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = transactions[index];
                        return TransactionTile(
                          transaction: t,
                          currencyFormatter: _currencyFormatter,
                          onTap: () => context.pushNamed(
                            'addTransaction',
                            extra: t,
                          ),
                          onPaidChanged: (val) async {
                            if (val == null) return;
                            final repo = sl<TransactionRepository>();
                            await repo.togglePaid(t.id, val);
                          },
                          onDismissed: () async {
                            final repo = sl<TransactionRepository>();
                            await repo.delete(t.id);
                          },
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}
