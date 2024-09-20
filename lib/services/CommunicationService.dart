import 'dart:convert';
import 'package:ippu/services/ApiService.dart';

class CommunicationService {
  final ApiService apiService;

  CommunicationService(this.apiService);

  Future<Map<String, int>> getCountOfReadAndUnreadCommunications(
      int userId) async {
    try {
      final response = await apiService.fetchData('communications/$userId');
      final Map<String, dynamic> jsonResponse = json.decode(response);

      if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> communicationsMap = jsonResponse['data'];

        final List<dynamic> communications = communicationsMap.values.toList();

        final counts = {
          'readCount': 0,
          'unreadCount': 0,
          'totalCommunications': 0
        };

        for (final communication in communications) {
          // Assuming 'status' field exists in each communication object
          if (communication['status'] == true) {
            counts['readCount'] = counts['readCount']! + 1;
          } else {
            counts['unreadCount'] = counts['unreadCount']! + 1;
          }
        }

        counts['totalCommunications'] = communications.length;

        return counts;
      } else {
        return {'readCount': 0, 'unreadCount': 0, 'totalCommunications': 0};
      }
    } catch (error) {
      // Handle the error (e.g., log it or throw a custom exception)
      return {'readCount': 0, 'unreadCount': 0, 'totalCommunications': 0};
    }
  }
}
