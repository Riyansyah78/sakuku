import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_utils.dart';
import '../../data/models/category_model.dart';
import '../../data/providers/finance_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, CategoryType type) {
    final nameController = TextEditingController();
    String selectedIcon = type == CategoryType.expense
        ? 'restaurant'
        : 'payments';
    int selectedColor = AppColors.calmPalette.first;

    final icons = [
      'restaurant',
      'directions_car',
      'shopping_bag',
      'home',
      'movie',
      'medical_services',
      'school',
      'sports_esports',
      'payments',
      'work',
      'savings',
      'card_giftcard',
    ];
    final colors = AppColors.calmPalette;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(
                'Tambah Kategori ${type == CategoryType.expense ? "Pengeluaran" : "Pemasukan"}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Ikon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((ic) {
                        final isSel = selectedIcon == ic;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = ic),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? Theme.of(ctx).colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Icon(IconUtils.resolveIcon(ic), size: 20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Warna',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((col) {
                        final isSel = selectedColor == col;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = col),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(col),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final repo = ref.read(financeRepositoryProvider);
                    final newCat = CategoryModel(
                      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      type: type,
                      icon: selectedIcon,
                      color: selectedColor,
                      isDefault: false,
                    );
                    await repo.addCategory(newCat);
                    ref.invalidate(categoriesListProvider(type));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Kelola Kategori',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? CategoryType.expense
              : CategoryType.income;
          _showAddCategoryDialog(context, type);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(CategoryType.expense),
          _buildCategoryList(CategoryType.income),
        ],
      ),
    );
  }

  Widget _buildCategoryList(CategoryType type) {
    final categoriesAsync = ref.watch(categoriesListProvider(type));

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('Tidak ada kategori.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),

          itemBuilder: (context, index) {
            final cat = categories[index];
            final iconData = IconUtils.resolveIcon(cat.icon);
            final color = Color(cat.color);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (cat.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Bawaan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.archive_outlined,
                        size: 20,
                        color: AppColors.expenseText,
                      ),
                      onPressed: () async {
                        final repo = ref.read(financeRepositoryProvider);
                        await repo.archiveCategory(cat.id);
                        ref.invalidate(categoriesListProvider(type));
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
