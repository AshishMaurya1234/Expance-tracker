import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  static const List<String> iconOptions = [
    "food",
    "travel",
    "bills",
    "shopping",
    "health",
    "education",
    "entertainment",
    "other",
    "gaming",
    "pets",
    "fitness",
    "gift",
    "rent",
    "fuel",
    "salary",
    "family",
  ];

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCategoryDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(category.color).withValues(alpha: 0.15),
                child: Icon(
                  _iconFromKey(category.icon),
                  color: Color(category.color),
                ),
              ),
              title: Text(category.name),
              subtitle: Text(
                category.isDefault ? "Default category" : "Custom category",
              ),
              trailing: category.isDefault
                  ? const Icon(Icons.lock_outline)
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _showCategoryDialog(
                        context,
                        category: category,
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _confirmDelete(context, category);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void _showCategoryDialog(
      BuildContext context, {
        CategoryModel? category,
      }) {
    final nameController = TextEditingController(
      text: category?.name ?? "",
    );

    String selectedIcon = category?.icon ?? "other";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                category == null ? "Add Category" : "Edit Category",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: const InputDecoration(
                      labelText: "Icon",
                    ),
                    items: iconOptions.map((icon) {
                      return DropdownMenuItem(
                        value: icon,
                        child: Row(
                          children: [
                            Icon(_iconFromKey(icon)),
                            const SizedBox(width: 10),
                            Text(icon),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedIcon = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category name is required"),
                        ),
                      );
                      return;
                    }

                    final provider = context.read<CategoryProvider>();

                    if (category == null) {
                      provider.addCategory(
                        CategoryModel(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: name,
                          icon: selectedIcon,
                          color: _colorFromIcon(selectedIcon),
                          isDefault: false,
                          createdAt: DateTime.now(),
                        ),
                      );
                    } else {
                      provider.updateCategory(
                        category.copyWith(
                          name: name,
                          icon: selectedIcon,
                          color: _colorFromIcon(selectedIcon),
                        ),
                      );
                    }

                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    category == null ? "Save" : "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _confirmDelete(
      BuildContext context,
      CategoryModel category,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Category?"),
          content: Text(
            "${category.name} will be permanently deleted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                context.read<CategoryProvider>().deleteCategory(category.id);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Category deleted"),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  static IconData _iconFromKey(String icon) {
    switch (icon) {
      case "food":
        return Icons.restaurant;
      case "travel":
        return Icons.directions_car;
      case "bills":
        return Icons.receipt_long;
      case "shopping":
        return Icons.shopping_bag;
      case "health":
        return Icons.health_and_safety;
      case "education":
        return Icons.school;
      case "entertainment":
        return Icons.movie;
      case "gaming":
        return Icons.sports_esports;
      case "pets":
        return Icons.pets;
      case "fitness":
        return Icons.fitness_center;
      case "gift":
        return Icons.card_giftcard;
      case "rent":
        return Icons.home;
      case "fuel":
        return Icons.local_gas_station;
      case "salary":
        return Icons.payments;
      case "family":
        return Icons.family_restroom;
      default:
        return Icons.category;
    }
  }

  static int _colorFromIcon(String icon) {
    switch (icon) {
      case "food":
        return 0xFFFF9800;
      case "travel":
        return 0xFF2196F3;
      case "bills":
        return 0xFFF44336;
      case "shopping":
        return 0xFF9C27B0;
      case "health":
        return 0xFF4CAF50;
      case "education":
        return 0xFF00BCD4;
      case "entertainment":
        return 0xFFE91E63;
      case "gaming":
        return 0xFF673AB7;
      case "pets":
        return 0xFF795548;
      case "fitness":
        return 0xFF009688;
      case "gift":
        return 0xFFFF5722;
      case "rent":
        return 0xFF3F51B5;
      case "fuel":
        return 0xFFFFC107;
      case "salary":
        return 0xFF22C55E;
      case "family":
        return 0xFF607D8B;
      default:
        return 0xFF9E9E9E;
    }
  }
}