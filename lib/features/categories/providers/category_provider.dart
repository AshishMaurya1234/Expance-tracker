import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: "food",
      name: "Food",
      icon: "food",
      color: 0xFFFF9800,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "travel",
      name: "Travel",
      icon: "travel",
      color: 0xFF2196F3,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "bills",
      name: "Bills",
      icon: "bills",
      color: 0xFFF44336,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "shopping",
      name: "Shopping",
      icon: "shopping",
      color: 0xFF9C27B0,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "health",
      name: "Health",
      icon: "health",
      color: 0xFF4CAF50,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "education",
      name: "Education",
      icon: "education",
      color: 0xFF00BCD4,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "entertainment",
      name: "Entertainment",
      icon: "entertainment",
      color: 0xFFE91E63,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "other",
      name: "Other",
      icon: "other",
      color: 0xFF607D8B,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  List<CategoryModel> get categories =>
      List.unmodifiable(_categories);

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(CategoryModel category) {
    final index = _categories.indexWhere(
          (c) => c.id == category.id,
    );

    if (index == -1) return;

    _categories[index] = category;

    notifyListeners();
  }

  void deleteCategory(String id) {
    final category = _categories.firstWhere(
          (c) => c.id == id,
    );

    if (category.isDefault) return;

    _categories.removeWhere(
          (c) => c.id == id,
    );

    notifyListeners();
  }
}