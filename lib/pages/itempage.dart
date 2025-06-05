import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:project_akhir_tpm/models/boxes.dart';
import 'package:project_akhir_tpm/models/item.dart';
import 'package:project_akhir_tpm/pages/create_itempage.dart';
import 'package:project_akhir_tpm/pages/edit_itempage.dart';
import 'package:project_akhir_tpm/services/currency_format.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  // digunakan untuk menonaktifkan hive (tutup koneksi ke database) yang masih aktif saat widget udah nonaktif / pindah ke screen lain, untuk menghindari memory leak,dll
  // @override
  // void dispose() {
  //   Hive.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Item List"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ValueListenableBuilder(
          // widget yang mendengarkan perubahan data "value listenable", dimana kasusnya adalah Hive/db Todo, fungsinya agar data di listview selalu up to date tanpa harus memanggil set state.
          valueListenable: Hive.box<Item>(HiveBox.item).listenable(),
          builder: (context, Box<Item> box, _) {
            if (box.values.isEmpty) {
              return Center(child: Text("Item List is empty"));
            }
            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                Item? result = box.getAt(
                  index,
                ); // mengambil data dari box berdasarkan index/urutannya
                return Dismissible(
                  key:
                      UniqueKey(), // generate key yang unik dari bawaan funct flutter, Biar saat widget dihapus dari list, Flutter tahu persis widget mana yang dihapus
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      result.delete();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Item Deleted")));
                    }
                  },

                  background: Container(color: Colors.red),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditItemPage(
                                index: index,
                                data: result,
                                itemController: result.item_name,
                                priceController: result.price,
                              ),
                        ),
                      );
                    },
                    title: Text(result!.item_name),
                    subtitle: Text(
                      CurrencyFormat.convertToIdr(int.parse(result.price), 2),
                      //result.price,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: "Add Item",
        onPressed:
            () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateItemPage()),
              ),
            },
        child: Icon(Icons.add),
      ),
    );
  }
}
