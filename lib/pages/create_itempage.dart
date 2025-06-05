import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir_tpm/models/boxes.dart';
import 'package:project_akhir_tpm/models/item.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<
        FormState
      >(); // key yang digunakan untuk mengidentifikasi dan mengelola status form di widget Form
  validated() {
    // ini bertujuan untuk memeriksa apakah form yang sudah diisi valid atau tidak, ini akan ngecek semua form, inilah keuntungan pake form key
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // Ini memeriksa apakah form sudah diisi dengan data yang valid (bukan kosong, sesuai aturan validator).
      _onFormSubmit();
      print("form validated");
    } else {
      print("form unvalidated");
      return;
    }
  }

  // variable late ini berfungsi untuk agar bisa mengisi data nanti setelah pengguna ngisi form, jadi sesuai namanya late/terlambat
  late String item_name;
  late String price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Item"), centerTitle: true),
      body: Form(
        // Form adalah widget yang berfungsi untuk mengelompokkan beberapa TextFormField dan memungkinkan melakukan validasi terhadap keseluruhan form. Kalau nggak pakai Form,  perlu validasi dan kontrol tiap field secara manual, yang lebih ribet.
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) {
                  item_name = value;
                },
                decoration: InputDecoration(labelText: "Nama Produk"),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Required";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                keyboardType: TextInputType.numberWithOptions(),
                onChanged: (value) {
                  price = value;
                },
                decoration: InputDecoration(labelText: "Harga"),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Required";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  validated();
                },
                child: Text("Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFormSubmit() {
    Box<Item> itemBox = Hive.box<Item>(HiveBox.item);
    itemBox.add(Item(item_name: item_name, price: price));
    Navigator.of(context).pop();
    print(itemBox);
  }
}
