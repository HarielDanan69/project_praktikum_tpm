import 'package:hive/hive.dart';
part 'presensi.g.dart';

@HiveType(typeId: 2)
class Presensi extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String tgl;

  @HiveField(2)
  final String kehadiran;

  Presensi({
    this.id,
    required this.tgl,
    required this.kehadiran,
  });
}