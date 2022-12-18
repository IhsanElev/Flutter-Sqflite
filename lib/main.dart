import 'package:crud_sqlite/helpers/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  void _refreshJournal() async {
    final data = await SqlHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournal();
    debugPrint(".. number of items ${_journals.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        _titleController.text = '';
                        _descriptionController.text = '';

                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'create new' : 'update'))
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sqlflite Crud')),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
                color: Colors.blue[200],
                margin: const EdgeInsets.all(20),
                child: ListTile(
                  trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () =>
                                  _showForm(_journals[index]['id']),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () =>
                                  _deleteItem(_journals[index]['id']),
                              icon: const Icon(Icons.delete))
                        ],
                      )),
                  title: Text(_journals[index]['title']),
                  subtitle: Text(_journals[index]['description']),
                ),
              )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }

  Future<void> _addItem() async {
    await SqlHelper.createItem(
        _titleController.text, _descriptionController.text);
    Get.snackbar('Sukses', 'Berhasil Mennambahkan data');

    _refreshJournal();

    debugPrint('Number Of Item ${_journals.length}');
  }

  Future<void> _updateItem(int id) async {
    await SqlHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournal();
  }

  Future<void> _deleteItem(id) async {
    await SqlHelper.deleteItem(id);
    Get.snackbar('Sukses', 'Berhasil Menghapus data');
    _refreshJournal();
  }
}
