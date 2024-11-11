import 'package:http/http.dart' as http;
import 'package:ippu/Util/app_endpoints.dart';

class ApiService {
  static const String baseUrl = AppEndpoints.baseUrl;

  Future<String> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
