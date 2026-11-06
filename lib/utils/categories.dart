import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  const ExpenseCategory(this.name, this.icon);
}

class Categories {
  static const List<ExpenseCategory> all = [
    ExpenseCategory('Ăn uống', Icons.restaurant),
    ExpenseCategory('Đi lại', Icons.directions_bus),
    ExpenseCategory('Nhà ở', Icons.home),
    ExpenseCategory('Điện nước', Icons.bolt),
    ExpenseCategory('Giải trí', Icons.movie),
    ExpenseCategory('Học tập', Icons.school),
    ExpenseCategory('Khác', Icons.more_horiz),
  ];
}
