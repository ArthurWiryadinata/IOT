import 'package:flutter/material.dart';
import 'dart:async';
import 'package:iot_project/services/iot_services.dart';
import 'package:iot_project/models/iot_items.dart';
import 'package:iot_project/models/chart_items.dart';
import 'package:intl/intl.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});
  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  final ValueNotifier<List<IoTItem>> _iotDataNotifier =
      ValueNotifier<List<IoTItem>>([]);
  final ValueNotifier<DateTime?> _lastRefreshNotifier =
      ValueNotifier<DateTime?>(null);

  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchIoTData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchIoTData();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _iotDataNotifier.dispose();
    _lastRefreshNotifier.dispose();
    super.dispose();
  }

  void _fetchIoTData() async {
    try {
      final data = await ApiService().fetchIoTData();
      _iotDataNotifier.value = data;
      _lastRefreshNotifier.value = DateTime.now();
    } catch (e) {
      debugPrint("Error fetching IoT data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<List<IoTItem>>(
        valueListenable: _iotDataNotifier,
        builder: (context, iotData, child) {
          if (iotData.isEmpty) {
            return const CircularProgressIndicator();
          }
          return SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Fruits Condition',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<DateTime?>(
                  valueListenable: _lastRefreshNotifier,
                  builder: (context, value, child) {
                    String formattedTime = value != null
                        ? DateFormat('HH:mm:ss').format(value)
                        : "Refreshing data...";
                    return Text(
                      "Last refreshed at: $formattedTime",
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.amber[600],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        columnWidths: {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2.25),
                          2: FlexColumnWidth(2.25),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(3),
                        },
                        children: [
                          TableRow(
                            children: [
                              Text('Sensor Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Distance',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Condition',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      Table(
                        columnWidths: {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2.25),
                          2: FlexColumnWidth(2.25),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(3),
                        },
                        children: iotData.map((iotItem) {
                          String formattedTimestamp =
                              DateFormat('HH:mm:ss').format(iotItem.timestamp);
                          return TableRow(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(iotItem.sensorName),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(iotItem.distance.toString()),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                    (iotItem.isFall ? "Fallen" : "Not Fallen")),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(formattedTimestamp),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _resetSensorStatus(iotItem.sensorName),
                                  child: const Text("Reset"),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.amber[600],
                  child: SizedBox(
                    height: 200,
                    child: FruitPieChart(
                      isFall: iotData.map((item) => item.isFall).toList(),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _resetSensorStatus(String sensorName) async {
    try {
      // Update the status locally
      final updatedData = _iotDataNotifier.value.map((iotItem) {
        if (iotItem.sensorName == sensorName) {
          return iotItem.copyWith(
              isFall: false); // Use your IoTItem model's copyWith method
        }
        return iotItem;
      }).toList();

      _iotDataNotifier.value = updatedData;

      // Send the reset request to the API
      await ApiService().resetSensorStatus(sensorName);

      debugPrint("Sensor $sensorName reset successfully");
    } catch (e) {
      debugPrint("Error resetting sensor $sensorName: $e");
    }
  }
}
