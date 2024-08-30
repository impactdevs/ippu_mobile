
class WorkingExperience {
  final String? id;
  final String? user_id;
  final String? title;
  final String? description;
  final String? start_date;
  final String? end_date;
  final String? attachment;
  final String? field;
  final String? points;
  final String? position;
  final String? type;

  WorkingExperience({
    this.id,
    this.user_id,
    this.title,
    this.description,
    this.start_date,
    this.end_date,
    this.attachment,
    this.field,
    this.points,
    this.position,
    this.type,
  });
}

// import 'package:meta/meta.dart';
// import 'dart:convert';

// class WorkingExperience {
//     final List<Datum> data;

//     WorkingExperience({
//         required this.data,
//     });

//     factory WorkingExperience.fromRawJson(String str) => WorkingExperience.fromJson(json.decode(str));

//     String toRawJson() => json.encode(toJson());

//     factory WorkingExperience.fromJson(Map<String, dynamic> json) => WorkingExperience(
//         data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//     };
// }

// class Datum {
//     final int id;
//     final int userId;
//     final String title;
//     final String description;
//     final String startDate;
//     final String endDate;
//     final dynamic attachment;
//     final dynamic field;
//     final dynamic points;
//     final String position;
//     final String type;
//     final DateTime createdAt;
//     final DateTime updatedAt;

//     Datum({
//         required this.id,
//         required this.userId,
//         required this.title,
//         required this.description,
//         required this.startDate,
//         required this.endDate,
//         required this.attachment,
//         required this.field,
//         required this.points,
//         required this.position,
//         required this.type,
//         required this.createdAt,
//         required this.updatedAt,
//     });

//     factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

//     String toRawJson() => json.encode(toJson());

//     factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         id: json["id"],
//         userId: json["user_id"],
//         title: json["title"],
//         description: json["description"],
//         startDate: json["start_date"],
//         endDate: json["end_date"],
//         attachment: json["attachment"],
//         field: json["field"],
//         points: json["points"],
//         position: json["position"],
//         type: json["type"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "user_id": userId,
//         "title": title,
//         "description": description,
//         "start_date": startDate,
//         "end_date": endDate,
//         "attachment": attachment,
//         "field": field,
//         "points": points,
//         "position": position,
//         "type": type,
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//     };
// }
