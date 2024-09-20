class CommunicationModel {
  String id;
  String title;
  bool status;
  String message;
  String created_at;

  CommunicationModel({
    required this.id,
    required this.title,
    required this.status,
    required this.message,
    required this.created_at,
  });
}