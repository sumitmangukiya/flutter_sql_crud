import 'package:flutter/material.dart';
import 'package:flutter_sql_crud/db_helper.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _allData = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final data = await SQLHelper.getAllDatas();
    setState(() {
      _allData = data;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addData() async {
    await SQLHelper.createData(
        _titleController.text, _descriptionController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data added successfully')));
    _clearControllers();
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
        id, _titleController.text, _descriptionController.text);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')));
    _clearControllers();
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data deleted successfully')));
    _refreshData();
  }

  void _clearControllers() {
    _titleController.text = '';
    _descriptionController.text = '';
  }

  void showBottomSheet(int? id) async {

    if (id != null) {
      final existingData = _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _clearControllers();
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Title',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              maxLines: 4,
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Description',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        backgroundColor: Colors.red,
        title: Text(
          'Flutter SQL CRUD',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _allData.isEmpty
          ? Center(
              child: Text(
              "No Data Found",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ))
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                color: Colors.red,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allData[index]['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    _allData[index]['description'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
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
        backgroundColor: Colors.red,
      ),
    );
  }
}
