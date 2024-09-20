import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://staging.ippu.org/api'; // Define the base URL

  Future<String> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
