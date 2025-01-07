class Subcategory {
  final int id;
  final String name;
  final int categoryId;

  Subcategory({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory Subcategory.fromMap(Map<String, dynamic> json) => new Subcategory(
        id: json['id'],
        name: json['name'],
        categoryId: json['categoryId'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
    };
  }
}
