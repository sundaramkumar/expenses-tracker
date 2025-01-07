class Subcategory {
  final int subCategoryId;
  final String subCategoryName;
  final int categoryId;

  Subcategory({
    required this.subCategoryId,
    required this.subCategoryName,
    required this.categoryId,
  });

  factory Subcategory.fromMap(Map<String, dynamic> json) => Subcategory(
        subCategoryId: json['subCategoryId'],
        categoryId: json['categoryId'],
        subCategoryName: json['subCategoryName'],
      );

  Map<String, dynamic> toMap() {
    return {
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'categoryId': categoryId,
    };
  }
}
