import 'package:flutter/material.dart';
import 'package:project_akhir_tpm/pages/create_memberpage.dart';
//import 'package:project_akhir_tpm/services/api_service.dart';
import 'package:project_akhir_tpm/services/member_service.dart';
import 'package:project_akhir_tpm/models/member_model.dart';
import 'package:project_akhir_tpm/pages/edit_memberpage.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Halaman Member"),
        ),
        body: Padding(padding: EdgeInsets.all(20), child: _membersContainer()),
      ),
    );
  }

  Widget _membersContainer() {
    /*
      FutureBuilder adalah widget yang membantu menangani proses asynchronous
      Proses async adalah proses yang membutuhkan waktu. (ex: mengambil data dari API)

      FutureBuilder itu butuh 2 properti, yaitu future dan builder.
      Properti future adalah proses async yg akan dilakukan.
      Properti builder itu tampilan yg akan ditampilkan berdasarkan proses future tadi.
      
      Properti builder itu pada umumnya ada 2 status, yaitu hasError dan hasData.
      Status hasError digunakan untuk mengecek apakah terjadi kesalahan (misal: jaringan error).
      Status hasData digunakan untuk mengecek apakah data sudah siap.
    */
    return FutureBuilder(
      future: MemberService.getMember(),
      builder: (context, snapshot) {
        // Jika error (gagal memanggil API), maka tampilkan teks error
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        }
        // Jika berhasil memanggil API
        else if (snapshot.hasData) {
          /*
            Baris 1:
            Untuk mengambil response dari API, kita bisa mengakses "snapshot.data"
            Nah, snapshot.data tadi itu bentuknya masih berupa Map<String, dynamic>.

            Untuk memudahkan pengolahan data, 
            kita perlu mengonversi data JSON tersebut ke dalam 
            model Dart (ClothingModel) untuk memudahkan pengolahan data.
            Setelah itu, hasil konversinya disimpan ke dalam variabel bernama "response".

            Baris 2:
            Setelah dikonversi, tampilkan data tadi di widget bernama "_clothingList()"
            dengan mengirimkan data tadi sebagai parameternya.

            Kenapa yg dikirim "response.data" bukan "response" aja?
            Karena kalau kita lihat di dokumentasi API, bentuk response-nya itu kaya gini:
            {
              "status": ...
              "message": ...
              "data": [
                {
                  "id": 1,
                  "name": "rafli",
                  "price": 12000,
                  ...
                },
                ...
              ]
            }

            Nah, kita itu cuman mau ngambil properti "data" doang, 
            kita gamau ngambil properti "status" dan "message",
            makanya yg kita kirim ke Widget _clothingList itu response.data
          */
          MemberModel response = MemberModel.fromJson(snapshot.data!);
          return _memberList(context, response.data!);
        }
        // Jika masih loading, tampilkan loading screen di tengah layar
        else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _memberList(BuildContext context, List<Member> members) {
    return ListView(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => CreateMemberPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text("Add Member"),
        ),
        // Tombol add clothes
        SizedBox(height: 16),

        // Tampilkan tiap-tiap data pakaian dengan melakukan perulangan pada variabel "clothes".
        // Simpan data tiap pakaian ke dalam variabel "clothing"
        for (var member in members)
          Container(
            margin: EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () {
                /*
                  Pindah ke halaman DetailPage() (detail_page.dart)
                  Karena kita mau menampilkan detail pakaian yg dipilih berdasarkan id-nya, 
                  maka beri parameter berupa id yg dipilih
                */
              },
              child: Container(
                // Untuk keperluan tampilan doang (opsional)
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ), // <- Ngasih Padding
                // Ngasi border
                decoration: BoxDecoration(
                  border: Border.all(width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                // Nampilin datanya dalam bentuk layout kolom (ke bawah)
                child: Column(
                  // Cross Axis Alignment "Stretch" berfungsi supaya teks menjadi rata kiri
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tampilkan nama, email, gender dalam bentuk teks
                    Text(
                      member.nama!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(member.nik!),
                    Text(member.alamat!),

                    SizedBox(height: 4),
                    Row(children: [
                       
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ), // <- Beri jarak buat tombol di bawah
                    /*
                      Supaya tombol edit, delete, dan detail itu tidak ke bawah
                      melainkan menyamping, maka gunakan layout Row
                    */
                    Row(
                      spacing: 8, // <- Beri jarak antar widget sebanyak 8dp
                      children: [
                        // Tombol edit
                        IconButton(
                          onPressed: () {
                            /*
                              Pindah ke halaman EdiPage() (edit_page.dart)
                              Karena kita mau mengubah data yg dipilih berdasarkan id-nya, 
                              maka beri parameter berupa id yg dipilih
                            */
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        EditMemberPage(id: member.id!),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                        // Tombol delete
                        IconButton(
                          onPressed: () {
                            /*
                              Karena kita mau menghapus berdasarkan id-nya, maka
                              jalankan fungsi _delete() dengan memberi
                              parameter berupa id yg dipilih
                            */
                            _delete(member.id!);
                          },
                          color: Colors.red,
                          icon: Icon(Icons.delete),
                        ),
                        // Tombol detail
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _delete(int id) async {
    try {
      /*
        Lakukan pemanggilan API delete, setelah itu
        simpan ke dalam variabel bernama "response"
      */
      final response = await MemberService.deleteMember(id);

      /*
        Jika response status "Success", 
        maka tampilkan snackbar yg bertuliskan "Clothes Removed"
      */
      if (response["status"] == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Member Removed")));

        // Refresh tampilan (Supaya data yg dihapus ilang dari layar)
        setState(() {});
      } else {
        // Jika response status "Error", maka kode akan dilempar ke bagian catch
        throw Exception(response["message"]);
      }
    } catch (error) {
      /*
        Jika data gagal dihapus, 
        maka tampilkan snackbar dengan tulisan "Gagal: error-nya apa"
      */
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $error")));
    }
  }
}
