class AllEventsModel {
  String id;
  String name;
  String start_date;
  String end_date;
  String member_rate;
  String points;
  String attachment_name;
  String banner_name;
  String details;
  bool attandence_request;
  String status;
 String normal_rate; 

  AllEventsModel({
    required this.id,
    required this.name,
    required this.attandence_request,
    required this.start_date,
    required this.end_date,
    required this.member_rate,
    required this.points,
    required this.attachment_name,
    required this.banner_name,
    required this.details,
    required this.status,
    required this.normal_rate,
  });

  String getStatus() {
    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime.parse(start_date);
    DateTime endDate = DateTime.parse(end_date);

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
    DateTime endDate = DateTime.parse(end_date);

    if (currentDate.isAfter(endDate)) {
      return true;
    } else {
      return false;
    }
  }

  //attended
  bool isAttended() {
    if (status == "Attended") {
      return true;
    } else {
      return false;
    }
  }
}
