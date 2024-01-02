import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  fetchTodos({required String url}) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return {'body': json.decode(response.body), 'isSuccess': true};
    }

    return {'body': [], 'isSuccess': false};
  }
}
