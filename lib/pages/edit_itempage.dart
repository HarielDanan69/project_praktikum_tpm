// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir_tpm/models/boxes.dart';
import 'package:project_akhir_tpm/models/item.dart';
//import 'package:project_akhir_tpm/pages/homepage.dart';

class EditItemPage extends StatefulWidget {
  final int index;
  final Item? data;
  final itemController;
  final priceController;

  const EditItemPage({
    super.key,
    required this.index,
    this.data,
    this.itemController,
    this.priceController,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  // late final Box dataBox;
  late final TextEditingController itemController;
  late final TextEditingController priceController;

  _updateData() {
    Box<Item> itemBox = Hive.box<Item>(HiveBox.item);
    itemBox.putAt(
      widget.index,
      Item(item_name: itemController.text, price: priceController.text),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Item Updated")));
    Navigator.of(context).pop();
    print(itemBox);
    // Item newData = Item(
    //   item_name: itemController.text,
    //    price: priceController.text,
    // );
    // dataBox.putAt(widget.index, newData);
  }

  @override
  void initState() {
    super.initState();

    //dataBox = Hive.box('data_box');
    itemController = TextEditingController(text: widget.itemController);
    priceController = TextEditingController(text: widget.priceController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update Item'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: itemController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan Nama Produk',
                labelText: 'Item',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              keyboardType: TextInputType.numberWithOptions(),
              controller: priceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan harga',
                labelText: 'Price',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _updateData();
              // Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => HomePage()),
              //);
            },
            child: const Text('Update Item'),
          ),
        ],
      ),
    );
  }
}
