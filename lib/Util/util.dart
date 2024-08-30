class Event {
  final int id;
  final String title;
  final String eventType;
  final bool attendanceRequest;
  final String normal_rate;
  final String member_rate;
  final String description;
  final String startDate;
  final String endDate;
  final String imageLink;
  final String points;
  final String? type;
  final String? location;
  final String? targetGroup;

  const Event( {required this.id, required this.title, required this.eventType, required this.attendanceRequest,required this.description, required this.startDate, required this.endDate, required this.imageLink, required this.points, this.type, this.location, this.targetGroup, required this.normal_rate, required this.member_rate});

  @override
  String toString() => title;
}


int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 12, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 12, kToday.day);