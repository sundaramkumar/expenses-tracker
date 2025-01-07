class Category {
  final int categoryId;
  final String categoryName;

  Category({
    required this.categoryId,
    required this.categoryName,
  });

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
      );

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
