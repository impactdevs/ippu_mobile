class AttendedCpdModel {
  final String id;
  final String code;
  final String topic;
  final String content;
  final String hours;
  final String points;
  final String targetGroup;
  final String location;
  final String startDate;
  final String endDate;
  final String normalRate;
  final String membersRate;
  final String resource;
  final String status;
  final String type;
  final String banner;
  final String attendance_status;



  AttendedCpdModel({
    required this.id,
    required this.code,
    required this.topic,
    required this.content,
    required this.hours,
    required this.points,
    required this.targetGroup,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.normalRate,
    required this.membersRate,
    required this.resource,
    required this.status,
    required this.type,
    required this.banner,
    required this.attendance_status
  });
}