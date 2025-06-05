import 'dart:convert'; // <- Untuk melakukan encode dan decode JSON
import 'package:project_akhir_tpm/models/member_model.dart';
import 'package:project_akhir_tpm/services/api_service.dart';

// Supaya dapat mengirimkan HTTP request
import 'package:http/http.dart' as http;

class MemberService {
  // Buat menyimpan URL dari API yg akan digunakan supaya ga perlu nulis ulang tiap mau manggil
  static const url =
      "https://tcc-end-be-425714712446.us-central1.run.app/api/admin/member/";

  /*
    Kalau temen-temen liat di bawah, semua method itu punya return type Future<Map<String, dynamic>>
    Penjelasan:
    - Future<...>: Menandakan bahwa method ini berjalan secara asynchronous
    - Map<String, dynamic>: Return value berupa JSON (key String, value bisa tipe apa saja).
  */

  // Method buat mengambil seluruh data pakaian
  static Future<Map<String, dynamic>> getMember() async {
    String? token = await ApiService.getAuthToken();

    // Mengirim GET request ke url, kemudian disimpan ke dalam variabel "response"
    final response = await http.get(
      Uri.parse("${url}get/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    /*
      Hasil dari get request yg disimpan ke variabel "response" itu menyimpan banyak hal,
      seperti statusCode, contentLength, headers, data, dsb.
      Nah, kita cuma mau nge-return datanya doang. Kita bisa mengakses "data"-nya aja dengan
      mengetikkan "response.data"

      Sebelum kita return, kita perlu mengubah JSON menjadi Map<String, dynamic> agar 
      bisa diproses di Dart. Kita bisa mengubahnya menggunakan fungsi jsonDecode().
    */
    return jsonDecode(response.body);
  }

  // Method buat menambahkan produk baru
  static Future<Map<String, dynamic>> addMember(Member newMember) async {
    String? token = await ApiService.getAuthToken();
    /* 
      Mengirim POST request ke url.
      Ketika kita mengirim POST request, kita membutuhkan request body.
      Selain itu, kita juga perlu memberi tahu jenis dari request body-nya itu.

      Karena kita ingin mengirimkan data berupa teks, 
      maka pada bagian headers: Content-Type kita isi menjadi "application/json"

      Pada bagian request body, kita akan mengisi request body dengan data yang telah diisi tadi.
      Kita bisa memanfaatkan parameter "Clothing newClothing" untuk mengisinya.
      Kita juga perlu mengubahnya ke dalam bentuk JSON supaya bisa dikirimkan ke API.

      Terakhir, hasil dari POST request disimpan ke dalam variabel "response"
    */
    final response = await http.post(
      Uri.parse("${url}create/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newMember),
    );

    /*
      Hasil dari get request yg disimpan ke variabel "response" itu menyimpan banyak hal,
      seperti statusCode, contentLength, headers, data, dsb.
      Nah, kita cuma mau nge-return datanya doang. Kita bisa mengakses "data"-nya aja dengan
      mengetikkan "response.data"

      Sebelum kita return, kita perlu mengubah JSON menjadi Map<String, dynamic> agar 
      bisa diproses di Dart. Kita bisa mengubahnya menggunakan fungsi jsonDecode().
    */
    return jsonDecode(response.body);
  }

  // Method buat mengambil data pakaian secara detail berdasarkan id
  static Future<Map<String, dynamic>> getMemberById(int id) async {
    String? token = await ApiService.getAuthToken();
    // Mengirim GET request ke url, kemudian disimpan ke dalam variabel "response"
    final response = await http.get(
      Uri.parse("${url}get/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // Method buat mengedit data pakaian berdasarkan id
  static Future<Map<String, dynamic>> createMember(Member updatedMember) async {
    String? token = await ApiService.getAuthToken();
    /* 
      Mengirim PUT request ke url.
      Ketika kita mengirim PUT request, kita membutuhkan request body.
      Selain itu, kita juga perlu memberi tahu jenis dari request body-nya itu.

      Karena kita ingin mengirimkan data berupa teks, 
      maka pada bagian headers: Content-Type kita isi menjadi "application/json"

      Pada bagian request body, kita akan mengisi request body dengan data yang kita ubah tadi.
      Kita bisa memanfaatkan parameter "Clothing updatedClothing" untuk mengisinya.
      Kita juga perlu mengubahnya ke dalam bentuk JSON supaya bisa dikirimkan ke API.
      
      Terakhir, hasil dari POST request disimpan ke dalam variabel "response"
    */

    final response = await http.put(
      Uri.parse("${url}update/${updatedMember.id}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedMember),
    );

    /*
      Hasil dari get request yg disimpan ke variabel "response" itu menyimpan banyak hal,
      seperti statusCode, contentLength, headers, data, dsb.
      Nah, kita cuma mau nge-return datanya doang. Kita bisa mengakses "data"-nya aja dengan
      mengetikkan "response.data"

      Sebelum kita return, kita perlu mengubah JSON menjadi Map<String, dynamic> agar 
      bisa diproses di Dart. Kita bisa mengubahnya menggunakan fungsi jsonDecode().
    */
    return jsonDecode(response.body);
  }

  // Method buat menghapus data pakaian berdasarkan id
  static Future<Map<String, dynamic>> deleteMember(int id) async {
    String? token = await ApiService.getAuthToken();
    // Mengirim DELETE request ke url, kemudian disimpan ke dalam variabel "response"
    final response = await http.delete(
      Uri.parse("${url}delete/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    /*
      Hasil dari get request yg disimpan ke variabel "response" itu menyimpan banyak hal,
      seperti statusCode, contentLength, headers, data, dsb.
      Nah, kita cuma mau nge-return datanya doang. Kita bisa mengakses "data"-nya aja dengan
      mengetikkan "response.data"

      Sebelum kita return, kita perlu mengubah JSON menjadi Map<String, dynamic> agar 
      bisa diproses di Dart. Kita bisa mengubahnya menggunakan fungsi jsonDecode().
    */
    return jsonDecode(response.body);
  }
}
