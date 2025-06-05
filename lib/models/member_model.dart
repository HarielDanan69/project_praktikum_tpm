class MemberModel {
  int? status;
  String? message;
  List<Member>? data;

  MemberModel({this.status, this.message, this.data});

  MemberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Member>[];
      json['data'].forEach((v) {
        data!.add(new Member.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Member {
  int? id;
  String? nama;
  String? nik;
  String? alamat;
  String? createdAt;
  String? updatedAt;

  Member({
    this.id,
    this.nama,
    this.nik,
    this.alamat,
    this.createdAt,
    this.updatedAt,
  });

  Member.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    nik = json['nik'];
    alamat = json['alamat'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['nik'] = this.nik;
    data['alamat'] = this.alamat;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
