import 'package:flutter/material.dart';
import 'package:flutter_sql_crud/db_helper_contact.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  List<Map<String, dynamic>> _allData = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final data = await SQLHelper.getAllContacts();
    setState(() {
      _allData = data;
    });
  }

  void _clearControllers() {
    _nameController.text = '';
    _numberController.text = '';
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _addData() async {
    if (_nameController.text.isEmpty || _numberController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    await SQLHelper.createContact(
      _nameController.text,
      _selectedImage?.path ?? '',
      // Use the path of the selected image if available
      _numberController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data added successfully')),
    );
    _clearControllers();
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateContact(
      id,
      _nameController.text,
      _selectedImage?.path ?? '',
      _numberController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data updated successfully')),
    );
    _clearControllers();
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    await SQLHelper.deleteContact(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data deleted successfully')),
    );
    _refreshData();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = _allData.firstWhere((element) =>
      element['id'] == id);
      _nameController.text = existingData['name'];
      _numberController.text = existingData['number'];
      setState(() {
        _selectedImage = File(existingData['image']);
      });
    } else {
      _clearControllers();
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) =>
          Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image'),
                    ),
                    const SizedBox(width: 10),
                    _selectedImage != null
                        ? Expanded(child: Text(_selectedImage!.path))
                        : Text('No Image Selected'),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _numberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile Number',
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                    onPressed: () async {
                      if (id == null) {
                        _addData();
                      } else {
                        _updateData(id);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        id == null ? 'Add' : 'Update',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Flutter Contact Book App',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _allData.isEmpty
          ? Center(
        child: Text(
          "No Data Found",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: _allData.length,
        itemBuilder: (context, index) => Card(
          color: Colors.indigo,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: _allData[index]['image'] != null
                        ? Image.file(
                      File(_allData[index]['image']),
                      width: 60,
                      fit: BoxFit.cover,
                      height: 60,
                    )
                        : Image.network(
                      "https://via.placeholder.com/150",
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _allData[index]['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _allData[index]['number'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        showBottomSheet(_allData[index]['id']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        _deleteData(_allData[index]['id']);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(null);
        },
        tooltip: 'Add',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}