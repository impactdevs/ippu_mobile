class JobData {
  final int id;
  final String title;
  final String description;
  final String? visibleFrom;
  final String? visibleTo;
  final String? deadline;

  JobData({
    required this.id,
    required this.title,
    required this.description,
    this.visibleFrom,
    this.visibleTo,
    this.deadline,
  });

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      visibleFrom: json['visible_from'],
      visibleTo: json['visible_to'],
      deadline: json['deadline'],
    );
  }
}
