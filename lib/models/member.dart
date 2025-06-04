import 'package:hive/hive.dart';
part 'member.g.dart';

@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String nama;

  @HiveField(2)
  final String nik;

  @HiveField(3)
  final String alamat;


  Member({
    this.id,
    required this.nama,
    required this.nik,
    required this.alamat,
  });
}