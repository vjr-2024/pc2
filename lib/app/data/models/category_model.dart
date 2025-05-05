// class CategoryModel {
//   final String id;
//   final String name;
//   final String image;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.image,
//   });

//   factory CategoryModel.fromFirestore(String id, Map<String, dynamic> data) {
//     return CategoryModel(
//       id: id,
//       name: data['name'] ?? 'Unnamed',
//       image: data['image'] ?? '',
//     );
//   }
// }
//
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
