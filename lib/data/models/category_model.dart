enum CategoryType { expense, income }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final String icon;
  final int color;
  final bool isDefault;
  final bool archived;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.archived = false,
  });
}
