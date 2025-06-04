import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir_tpm/services/api_service.dart';
import 'package:project_akhir_tpm/models/member.dart';
import 'package:project_akhir_tpm/models/boxes.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late Box<Member> memberBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    memberBox = await Hive.openBox<Member>(HiveBox.member);
    setState(() {
      _isLoading = false;
    });
  }

  // Create - Hanya simpan ke Hive
  Future<void> _createMember() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _MemberFormDialog(),
    );

    if (result != null) {
      final member = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: result['nama']!,
        nik: result['nik']!,
        alamat: result['alamat']!,
      );

      await memberBox.add(member);
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member berhasil ditambahkan'), backgroundColor: Colors.green),
      );
    }
  }

  // Update - API + Hive
  Future<void> _updateMember(Member member, int index) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _MemberFormDialog(
        initialData: {
          'nama': member.nama,
          'nik': member.nik,
          'alamat': member.alamat,
        },
      ),
    );

    if (result != null) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final apiResult = await ApiService.updateMember(
          id: member.id!,
          nama: result['nama']!,
          nik: result['nik']!,
          alamat: result['alamat']!,
        );

        Navigator.of(context).pop(); // Hide loading

        if (apiResult['success']) {
          // Update di Hive juga
          final updatedMember = Member(
            id: member.id,
            nama: result['nama']!,
            nik: result['nik']!,
            alamat: result['alamat']!,
          );
          await memberBox.putAt(index, updatedMember);
          setState(() {});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Member berhasil diupdate'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiResult['message']), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update member'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Delete - API + Hive
  Future<void> _deleteMember(Member member, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Member'),
        content: Text('Yakin ingin menghapus ${member.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final apiResult = await ApiService.deleteMember(member.id!);

        Navigator.of(context).pop(); // Hide loading

        if (apiResult['success']) {
          // Hapus dari Hive juga
          await memberBox.deleteAt(index);
          setState(() {});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Member berhasil dihapus'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiResult['message']), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus member'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Data Member')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Member'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: memberBox.listenable(),
        builder: (context, Box<Member> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data member', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final member = box.getAt(index)!;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      member.nama.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(member.nama),
                  subtitle: Text('NIK: ${member.nik}\nAlamat: ${member.alamat}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _updateMember(member, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMember(member, index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMember,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MemberFormDialog extends StatefulWidget {
  final Map<String, String>? initialData;

  const _MemberFormDialog({this.initialData});

  @override
  _MemberFormDialogState createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _nikController.text = widget.initialData!['nik'] ?? '';
      _alamatController.text = widget.initialData!['alamat'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Tambah Member' : 'Edit Member'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
              validator: (value) => value?.isEmpty == true ? 'Nama harus diisi' : null,
            ),
            TextFormField(
              controller: _nikController,
              decoration: InputDecoration(labelText: 'NIK'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'NIK harus diisi' : null,
            ),
            TextFormField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
              validator: (value) => value?.isEmpty == true ? 'Alamat harus diisi' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'nama': _namaController.text.trim(),
                'nik': _nikController.text.trim(),
                'alamat': _alamatController.text.trim(),
              });
            }
          },
          child: Text(widget.initialData == null ? 'Tambah' : 'Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}