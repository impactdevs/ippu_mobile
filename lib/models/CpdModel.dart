class CpdModel {
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
  bool attendance_request;
  final String attendance_status;

  CpdModel({
    required this.id,
    required this.code,
    required this.topic,
    required this.content,
    required this.hours,
    required this.attendance_request,
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

  String getStatus() {
    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime.parse(this.startDate);
    DateTime endDate = DateTime.parse(this.endDate);

    if (currentDate.isBefore(startDate)) {
      return "Pending";
    } else if (currentDate.isAfter(endDate)) {
      return "Happened";
    } else {
      return "Ongoing";
    }
  }

  //check if an event happened and return true else false
  bool isHappened() {
    DateTime currentDate = DateTime.now();
    DateTime endDate = DateTime.parse(this.endDate);

    if (currentDate.isAfter(endDate)) {
      return true;
    } else {
      return false;
    }
  }
}
