import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ippu/models/Payment.dart';

import '../DrawerWidget/DrawerWidget.dart';

import 'package:ippu/controllers/auth_controller.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen();

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<List<Payment>> paymentData;

  @override
  void initState() {
    super.initState();
    paymentData = loadPaymentsHistory();
  }

  Future<List<Payment>> loadPaymentsHistory() async {
    AuthController authController = AuthController();
    try {
      final response = await authController.getPaymentsHistory();
      if (response != null) {
        log("payments-responseffffffdff: $response");
        List<Payment> payments = [];
        for (var payment in response) {
          payments.add(Payment.fromJson(payment));
        }
        log("payments after conversion: $payments");
        return payments;
      } else {
        log("payments-error: You currently have no data");
        // Handle the case where the 'data' field in the API response is null
        throw Exception("You currently have no data");
      }
    } catch (error) {
      log("payments-error: $error");
      throw Exception("An error occurred while loading data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      appBar: AppBar(
        title: const Text(
          'Payments',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: paymentData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Payment> payments = snapshot.data as List<Payment>;
              log("Payments-body: $payments");
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Other Payments Section
                    const Text(
                      'Transaction History',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(children: [
                                const Icon(Icons.payment),
                                Column(
                                  children: [
                                    Text(
                                        'Payment #: ${payments[index].transactionId}'),
                                    Text('Amount: ${payments[index].amount}'),
                                    Text('Date: ${payments[index].date}'),
                                  ],
                                ),
                              ]));
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              log("Payments-body: ${snapshot.error.toString()}");
              return const Center(
                  child: Text("An error occured while getting details"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
