import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({super.key});

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}
class _DropDownWidgetState extends State<DropDownWidget> {
  final Map<String, String> _accountTypeMap = {'Please select account type': '0'};
  String _selectedValue = 'Please select account type';

  @override
  void initState() {
    super.initState();
    _fetchAccountTypes();
  }

  Future<void> _fetchAccountTypes() async {
    final response = await http.get(Uri.parse('https://staging.ippu.org/api/account-types'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData.containsKey('data')) {
        final data = jsonData['data'] as List<dynamic>;

        setState(() {
          for (var item in data) {
            final name = item['name'].toString();
            final id = item['id'].toString();
            _accountTypeMap[name] = id;
          }
        });
      }
    } else {
      throw Exception('Failed to load account types from the API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedValue,
      onChanged: (newValue) {
        setState(() {
          _selectedValue = newValue!;
        });
      },
      items: _accountTypeMap.keys
          .map<DropdownMenuItem<String>>(
            (String name) => DropdownMenuItem<String>(
              value: _accountTypeMap[name],
              child: Text(name),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: 'Account Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
