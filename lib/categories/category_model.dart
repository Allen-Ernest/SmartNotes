class CategoryModel {
  String categoryId;
  String categoryTitle;
  String categoryColor;
  int categoryIcon;
  String fontFamily;

  CategoryModel(
      {required this.categoryId,
      required this.categoryTitle,
      required this.categoryColor,
      required this.categoryIcon,
      required this.fontFamily});

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryTitle': categoryTitle,
        'categoryColor': categoryColor,
        'categoryIcon': categoryIcon,
        'fontFamily': fontFamily
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
      categoryId: json['categoryId'],
      categoryTitle: json['categoryTitle'],
      categoryColor: json['categoryColor'],
      categoryIcon: json['categoryIcon'],
      fontFamily: json['fontFamily']);
}
