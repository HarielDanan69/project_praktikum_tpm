import 'package:flutter/material.dart';
import 'package:project_akhir_tpm/pages/memberpage.dart';
import 'package:project_akhir_tpm/services/member_service.dart';
import 'package:project_akhir_tpm/models/member_model.dart';
//import 'package:project_akhir_tpm/pages/homepage.dart';

class CreateMemberPage extends StatefulWidget {
  const CreateMemberPage({super.key});

  @override
  State<CreateMemberPage> createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  // Controller dipake buat mengelola input teks dari TextField.
  final nama = TextEditingController();
  final nik = TextEditingController();
  final alamat = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Member"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _textField(nama, "Nama"),
            _textField(nik, "NIK"),
            _textField(alamat, "Alamat"),

            const SizedBox(height: 16),
            // Tombol buat submit data baru
            ElevatedButton(
              onPressed: () {
                // Jalankan fungsi _createClothing() ketika tombol diklik
                _createMember(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Member"),
            ),
          ],
        ),
      ),
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
  Future<void> _createMember(BuildContext context) async {
    try {
      // Ngubah jadi tipe data angka

      /*
        Karena kita mau mengedit data, maka kita juga perlu datanya.
        Disini kita mengambil data-data yang dah diisi pada form,
        Terus datanya itu disimpan ke dalam variabel "updatedClothing" dengan tipe data "Clothing".
      */
      Member newMember = Member(
        nama: nama.text.trim(),
        nik: nik.text.trim(),
        alamat: alamat.text.trim(),
      );

      /*
        Lakukan pemanggilan API update, setelah itu
        simpan ke dalam variabel bernama "response"
      */
      final response = await MemberService.addMember(newMember);

      /*
        Jika response status "Success", 
        maka tampilkan snackbar yg bertuliskan "Clothing [nama] updated"
      */
      if (response["status"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Member ${newMember.nama} created")),
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
