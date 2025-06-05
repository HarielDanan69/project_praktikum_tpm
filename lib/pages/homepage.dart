import 'package:flutter/material.dart';
import 'package:project_akhir_tpm/services/api_service.dart';
import 'loginpage.dart';
import 'package:project_akhir_tpm/pages/memberpage.dart';
import 'itempage.dart';
//import 'presensipage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    try {
      // Debug: Cek apakah user sudah login
      bool isLoggedIn = await ApiService.isLoggedIn();
      print('Is logged in: $isLoggedIn');

      // Debug: Cek token
      String? token = await ApiService.getAuthToken();
      print(
        'Token: ${token?.substring(0, 20)}...',
      ); // Tampilkan sebagian token saja

      // Ambil data user dari SharedPreferences
      Map<String, dynamic>? userData = await ApiService.getUserData();
      print('User data from SharedPreferences: $userData');

      if (userData != null) {
        setState(() {
          // Coba berbagai kemungkinan struktur data
          _userName =
              userData['name'] ??
              userData['username'] ??
              userData['fullName'] ??
              userData['full_name'] ??
              'Admin';

          _userEmail = userData['email'] ?? userData['email_address'] ?? '';
        });

        print('Final userName: $_userName');
        print('Final userEmail: $_userEmail');
      } else {
        print('userData is null');
        setState(() {
          _userName = '';
          _userEmail = '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'Admin';
        _userEmail = '';
      });
    }
  }

  _logout() async {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (ctx) => Center(child: CircularProgressIndicator()),
                  );

                  // Call logout API
                  await ApiService.logout();

                  // Hide loading
                  Navigator.of(context).pop();

                  // Arahkan ke login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Fungsi untuk navigasi ke halaman lain
  void _navigateToPage(String pageName) {
    // Navigator.of(context).pop(); // Tutup drawer

    // Navigasi berdasarkan nama halaman
    switch (pageName) {
      case 'Member':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemberPage()),
        );
        break;
      case 'Item':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemPage()),
        );
        break;
      // case 'Presensi':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => PresensiPage()),
      //   );
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserData, // Tombol refresh untuk debug
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header - Simplified
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items - Simplified
            ListTile(
              leading: Icon(Icons.home, color: Colors.grey[700]),
              title: Text('Home'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.grey[700]),
              title: Text('Member'),
              onTap: () => _navigateToPage('Member'),
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Colors.grey[700]),
              title: Text('Item'),
              onTap: () => _navigateToPage('Item'),
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.grey[700]),
              title: Text('Presensi'),
              onTap: () => _navigateToPage('Presensi'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_userEmail.isNotEmpty && _userEmail != 'Loading...')
                      Text(
                        _userEmail,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                  ],
                ),
              ),

              // Menu Grid
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          children: [
                            _buildMenuCard(
                              icon: Icons.people,
                              title: 'Member',
                              color: Colors.blue,
                              onTap: () => _navigateToPage('Member'),
                            ),
                            _buildMenuCard(
                              icon: Icons.inventory,
                              title: 'Item',
                              color: Colors.green,
                              onTap: () => _navigateToPage('Item'),
                            ),
                            _buildMenuCard(
                              icon: Icons.assignment,
                              title: 'Presensi',
                              color: Colors.orange,
                              onTap: () => _navigateToPage('Presensi'),
                            ),
                            _buildMenuCard(
                              icon: Icons.settings,
                              title: 'Settings',
                              color: Colors.grey,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Settings coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
