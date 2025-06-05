import 'package:flutter/material.dart';
import 'package:project_akhir_tpm/services/member_service.dart';
import 'package:project_akhir_tpm/models/member_model.dart';
import 'package:project_akhir_tpm/pages/memberpage.dart';
//import 'package:project_akhir_tpm/pages/homepage.dart';

class EditMemberPage extends StatefulWidget {
  final int id;
  const EditMemberPage({super.key, required this.id});

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  // Controller dipake buat mengelola input teks dari TextField.
  final nama = TextEditingController();
  final nik = TextEditingController();
  final alamat = TextEditingController();

  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Member"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _clothingWidget(),
      ),
    );
  }

  Widget _clothingWidget() {
    return FutureBuilder(
      future: MemberService.getMemberById(widget.id),
      builder: (context, snapshot) {
        // Jika error (gagal memanggil API), maka tampilkan teks error
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        }
        // Jika berhasil memanggil API (ada datanya)
        else if (snapshot.hasData) {
          /*
            Jika data belum pernah di-load sama sekali (baru pertama kali),
            maka program akan masuk ke dalam percabangan ini.

            Mengapa perlu dicek? Karena setiap kali layar mengupdate state menggunakan setState(),
            Widget ini akan terus dijalankan berulang-ulang.
            Untuk mencegah pengambilan data berulang-ulang, kita perlu mengecek
            apakah data sudah pernah diambil atau belum.
          */
          if (!_isDataLoaded) {
            // Jika data baru pertama kali di-load, ubah menjadi true
            _isDataLoaded = true;

            /*
              Baris 1:
              Untuk mengambil response dari API, kita bisa mengakses "snapshot.data"
              Nah, snapshot.data tadi itu bentuknya masih berupa Map<String, dynamic>.

              Untuk memudahkan pengolahan data, 
              kita perlu mengonversi data JSON tersebut ke dalam model Dart (Clothing),
              makanya kita pake method Clothing.fromJSON() buat mengonversinya.
              Setelah itu, hasil konversinya disimpan ke dalam variabel bernama "clothing".
              
              Kenapa yg kita simpan "snapshot.data["data"]" bukan "snapshot.data" aja?
              Karena kalau kita lihat di dokumentasi API, bentuk response-nya itu kaya gini:
              {
                "status": ...
                "message": ...
                "data": {
                  "id": 1,
                  "name": "tes",
                  "price": 22000,
                  ...
                },
              }

              Nah, kita itu cuman mau ngambil properti "data" doang, 
              kita gamau ngambil properti "status" dan "message",
              makanya yg kita simpan ke variabel itu response.data["data"]

              Baris 2-4
              Setelah mendapatkan data pakaian yg dipilih,
              masukkan data tadi sebagai nilai default pada tiap-tiap input
            */
            Member member = Member.fromJson(snapshot.data!["data"]);
            nama.text = member.nama!;
            nik.text = member.nik!.toString();
            alamat.text = member.alamat!.toString();
          }

          return _clothingEditForm(context);
        }
        // Jika masih loading, tampilkan loading screen di tengah layar
        else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _clothingEditForm(BuildContext context) {
    return ListView(
      children: [
        _textField(nama, "Nama"),
        _textField(nik, "NIK"),
        _textField(alamat, "Alamat"),

        const SizedBox(height: 16),
        // Tombol buat submit data baru
        ElevatedButton(
          onPressed: () {
            // Jalankan fungsi _createClothing() ketika tombol diklik
            _updateMember(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Update Member"),
        ),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label, // <- Ngasi label
      ),
    );
  }

  // Fungsi untuk mengupdate data ketika tombol "Update Clothing" diklik
  Future<void> _updateMember(BuildContext context) async {
    try {
      // Ngubah jadi tipe data angka

      /*
        Karena kita mau mengedit data, maka kita juga perlu datanya.
        Disini kita mengambil data-data yang dah diisi pada form,
        Terus datanya itu disimpan ke dalam variabel "updatedClothing" dengan tipe data "Clothing".
      */
      Member updatedMember = Member(
        id: widget.id,
        nama: nama.text.trim(),
        nik: nik.text.trim(),
        alamat: alamat.text.trim(),
      );

      /*
        Lakukan pemanggilan API update, setelah itu
        simpan ke dalam variabel bernama "response"
      */
      final response = await MemberService.createMember(updatedMember);

      /*
        Jika response status "Success", 
        maka tampilkan snackbar yg bertuliskan "Clothing [nama] updated"
      */
      if (response["status"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Member ${updatedMember.nama} updated")),
        );

        // Pindah ke halaman sebelumnya
        Navigator.pop(context);

        // Untuk merefresh tampilan (menampilkan data yg telah diedit ke dalam daftar)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MemberPage()),
        );
      } else {
        // Jika response status "Error", maka kode akan dilempar ke bagian catch
        throw Exception(response["message"]);
      }
    } catch (error) {
      // Jika gagal, maka tampilkan snackbar dengan tulisan "Gagal: error-nya apa"
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $error")));
    }
  }
}
