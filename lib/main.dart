import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:running_tracker/create_page.dart';
import 'package:running_tracker/database/database_instance.dart';
import 'package:running_tracker/detail_page.dart';
import 'package:running_tracker/model/lari_model.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseInstance databaseInstance = DatabaseInstance();

  @override
  void initState() {
    // TODO: implement initState
    databaseInstance.database();
    initDatabase();

    super.initState();
  }

  Future initDatabase() async {
    await databaseInstance.database();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Running Tracker"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (contec) => CreatePage()))
              .then((value) {
            setState(() {});
          });
        },
        child: Icon(Icons.navigation),
      ),
      body: SafeArea(
          child: Column(children: [
        FutureBuilder<List<LariModel>>(
            future: databaseInstance.getAllLari(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => Card(
                          child: ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (contec) => DetailPage(
                                            lariId: snapshot.data![index].id)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mulai : " +
                                      DateFormat("dd-MM-yyyy H:mm:ss").format(
                                          DateTime.parse(
                                              snapshot.data![index].mulai))),
                                  Text("Selesai : " +
                                      DateFormat("dd-MM-yyyy H:mm:ss").format(
                                          DateTime.parse(
                                              snapshot.data![index].selesai))),
                                  Text("Durasi : " +
                                      DateTime.parse(
                                              snapshot.data![index].selesai)
                                          .difference(DateTime.parse(
                                              snapshot.data![index].mulai))
                                          .inSeconds
                                          .toString() +
                                      " detik")
                                ],
                              ),
                              leading: Icon(Icons.map))),
                    ),
                  );
                } else {
                  return Center(child: Text('Tidak ada data'));
                }
              }
            })
      ])),
    );
  }
}
