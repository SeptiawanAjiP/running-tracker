import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:running_tracker/database/database_instance.dart';
import 'package:running_tracker/model/lari_detail_model.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:async';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  DatabaseInstance databaseInstance = DatabaseInstance();
  bool isRunning = false;
  late int lariId;
  late Timer myTimer;
  List<LocationData?> locations = [];

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  @override
  void initState() {
    databaseInstance.database();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mulai Lari"),
      ),
      body: FutureBuilder<LocationData?>(
          future: _currenctLocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data;
              print("KODING : " +
                  currentLocation.latitude.toString() +
                  " | " +
                  currentLocation.longitude.toString());
              return SafeArea(
                  child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  if (isRunning) Text("Selamat berlari"),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (!isRunning) {
                            lariId = await databaseInstance.insertLari(
                                {'mulai': DateTime.now().toString()});
                            print('LARI ID : $lariId');
                            locations.clear();
                            myTimer = Timer.periodic(Duration(seconds: 5),
                                (timer) async {
                              LocationData? loc = await _currenctLocation();

                              locations.add(loc);

                              int idLariDetail =
                                  await databaseInstance.insertDetailLari({
                                'lari_id': lariId,
                                'waktu': DateTime.now().toString(),
                                'latitude': loc?.latitude,
                                'longitude': loc?.longitude
                              });
                              print('LARI DETAIL ID : $idLariDetail');
                              print(
                                  'LOCATIONS : ' + locations.length.toString());
                              setState(() {});
                              //code to run on every 2 minutes 5 seconds
                            });
                            isRunning = true;

                            setState(() {});
                          } else {
                            myTimer.cancel();
                            await databaseInstance.updateLari(
                                lariId, {'selesai': DateTime.now().toString()});
                            isRunning = false;
                            setState(() {});
                            Navigator.pop(context);
                          }
                        },
                        child: isRunning ? Text("Berhenti") : Text("Mulai")),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) => Center(
                              child: Text('Latitude : ' +
                                  locations[index]!.latitude.toString() +
                                  " | Longitude : " +
                                  locations[index]!.longitude.toString()),
                            )),
                  )
                ],
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
