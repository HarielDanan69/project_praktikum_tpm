import 'package:hive/hive.dart';
part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String price;

  @HiveField(2)
  final String item_name;

  Item({this.id, required this.price, required this.item_name});
}
