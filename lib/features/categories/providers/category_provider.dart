import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [
    CategoryModel(
      id: "1",
      name: "Food",
      icon: "fastfood",
      color: 0xFFFF9800,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "2",
      name: "Travel",
      icon: "directions_car",
      color: 0xFF2196F3,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "3",
      name: "Bills",
      icon: "receipt",
      color: 0xFFE91E63,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: "4",
      name: "Shopping",
      icon: "shopping_cart",
      color: 0xFF9C27B0,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get('/categories');
      if (data is List && data.isNotEmpty) {
        _categories = data.map<CategoryModel>((json) {
          return CategoryModel(
            id: json['category_id'].toString(),
            name: json['category_name'] ?? '',
            icon: json['icon'] ?? 'category',
            color: 0xFF00C897,
            isDefault: json['user_id'] == null,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();

    ApiService.post('/categories', {
      'category_name': category.name,
      'icon': category.icon,
    }).catchError((e) => debugPrint('Error adding category: $e'));
  }

  void updateCategory(CategoryModel category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}