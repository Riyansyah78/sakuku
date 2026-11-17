import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/money.dart';
import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/finance_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionDetailModel? initialDetail;

  const AddTransactionScreen({super.key, this.initialDetail});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  late int _amount;
  bool _adjustmentIsIncrease = true;
  String? _categoryId;
  String? _accountId;
  String? _toAccountId; // For transfer
  late DateTime _occurredAt;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final detail = widget.initialDetail;
    if (detail != null) {
      _type = detail.transaction.type;
      _adjustmentIsIncrease = detail.transaction.amount >= 0;
      _amount = detail.transaction.amount.abs();
      _categoryId = detail.transaction.categoryId;
      _accountId = detail.transaction.accountId;
      _toAccountId = detail.transaction.toAccountId;
      _occurredAt = detail.transaction.occurredAt;
      _noteController.text = detail.transaction.note ?? '';
    } else {
      _type = TransactionType.expense;
      _amount = 0;
      _occurredAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) {
    setState(() {
      if (val == 'C') {
        _amount = 0;
      } else if (val == 'backspace') {
        final s = _amount.toString();
        if (s.length <= 1) {
          _amount = 0;
        } else {
          _amount = int.tryParse(s.substring(0, s.length - 1)) ?? 0;
        }
      } else if (val == '000') {
        if (_amount > 0 && _amount <= 9999999) {
          _amount = _amount * 1000;
        }
      } else {
        final s = '$_amount$val';
        final parsed = int.tryParse(s);
        if (parsed != null && parsed <= 9999999999) {
          _amount = parsed;
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt.isAfter(now) ? now : _occurredAt,
      firstDate: DateTime(2020),
      lastDate: now, // Business rule #3: no future dates
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _occurredAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _occurredAt.hour,
          _occurredAt.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked != null) {
      setState(() {
        _occurredAt = DateTime(
          _occurredAt.year,
          _occurredAt.month,
          _occurredAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (_amount <= 0) return;
    if (_type != TransactionType.transfer &&
        _type != TransactionType.adjustment &&
        _categoryId == null) {
      return;
    }
    if (_accountId == null) return;
    if (_type == TransactionType.transfer &&
        (_toAccountId == null || _toAccountId == _accountId))
      return;

    final repo = ref.read(financeRepositoryProvider);
    final now = DateTime.now();

    if (widget.initialDetail != null) {
      final tx = TransactionModel(
        id: widget.initialDetail!.transaction.id,
        type: _type,
        amount: _type == TransactionType.adjustment
            ? _amount * (_adjustmentIsIncrease ? 1 : -1)
            : _amount,
        categoryId: _type == TransactionType.transfer ||
                _type == TransactionType.adjustment
            ? null
            : _categoryId,
        accountId: _accountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        occurredAt: _occurredAt,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: widget.initialDetail!.transaction.createdAt,
        updatedAt: now,
      );
      await repo.updateTransaction(tx);
    } else {
      final tx = TransactionModel(
        id: 'tx_${now.millisecondsSinceEpoch}',
        type: _type,
        amount: _type == TransactionType.adjustment
            ? _amount * (_adjustmentIsIncrease ? 1 : -1)
            : _amount,
        categoryId: _type == TransactionType.transfer ||
                _type == TransactionType.adjustment
            ? null
            : _categoryId,
        accountId: _accountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        occurredAt: _occurredAt,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await repo.addTransaction(tx);
    }

    // Refresh providers
    ref.invalidate(homeDashboardProvider);
    ref.invalidate(filteredTransactionsProvider);
    ref.invalidate(accountsWithBalanceProvider);
    ref.invalidate(reportsDataProvider);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialDetail != null
                ? 'Transaksi diperbarui'
                : 'Transaksi disimpan',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expenseText,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.initialDetail != null) {
      final repo = ref.read(financeRepositoryProvider);
      final deletedTx = widget.initialDetail!.transaction;
      await repo.deleteTransaction(deletedTx.id);

      ref.invalidate(homeDashboardProvider);
      ref.invalidate(filteredTransactionsProvider);
      ref.invalidate(accountsWithBalanceProvider);
      ref.invalidate(reportsDataProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaksi dihapus'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Urungkan',
              onPressed: () async {
                await repo.addTransaction(deletedTx);
                ref.invalidate(homeDashboardProvider);
                ref.invalidate(filteredTransactionsProvider);
                ref.invalidate(accountsWithBalanceProvider);
                ref.invalidate(reportsDataProvider);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final categoryType = _type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final categoriesAsync = ref.watch(categoriesListProvider(categoryType));

    // Ensure default account selected
    accountsAsync.whenData((accounts) {
      if (_accountId == null && accounts.isNotEmpty) {
        setState(() {
          _accountId = accounts.first.account.id;
        });
      }
    });

    final isValid =
        _amount > 0 &&
        (_type == TransactionType.transfer
            ? (_accountId != null &&
                  _toAccountId != null &&
                  _accountId != _toAccountId)
            : _type == TransactionType.adjustment
            ? _accountId != null
            : (_categoryId != null && _accountId != null));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.initialDetail != null ? 'Ubah Transaksi' : 'Tambah Transaksi',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.initialDetail != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.expenseText,
              ),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Segmented Type Selector (hide for adjustment edits)
                    if (_type != TransactionType.adjustment) ...[
                      _buildTypeToggle(),
                      const SizedBox(height: 20),
                    ],

                    // Adjustment direction toggle
                    if (_type == TransactionType.adjustment) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Tambah Saldo'),
                              selected: _adjustmentIsIncrease,
                              onSelected: (_) => setState(() =>
                                  _adjustmentIsIncrease = true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Kurangi Saldo'),
                              selected: !_adjustmentIsIncrease,
                              onSelected: (_) => setState(() =>
                                  _adjustmentIsIncrease = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Amount Display
                    _buildAmountDisplay(),
                    const SizedBox(height: 24),

                    // Categories Selector (only for expense/income)
                    if (_type != TransactionType.transfer &&
                        _type != TransactionType.adjustment) ...[
                      Text(
                        'Kategori',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryGrid(categoriesAsync),
                      const SizedBox(height: 20),
                    ],

                    // Accounts Selection Row
                    if (_type == TransactionType.transfer) ...[
                      _buildTransferAccountsRow(accountsAsync),
                      const SizedBox(height: 16),
                    ] else ...[
                      _buildAccountSelectorRow(accountsAsync),
                      const SizedBox(height: 16),
                    ],

                    // Date Picker Row
                    _buildDateSelectorRow(),
                    const SizedBox(height: 16),

                    // Note Input
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Catatan (opsional)',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Custom Keypad + Save Button docked at bottom
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKeypad(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isValid
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isValid ? _save : null,
                      child: Text(
                        widget.initialDetail != null
                            ? 'Simpan Perubahan'
                            : 'Simpan Transaksi',
                        style: TextStyle(
                          color: isValid
                              ? Colors.white
                              : Theme.of(context).colorScheme.outline,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            title: 'Pengeluaran',
            active: _type == TransactionType.expense,
            activeColor: AppColors.expenseText,
            onTap: () {
              if (_type != TransactionType.expense) {
                setState(() {
                  _type = TransactionType.expense;
                  _categoryId = null;
                });
              }
            },
          ),
          _buildToggleOption(
            title: 'Pemasukan',
            active: _type == TransactionType.income,
            activeColor: AppColors.incomeText,
            onTap: () {
              if (_type != TransactionType.income) {
                setState(() {
                  _type = TransactionType.income;
                  _categoryId = null;
                });
              }
            },
          ),
          _buildToggleOption(
            title: 'Transfer',
            active: _type == TransactionType.transfer,
            activeColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              if (_type != TransactionType.transfer) {
                setState(() {
                  _type = TransactionType.transfer;
                  _categoryId = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active
                  ? activeColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    final formatted = MoneyUtils.format(_amount).replaceFirst('Rp ', '');
    final color = _type == TransactionType.income
        ? AppColors.incomeText
        : _type == TransactionType.expense
        ? AppColors.expenseText
        : Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatted,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (categories) {
        if (categories.isEmpty) {
          return const Text('Tidak ada kategori.');
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, i) {
            final cat = categories[i];
            final isSelected = _categoryId == cat.id;
            final iconData = IconUtils.resolveIcon(cat.icon);

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _categoryId = cat.id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 19,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Color(cat.color),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccountSelectorRow(
    AsyncValue<List<AccountWithBalanceModel>> accountsAsync,
  ) {
    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _accountId,
              isExpanded: true,
              hint: const Text('Pilih Dompet'),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              items: accounts.map((a) {
                return DropdownMenuItem<String>(
                  value: a.account.id,
                  child: Row(
                    children: [
                      Icon(
                        IconUtils.resolveIcon(a.account.icon),
                        size: 20,
                        color: Color(a.account.color),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        a.account.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        MoneyUtils.format(a.currentBalance),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _accountId = val);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransferAccountsRow(
    AsyncValue<List<AccountWithBalanceModel>> accountsAsync,
  ) {
    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        return Column(
          children: [
            // Dari Dompet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _accountId,
                  isExpanded: true,
                  hint: const Text('Dari Dompet'),
                  items: accounts.map((a) {
                    return DropdownMenuItem<String>(
                      value: a.account.id,
                      child: Text(
                        'Dari: ${a.account.name} (${MoneyUtils.format(a.currentBalance)})',
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _accountId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Ke Dompet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _toAccountId,
                  isExpanded: true,
                  hint: const Text('Ke Dompet'),
                  items: accounts.map((a) {
                    return DropdownMenuItem<String>(
                      value: a.account.id,
                      child: Text(
                        'Ke: ${a.account.name} (${MoneyUtils.format(a.currentBalance)})',
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _toAccountId = val);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelectorRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateUtilsId.formatFull(_occurredAt),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: _pickTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateUtilsId.formatTime(_occurredAt),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['000', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _onKeyPress(k),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: k == 'backspace'
                          ? const Icon(Icons.backspace_outlined, size: 20)
                          : Text(
                              k,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
