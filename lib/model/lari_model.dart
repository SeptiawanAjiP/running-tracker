// To parse this JSON data, do
//
//     final lariModel = lariModelFromJson(jsonString);

import 'dart:convert';

LariModel lariModelFromJson(String str) => LariModel.fromJson(json.decode(str));

String lariModelToJson(LariModel data) => json.encode(data.toJson());

class LariModel {
  LariModel({required this.id, required this.mulai, required this.selesai});

  int id;
  String mulai;
  String selesai;

  factory LariModel.fromJson(Map<String, dynamic> json) =>
      LariModel(id: json["id"], mulai: json["mulai"], selesai: json["selesai"]);

  Map<String, dynamic> toJson() =>
      {"id": id, "mulai": mulai, "selesai": selesai};
}
