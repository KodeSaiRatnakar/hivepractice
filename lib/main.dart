import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('data_box');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  var data_box = Hive.box('data_box');
  var items = [];

  Future<void> addData(Map<String, dynamic> item) async {
    await data_box.add(item);
  }

  void getEditData(
    int key,
  ) {
    Map<String, dynamic> editItem = items.firstWhere((element) {
      if (element['key'] == key) {
        return true;
      }
      return false;
    });

    name.text = editItem['name'];

    quantity.text = editItem['quantity'];
  }

  void saveEditData(int key, Map<String, dynamic> map) {
    data_box.put(key, map);
  }

  void fetchedData() {
    var _items = data_box.keys.map((key) {
      var item = data_box.get(key);
      return {"key": key, 'name': item['name'], 'quantity': item['quantity']};
    }).toList();
    setState(() {
      items = _items;
    });
  }

  void delete(int key) {
    data_box.delete(key);
  }

  @override
  void initState() {
    fetchedData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.3),
      body: SafeArea(
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                items[index]['name'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                items[index]['quantity'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    getEditData(items[index]['key']);
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextField(
                                            controller: name,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextField(
                                            controller: quantity,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                saveEditData(items[index]['key'] , {
                                                  'name': name.text,
                                                  'quantity': quantity.text
                                                });

                                                name.clear();
                                                quantity.clear();
                                                fetchedData();
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Submit"))
                                        ],
                                      ),
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit)),IconButton(onPressed: (){
                              delete(items[index]['key']);

                                fetchedData();

                        }, icon: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
              elevation: 5,
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: name,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: quantity,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            addData(
                                {'name': name.text, 'quantity': quantity.text});

                            name.clear();
                            quantity.clear();
                            fetchedData();
                            Navigator.pop(context);
                          },
                          child: const Text("Submit"))
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
