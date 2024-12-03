import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/iot_items.dart';

class ApiService {
  final String baseUrl =
      'https://iotbuahjatuh-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// Fetch IoT data from Firebase
  Future<List<IoTItem>> fetchIoTData() async {
    final response = await http.get(Uri.parse('$baseUrl/.json'));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      List<IoTItem> iotItems = [];

      jsonResponse.forEach((sensorName, sensorData) {
        if (sensorData is Map<String, dynamic>) {
          // Ensure 'timestamp' is parsed correctly
          DateTime timestamp = sensorData['timestamp'] != null
              ? DateTime.parse(sensorData['timestamp'])
              : DateTime.now();

          iotItems.add(IoTItem.fromJson(sensorName, sensorData, timestamp));
        }
      });

      return iotItems;
    } else {
      print('Failed to load data, status code: ${response.statusCode}');
      throw Exception('Failed to load IoT data');
    }
  }

  /// Reset a specific sensor's status to `false`
  Future<void> resetSensorStatus(String sensorName) async {
    print('$baseUrl/$sensorName.json');
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$sensorName.json'),
        body: json.encode({
          'Distance': 0,
          'IsFall': false,
          'Timestamp': 0,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset sensor status');
      }
    } catch (e) {
      throw e; // Re-throw the error to be caught in `_resetSensorStatus`.
    }
  }
}
