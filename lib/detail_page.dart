import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:running_tracker/database/database_instance.dart';
import 'package:running_tracker/model/lari_detail_model.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:async';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.lariId}) : super(key: key);
  final int lariId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<MapLatLng>? _polygonPoints;
  DatabaseInstance databaseInstance = DatabaseInstance();
  late List<LariDetailModel> lariDetailModels;

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
        title: Text("Detail Lari"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          FutureBuilder<List<MapLatLng>>(
              future: databaseInstance.getDetailLari(widget.lariId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    return Container(
                      height: 300,
                      child: SfMaps(
                        layers: [
                          MapTileLayer(
                            initialZoomLevel: 15,
                            initialFocalLatLng: snapshot.data!.first,
                            initialMarkersCount: 0,
                            markerBuilder: (BuildContext context, int index) {
                              return MapMarker(
                                latitude: snapshot.data!.first.latitude,
                                longitude: snapshot.data!.first.longitude,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                              );
                            },
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            sublayers: [
                              MapPolygonLayer.inverted(
                                polygons: [
                                  MapPolygon(
                                    points: snapshot.data!,
                                  )
                                ].toSet(),
                                color: Colors.black.withOpacity(0.5),
                                strokeColor: Colors.green,
                                strokeWidth: 2.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Text("Tidak ada data"),
                    );
                  }
                }
              }),
          SizedBox(
            height: 20,
          ),
        ],
      )),
    );
  }
}
