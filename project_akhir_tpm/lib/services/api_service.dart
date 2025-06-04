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
      print('Login response: $responseData'); // Debug log

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Simpan token - berdasarkan struktur response sebenarnya
        String? token;
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          token = responseData['data']['token'];
        } else if (responseData['token'] != null) {
          token = responseData['token'];
        }
        
        if (token != null) {
          await prefs.setString('auth_token', token);
          print('Token saved successfully: ${token.substring(0, 20)}...');
        } else {
          print('Token not found in response!');
        }
        
        // Buat API call kedua untuk mendapatkan data user menggunakan token
        Map<String, dynamic> userData = {};
        
        if (token != null) {
          try {
            final userResponse = await http.get(
              Uri.parse('$baseUrl/admin/login'), 
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            if (userResponse.statusCode == 200) {
              final userResponseData = json.decode(userResponse.body);
              print('User profile response: $userResponseData');
              
              if (userResponseData['data'] != null) {
                userData = userResponseData['data'];
              } else if (userResponseData['user'] != null) {
                userData = userResponseData['user'];
              } else {
                userData = userResponseData;
              }
            }
          } catch (e) {
            print('Error fetching user profile: $e');
          }
        }
        
        // Jika tidak berhasil mendapat data user dari API, buat default
        if (userData.isEmpty) {
          userData = {
            'name': 'Admin', // Default name yang lebih deskriptif
            'email': email,
          };
        }
        
        // Pastikan email ada dalam userData
        if (userData['email'] == null) {
          userData['email'] = email;
        }
        
        await prefs.setString('user_data', json.encode(userData));
        print('User data saved: $userData');

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
      print('Login error: $e');
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      print('Retrieved token: ${token?.substring(0, 20) ?? 'null'}...');
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    String? token = await getAuthToken();
    bool loggedIn = token != null && token.isNotEmpty;
    print('Is logged in: $loggedIn');
    return loggedIn;
  }

  // Get User Data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');
      
      print('Raw user data from SharedPreferences: $userData');
      
      if (userData != null && userData.isNotEmpty) {
        Map<String, dynamic> decodedData = json.decode(userData);
        print('Decoded user data: $decodedData');
        return decodedData;
      }
      
      print('No user data found');
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Clear All Data
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('All data cleared from SharedPreferences');
  }

  // Debug method - untuk melihat semua data yang tersimpan
  static Future<void> debugSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    print('=== SharedPreferences Debug ===');
    for (String key in keys) {
      if (key.contains('auth') || key.contains('user')) {
        String? value = prefs.getString(key);
        print('$key: $value');
      }
    }
    print('=== End Debug ===');
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