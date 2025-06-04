import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://tcc-end-be-425714712446.us-central1.run.app/api/admin';
  
  // Login Method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Simpan token dan data user ke shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        if (responseData['token'] != null) {
          await prefs.setString('auth_token', responseData['token']);
        }
        if (responseData['user'] != null) {
          await prefs.setString('user_data', json.encode(responseData['user']));
        }

        return {
          'success': true,
          'message': 'Login berhasil',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal. Silakan coba lagi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }

  // Register Method
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registrasi berhasil',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal. Silakan coba lagi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }

  // Logout Method
  static Future<Map<String, dynamic>> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Hapus data dari shared preferences terlepas dari response API
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logout berhasil',
        };
      } else {
        return {
          'success': true, // Tetap success karena data lokal sudah dihapus
          'message': 'Logout berhasil',
        };
      }
    } catch (e) {
      // Tetap hapus data lokal meskipun API error
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    }
  }

  // Get Auth Token
  static Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    String? token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get User Data
  static Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    
    if (userData != null && userData.isNotEmpty) {
      return json.decode(userData);
    }
    return null;
  }

  // Clear All Data
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // ==================== MEMBER CRUD METHODS ====================

  // Get All Members
  static Future<Map<String, dynamic>> getMembers() async {
    try {
      String? token = await getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/member/get'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengambil data member',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }

  // Create Member
  static Future<Map<String, dynamic>> createMember({
    required String nama,
    required String nik,
    required String alamat,
  }) async {
    try {
      String? token = await getAuthToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/member/create'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nama': nama,
          'nik': nik,
          'alamat': alamat,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Member berhasil ditambahkan',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal menambahkan member',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }

  // Update Member
  static Future<Map<String, dynamic>> updateMember({
    required String id,
    required String nama,
    required String nik,
    required String alamat,
  }) async {
    try {
      String? token = await getAuthToken();
      
      final response = await http.put(
        Uri.parse('$baseUrl/member/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nama': nama,
          'nik': nik,
          'alamat': alamat,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Member berhasil diupdate',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengupdate member',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }

  // Delete Member
  static Future<Map<String, dynamic>> deleteMember(String id) async {
    try {
      String? token = await getAuthToken();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/member/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Member berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal menghapus member',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      };
    }
  }
}